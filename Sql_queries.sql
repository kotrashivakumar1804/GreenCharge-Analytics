create DATABASE ev_charging_db;
USE ev_charging_db;

SHOW TABLES;

SET SQL_SAFE_UPDATES = 0;

UPDATE ev_charging_data
SET duration_difference = ABS(duration_difference);

SELECT * FROM ev_charging_data;

RENAME TABLE ev_charging_data To EV_charging;

select * from EV_charging;


-- 1) Display all columns and the first 10 records from the `ev_charging_data` table. --
select * from EV_charging limit 10;
select count(distinct(user_id)) from EV_charging ;

-- 2) What is the overall demand profile of EV charging sessions? --
select MIN(demand_value) AS minimum_demand,
	MAX(demand_value) AS maximum_demand,
	AVG(demand_value) AS average_demand,
	COUNT(*) AS total_sessions
FROM Ev_charging;

-- 3) Which hours have the highest charging activity ? --
select start_hour,count(demand_value) as charging_sessions from
EV_charging group by start_hour order by charging_sessions DESC;
 
-- 4) How many sessions fall into each demand_level category, and what percentage of all sessions does each category represent? --
select demand_level,count(*) as charging_sessions ,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM EV_charging),2
) AS session_percentage
from Ev_charging group by demand_level order by charging_sessions DESC;
 
 -- 5) What is the average calculated_duration_minutes by charger_speed_category? --
 select charger_speed_category,avg(calculated_duration_minutes) as Average_duration_minutes 
 from Ev_charging group by charger_speed_category order by Average_duration_minutes DESC;
 
-- 6) Which charging_location has the most charging sessions, and what is its average demand per session? --
select charging_location,count(*) as charging_sessions ,avg(demand_value) as Average_demand_per_session 
from Ev_charging
group by charging_location order by charging_sessions DESC;

-- 7) Which charger_company_name has the highest average demand_value, and how many sessions does each company serve? --
select charger_company_name,count(*) as Charging_sessions,
AVG(demand_value) AS average_demand 
from Ev_charging
group by charger_company_name 
order by Charging_sessions DESC;

-- 8) How does demand differ across charger_type_code? --
SELECT charger_type_code,COUNT(demand_value) AS total_sessions,
    AVG(demand_value) AS avg_demand_per_session,SUM(demand_value) AS total_demand
FROM Ev_charging 
GROUP BY charger_type_code
ORDER BY total_demand DESC;

-- 9) Which locations have the highest proportion of high-demand sessions? --
SELECT
    charging_location,
    demand_level,
    COUNT(*) AS session_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY charging_location),2) AS demand_percentage
FROM EV_charging
GROUP BY charging_location, demand_level
ORDER BY charging_location, demand_percentage DESC;

-- 10) Do short, medium, and long charging sessions have different average demand values? --
SELECT duration_group,COUNT(*) AS sessions_count,ROUND(AVG(demand_value), 2) AS average_demand
FROM (SELECT demand_value,
CASE
	WHEN calculated_duration_minutes < 30 THEN 'Short'
	WHEN calculated_duration_minutes BETWEEN 30 AND 60 THEN 'Medium'
	WHEN calculated_duration_minutes > 60 THEN 'Long'
END AS duration_group
FROM EV_charging) 
AS duration_data
WHERE duration_group IS NOT NULL
GROUP BY duration_group ORDER BY
    CASE duration_group
        WHEN 'Short' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Long' THEN 3
    END DESC;

-- 11) How many charging sessions have a difference greater than 5 minutes between the recorded duration and calculated duration? --
SELECT
    user_id,
    charger_id,
    duration_minutes,
    calculated_duration_minutes,
    ABS(duration_minutes - calculated_duration_minutes)
        AS duration_difference
FROM EV_charging
ORDER BY duration_difference DESC
LIMIT 10;


SHOW VARIABLES LIKE 'hostname';




