Date startDate = Date.newInstance(2026, 10, 23); 
Date endDate = Date.newInstance(2026, 10, 30);   

System.debug(
    WorkingDaysCalculator.getWorkingDays(startDate, endDate)
);