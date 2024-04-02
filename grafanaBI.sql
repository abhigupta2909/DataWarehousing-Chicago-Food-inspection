-- get number of inspections by year:

select dd.year_actual, count(*) AS "Inspection_Count"
FROM chicago_ins.FCT_Chicago_FoodInspections fi
JOIN chicago_ins.Dim_date dd ON fi.Inspection_Date_Key = dd.date_key
GROUP BY dd.year_actual
ORDER BY dd.year_actual;

