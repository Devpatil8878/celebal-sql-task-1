WITH CheckInOutTimes AS (
    SELECT
        EmpID,
        Name,
        MIN(CASE WHEN Attendance = 'IN' THEN CONCAT(Date, ' ', Time) END) AS FirstCheckInTime,
        MAX(CASE WHEN Attendance = 'OUT' THEN CONCAT(Date, ' ', Time) END) AS LastCheckOutTime
    FROM EmployeeAttendance
    GROUP BY EmpID, Name
),
TotalOutCount AS (
    SELECT
        EmpID,
        COUNT(*) AS TotalOutCount
    FROM EmployeeAttendance
    WHERE Attendance = 'OUT'
    GROUP BY EmpID
),
WorkDurations AS (
    SELECT
        ea1.EmpID,
        TIMESTAMPDIFF(MINUTE, CONCAT(ea1.Date, ' ', ea1.Time), CONCAT(ea2.Date, ' ', ea2.Time)) AS WorkDuration
    FROM
        EmployeeAttendance ea1
    JOIN
        EmployeeAttendance ea2 ON ea1.EmpID = ea2.EmpID
    WHERE
        ea1.Attendance = 'IN' AND ea2.Attendance = 'OUT'
        AND CONCAT(ea1.Date, ' ', ea1.Time) < CONCAT(ea2.Date, ' ', ea2.Time)
),
TotalWorkMinutes AS (
    SELECT
        EmpID,
        SUM(WorkDuration) AS TotalWorkMinutes
    FROM
        WorkDurations
    GROUP BY
        EmpID
)
SELECT
    ci.EmpID,
    ci.Name,
    ci.FirstCheckInTime,
    ci.LastCheckOutTime,
    toc.TotalOutCount,
    SEC_TO_TIME(twm.TotalWorkMinutes * 60) AS TotalWorkHours
FROM
    CheckInOutTimes ci
JOIN
    TotalOutCount toc ON ci.EmpID = toc.EmpID
JOIN
    TotalWorkMinutes twm ON ci.EmpID = twm.EmpID
ORDER BY
    ci.EmpID;
