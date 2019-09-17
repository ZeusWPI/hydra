# Models
- Prophet: seems nice, but not really sure if we can apply it here (https://facebook.github.io/prophet/)
- Random Forest: has good accuracy on a similar problem; see: https://www.kaggle.com/nsrose7224/crowdedness-at-the-campus-gym. Definitely something we should attempt to emulate (and check if our results are as good).
- Some custom combination of averages (moving, weighted):
  - Only check for similar weeks in previous semesters For example, predict week 1 of semester 2019/1 as some average of week 1 of semester 2018/2, 2018/1, 2017/2, etc. Vacations would be predicted by similarly looking at the corresponding weeks in previous year.
  - Divide weeks up into categories, and use some average (e.g. weighted) from the weeks in those categories. For example, predict week 1 of semester 2019/1 as the average of all previous "semester" weeks. Vacations would be predicted by averaging similar vacations, e.g. predict easter 2020 by averaging easter 2019, 2018, ...
  
# Other concerns:

- How to manage data?
    - Perhaps split into weeks and location, and version these (smaller) files into git (check with sysadmins about storage use or just use github)
- Contect Dienst Maaltijdvoorziening once we have some model, and try to get fresh data regularly (e.g. every week or month).
    - Need a quick way to update estimates by suppling fresh data (not possible with Prophet)