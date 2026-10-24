public with sharing class WorkingDaysCalculator {
       public static Integer getWorkingDays(Date startDate, Date endDate) {
        Integer workingDays = 0;
         if (startDate == null || endDate == null || startDate >= endDate) {
            return 0;
        }
        Date currentDate = startDate.addDays(1);
        while (currentDate < endDate) {
            Datetime CurrentDatetime = (Datetime) currentDate;
            String dayOfWeek = CurrentDatetime.formatGMT('EEEE');
            if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                workingDays++;
            }
            currentDate = currentDate.addDays(1);
        }

        return workingDays;
    }
}