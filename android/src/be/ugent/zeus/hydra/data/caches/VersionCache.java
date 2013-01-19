package be.ugent.zeus.hydra.data.caches;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

/**
 *
 * @author Thomas Meire
 */
public class VersionCache {

    private static final String DATABASE_NAME = "hydradb";
    private static final int DATABASE_VERSION = 1;
    private DatabaseHelper dbhelper;

    public VersionCache(Context context) {
        dbhelper = new DatabaseHelper(context);
    }

    public void close() {
        dbhelper.close();
    }

    public void put(String key, int version) {
        SQLiteDatabase db = dbhelper.getWritableDatabase();

        ContentValues values = new ContentValues();
        values.put("key", key);
        values.put("version", version);
        db.insertWithOnConflict("version_cache", null, values, SQLiteDatabase.CONFLICT_REPLACE);
    }

    public int version(String key) {
        try {
            SQLiteDatabase db = dbhelper.getReadableDatabase();

            Cursor cursor = db.query("version_cache", new String[]{"version"}, "key = ?", new String[]{key}, "", "", "");

            if (cursor.getCount() == 0) {
                cursor.close();
                return -1;
            } else {
                cursor.moveToFirst();

                int version = cursor.getInt(cursor.getColumnIndex("version"));
                cursor.close();
                return version;
            }
        } catch (Exception e) {
            Log.e("[VersionCache]", "Database exception " + e.getMessage());
            return -1;
        }
    }

    private class DatabaseHelper extends SQLiteOpenHelper {

        public DatabaseHelper(Context context) {
            super(context, DATABASE_NAME, null, DATABASE_VERSION);
        }

        @Override
        public void onCreate(SQLiteDatabase db) {
            db.execSQL("CREATE TABLE version_cache (key TEXT PRIMARY KEY, version INT);");
        }

        @Override
        public void onUpgrade(SQLiteDatabase arg0, int arg1, int arg2) {
        }
    }
}
