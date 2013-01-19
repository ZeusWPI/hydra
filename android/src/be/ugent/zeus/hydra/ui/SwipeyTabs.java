/*
 * Copyright 2011 Peter Kuterna
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package be.ugent.zeus.hydra.ui;

import be.ugent.zeus.hydra.R;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.text.TextUtils.TruncateAt;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

public class SwipeyTabs extends ViewGroup implements OnPageChangeListener {

    protected final String TAG = "SwipeyTabs";
    private SwipeyTabsAdapter mAdapter;
    private int mCurrentPos = -1;
    // height of the bar at the bottom of the tabs
    private int mBottomBarHeight = 2;
    // height of the indicator for the fronted tab
    private int mTabIndicatorHeight = 3;
    // color for the bottom bar, fronted tab
    private int mBottomBarColor = 0xff96aa39;
    // text color for all other tabs
    private int mTextColor = 0xff949494;
    // holds the positions of the fronted tabs
    private int[] mFrontedTabPos;
    // holds the positions of the target position when swiping left
    private int[] mLeftTabPos;
    // holds the positions of the target position when swiping right
    private int[] mRightTabPos;
    // holds the positions of the current position on screen
    private int[] mCurrentTabPos;
    private Paint mCachedTabPaint;
    private boolean mInPageScrolled = false;

    public SwipeyTabs(Context context) {
        this(context, null);
    }

    public SwipeyTabs(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SwipeyTabs(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);

        final TypedArray a = context.obtainStyledAttributes(attrs,
            R.styleable.SwipeyTabs, defStyle, 0);

        mBottomBarColor = a.getColor(R.styleable.SwipeyTabs_bottomBarColor,
            mBottomBarColor);
        mBottomBarHeight = a.getDimensionPixelSize(
            R.styleable.SwipeyTabs_bottomBarHeight, 2);
        mTabIndicatorHeight = a.getDimensionPixelSize(
            R.styleable.SwipeyTabs_tabIndicatorHeight, 3);
        mTextColor = a.getColor(R.styleable.SwipeyTabs_tabTextColor, 0xff949494);

        a.recycle();

        init();
    }

    /**
     * Initialize the SwipeyTabs {@link ViewGroup}
     */
    private void init() {
        // enable the horizontal fading edges which will be drawn by the parent
        // View
        setHorizontalFadingEdgeEnabled(true);
        setFadingEdgeLength((int) (getResources().getDisplayMetrics().density * 35.0f + 0.5f));
        setWillNotDraw(false);

        mCachedTabPaint = new Paint();
        mCachedTabPaint.setColor(mBottomBarColor);
    }

    /**
     * Set the adapter.
     *
     * @param adapter
     */
    public void setAdapter(SwipeyTabsAdapter adapter) {
        if (mAdapter != null) {
            // TODO: data set observer
        }

        mAdapter = adapter;
        mCurrentPos = -1;
        mFrontedTabPos = null;
        mLeftTabPos = null;
        mRightTabPos = null;
        mCurrentTabPos = null;

        // clean up our childs
        removeAllViews();

        if (mAdapter != null) {
            final int count = mAdapter.getCount();

            // add the child text views
            for (int i = 0; i < count; i++) {
                addView(mAdapter.getTab(i, this));
            }

            mCurrentPos = 0;
            mFrontedTabPos = new int[count];
            mLeftTabPos = new int[count];
            mRightTabPos = new int[count];
            mCurrentTabPos = new int[count];

            requestLayout();
        }
    }

    /**
     * Calculate the fronted, left and right positions
     *
     * @param forceLayout force the current positions to the values of the calculated fronted
     * positions
     */
    private void updateTabPositions(boolean forceLayout) {
        if (mAdapter == null) {
            return;
        }

        calculateTabPosition(mCurrentPos, mFrontedTabPos);
        calculateTabPosition(mCurrentPos + 1, mLeftTabPos);
        calculateTabPosition(mCurrentPos - 1, mRightTabPos);

        updateEllipsize();

        if (forceLayout) {
            System.arraycopy(mFrontedTabPos, 0, mCurrentTabPos, 0, mAdapter.getCount());
        }
    }

    /**
     * Calculate the position of the tabs.
     *
     * @param position the position of the fronted tab
     * @param tabPositions the array in which to store the result
     */
    private void calculateTabPosition(int position, int[] tabPositions) {
        if (mAdapter == null) {
            return;
        }

        final int count = mAdapter.getCount();

        if (position >= 0 && position < count) {
            final int width = getMeasuredWidth();

            final View centerTab = getChildAt(position);
            tabPositions[position] = width / 2 - centerTab.getMeasuredWidth()
                / 2;
            for (int i = position - 1; i >= 0; i--) {
                final TextView tab = (TextView) getChildAt(i);
                if (i == position - 1) {
                    tabPositions[i] = 0 - tab.getPaddingLeft();
                } else {
                    tabPositions[i] = 0 - tab.getMeasuredWidth() - width;
                }
                tabPositions[i] = Math.min(tabPositions[i], tabPositions[i + 1]
                    - tab.getMeasuredWidth());
            }
            for (int i = position + 1; i < count; i++) {
                final TextView tab = (TextView) getChildAt(i);
                if (i == position + 1) {
                    tabPositions[i] = width - tab.getMeasuredWidth()
                        + tab.getPaddingRight();
                } else {
                    tabPositions[i] = width * 2;
                }
                final TextView prevTab = (TextView) getChildAt(i - 1);
                tabPositions[i] = Math.max(tabPositions[i], tabPositions[i - 1]
                    + prevTab.getMeasuredWidth());
            }
        } else {
            for (int i = 0; i < tabPositions.length; i++) {
                tabPositions[i] = -1;
            }
        }
    }

    /**
     * Update the ellipsize of the text views
     */
    private void updateEllipsize() {
        if (mAdapter == null) {
            return;
        }

        final int count = mAdapter.getCount();

        for (int i = 0; i < count; i++) {
            TextView tab = (TextView) getChildAt(i);

            if (i < mCurrentPos) {
                tab.setEllipsize(null);
                tab.setGravity(Gravity.RIGHT | Gravity.CENTER_VERTICAL);
            } else if (i == mCurrentPos) {
                tab.setEllipsize(TruncateAt.END);
                tab.setGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);
            } else if (i > mCurrentPos) {
                tab.setEllipsize(null);
                tab.setGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);
            }
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int widthSize = MeasureSpec.getSize(widthMeasureSpec);

        measureTabs(widthMeasureSpec, heightMeasureSpec);

        int height = 0;
        final View v = getChildAt(0);
        if (v != null) {
            height = v.getMeasuredHeight();
        }

        setMeasuredDimension(
            resolveSize(getPaddingLeft() + widthSize + getPaddingRight(),
            widthMeasureSpec),
            resolveSize(height + mBottomBarHeight + getPaddingTop()
            + getPaddingBottom(), heightMeasureSpec));

        if (!mInPageScrolled) {
            updateTabPositions(true);
        }

    }

    /**
     * Measure our tab text views
     *
     * @param widthMeasureSpec
     * @param heightMeasureSpec
     */
    private void measureTabs(int widthMeasureSpec, int heightMeasureSpec) {
        if (mAdapter == null) {
            return;
        }

        int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        final int maxWidth = (int) (widthSize * 0.6);

        final int count = mAdapter.getCount();

        for (int i = 0; i < count; i++) {
            LayoutParams layoutParams = (LayoutParams) getChildAt(i).getLayoutParams();
            final int widthSpec = MeasureSpec.makeMeasureSpec(maxWidth,
                MeasureSpec.AT_MOST);
            final int heightSpec = MeasureSpec.makeMeasureSpec(
                layoutParams.height, MeasureSpec.EXACTLY);
            getChildAt(i).measure(widthSpec, heightSpec);
        }
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        if (mAdapter == null) {
            return;
        }

        final int count = mAdapter.getCount();

        for (int i = 0; i < count; i++) {
            View v = getChildAt(i);

            v.layout(mCurrentTabPos[i], this.getPaddingTop(), mCurrentTabPos[i]
                + v.getMeasuredWidth(),
                this.getPaddingTop() + v.getMeasuredHeight());
        }
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        if (mCurrentPos != -1) {
            // calculate the relative position of the fronted tab to set the
            // alpha channel of the tab indicator
            final int tabSelectedTop = getHeight() - getPaddingBottom()
                - mBottomBarHeight - mTabIndicatorHeight;
            final View currentTab = getChildAt(mCurrentPos);
            final int centerOfTab = (mCurrentTabPos[mCurrentPos] + currentTab.getMeasuredWidth()) - (currentTab.getMeasuredWidth() / 2);
            final int center = getWidth() / 2;
            final int centerDiv3 = center / 3;
            final float relativePos = 1.0f - Math.min(
                Math.abs((float) (centerOfTab - center)
                / (float) (centerDiv3)), 1.0f);

            mCachedTabPaint.setAlpha((int) (255 * relativePos));
            canvas.drawRect(
                mCurrentTabPos[mCurrentPos],
                tabSelectedTop,
                mCurrentTabPos[mCurrentPos] + currentTab.getMeasuredWidth(),
                tabSelectedTop + mTabIndicatorHeight, mCachedTabPaint);

            // set the correct text colors on the text views
            final int count = mAdapter.getCount();
            for (int i = 0; i < count; i++) {
                final TextView tab = (TextView) getChildAt(i);
                if (mCurrentPos == i) {
                    tab.setTextColor(interpolateColor(mBottomBarColor,
                        mTextColor, 1.0f - relativePos));
                } else {
                    tab.setTextColor(mTextColor);
                }
            }

        }

        super.dispatchDraw(canvas);
    }

    @Override
    public void draw(Canvas canvas) {
        super.draw(canvas);

        // draw the bottom bar
        final int bottomBarTop = getHeight() - getPaddingBottom()
            - mBottomBarHeight;
        mCachedTabPaint.setAlpha(0xff);
        canvas.drawRect(0, bottomBarTop, getWidth(), bottomBarTop
            + mBottomBarHeight, mCachedTabPaint);
    }

    @Override
    protected float getLeftFadingEdgeStrength() {
        // forced so that we will always have the left fading edge
        return 1.0f;
    }

    @Override
    protected float getRightFadingEdgeStrength() {
        // forced so that we will always have the right fading edge
        return 1.0f;
    }

    public void onPageScrollStateChanged(int state) {
        updateTabPositions(true);
        requestLayout();
    }

    public void onPageScrolled(int position, float positionOffset,
        int positionOffsetPixels) {
        if (mAdapter == null) {
            return;
        }

        final int count = mAdapter.getCount();

        float x = 0.0f;
        int dir = 0;

        // detect the swipe direction
        if (positionOffsetPixels != 0 && mCurrentPos == position) {
            dir = -1;
            x = positionOffset;
        } else if (positionOffsetPixels != 0 && mCurrentPos != position) {
            dir = 1;
            x = 1.0f - positionOffset;
        }

        mInPageScrolled = (dir != 0);

        // update the current positions
        for (int i = 0; i < count; i++) {
            final float curX = mFrontedTabPos[i];
            float toX = 0.0f;

            if (dir < 0) {
                toX = mLeftTabPos[i];
            } else if (dir > 0) {
                toX = mRightTabPos[i];
            } else {
                toX = mFrontedTabPos[i];
            }

            final int offsetX = (int) ((toX - curX) * x + 0.5f);
            final int newX = (int) (curX + offsetX);

            mCurrentTabPos[i] = newX;
        }

        requestLayout();
    }

    public void onPageSelected(int position) {
        mCurrentPos = position;
        updateTabPositions(false);
    }

    private int interpolateColor(final int color1, final int color2,
        float fraction) {
        final float alpha1 = Color.alpha(color1) / 255.0f;
        final float red1 = Color.red(color1) / 255.0f;
        final float green1 = Color.green(color1) / 255.0f;
        final float blue1 = Color.blue(color1) / 255.0f;

        final float alpha2 = Color.alpha(color2) / 255.0f;
        final float red2 = Color.red(color2) / 255.0f;
        final float green2 = Color.green(color2) / 255.0f;
        final float blue2 = Color.blue(color2) / 255.0f;

        final float deltaAlpha = alpha2 - alpha1;
        final float deltaRed = red2 - red1;
        final float deltaGreen = green2 - green1;
        final float deltaBlue = blue2 - blue1;

        float alpha = alpha1 + (deltaAlpha * fraction);
        float red = red1 + (deltaRed * fraction);
        float green = green1 + (deltaGreen * fraction);
        float blue = blue1 + (deltaBlue * fraction);

        alpha = Math.max(Math.min(alpha, 1f), 0f);
        red = Math.max(Math.min(red, 1f), 0f);
        green = Math.max(Math.min(green, 1f), 0f);
        blue = Math.max(Math.min(blue, 1f), 0f);

        return Color.argb((int) (alpha * 255.0f), (int) (red * 255.0f),
            (int) (green * 255.0f), (int) (blue * 255.0f));
    }
}
