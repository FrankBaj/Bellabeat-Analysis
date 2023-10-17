SELECT *
FROM [Bellabeat Data].[dbo].[sleepDay_merged]

SELECT COUNT(DISTINCT Id)
FROM [Bellabeat Data].[dbo].[total_active_time_bydate]

--- AVERAGE CALORIES BURNED BY DAY
SELECT Id, ActivityDate, AVG(Calories) as Average_Calories_Burned_By_Day
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id, ActivityDate
ORDER BY Id

--- AVERAGE CALORIES BURNED BY ID
SELECT Id, AVG(Calories) as Average_Calories_Burned
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

--- AVERAGE STEPS BY ID
SELECT Id, AVG(TotalSteps) as Average_Steps
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

--- AVERAGE DISTANCE BY DAY
SELECT Id, ActivityDate, AVG(TotalDistance) as Average_Distance_By_Day
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id, ActivityDate
ORDER BY Id

--- AVERAGE DISTANCE BY ID
SELECT Id, AVG(TotalDistance) as Average_Distance
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

--- AVERAGE OF VERY ACTIVE MINUTES BY ID
SELECT Id, AVG(VeryActiveMinutes) as Average_VeryActive
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

--- AVERAGE OF FAIRLY ACTIVE MINUTES BY ID
SELECT Id, AVG(FairlyActiveMinutes) as Average_FairlyActive
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

--- AVERAGE OF LIGHTLY ACTIVE MINUTES BY ID
SELECT Id, AVG(LightlyActiveMinutes) as Average_LightlyActive
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

--- AVERAGE OF SEDENTARY MINUTES BY ID
SELECT Id, AVG(SedentaryMinutes) as Average_Sedentary
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

--- DATES WHERE USERS MAXIMISED SEDENTARY TIME
CREATE TABLE test (
	Id bigint,
	ActivityDate date,
	Longest_Duration_Sedentary float
)
INSERT INTO test(Id, ActivityDate, Longest_Duration_Sedentary)
SELECT Id, ActivityDate, MAX(SedentaryMinutes) AS Lazy_Time
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id, ActivityDate
ORDER BY Lazy_Time DESC

SELECT * FROM test ORDER BY Id
DROP TABLE test

SELECT DISTINCT test.id, OG_table.ActivityDate, OG_table.SedentaryMinutes
FROM [Bellabeat Data].dbo.dailyActivity_merged AS OG_table
RIGHT JOIN test ON test.Longest_Duration_Sedentary = OG_table.SedentaryMinutes

--- DATES WHERE USERS MAXIMISED BURNED CALORIES
CREATE TABLE test2 (
	Id bigint,
	Max_Calories_Burned smallint
) INSERT INTO test2(Id, Max_Calories_Burned)
SELECT Id, MAX(Calories) as Most_Calories_Burned
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id

SELECT * FROM test2 ORDER BY Id
DROP TABLE test2

SELECT DISTINCT test2.id, OG_table.ActivityDate, test2.Max_Calories_Burned
FROM [Bellabeat Data].dbo.dailyActivity_merged AS OG_table
INNER JOIN test2 ON test2.Max_Calories_Burned = OG_table.Calories
ORDER BY OG_table.ActivityDate

--- DAYS WHERE USERS WERE MORE SEDENTARY THAN THE AVERAGE

SELECT AVG(SedentaryMinutes) FROM [Bellabeat Data].dbo.dailyActivity_merged

SELECT Id, ActivityDate, SedentaryMinutes
FROM [Bellabeat Data].dbo.dailyActivity_merged
WHERE SedentaryMinutes > (SELECT AVG(SedentaryMinutes) FROM [Bellabeat Data].dbo.dailyActivity_merged)
ORDER BY SedentaryMinutes

--- USERS WITH HIGHER THAN AVERAGE SEDENTARY TIME

SELECT Id, AVG(SedentaryMinutes) AS Average_Sedentary_Time
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
HAVING AVG(SedentaryMinutes) > (SELECT AVG(SedentaryMinutes) FROM [Bellabeat Data].dbo.dailyActivity_merged)


--- DAYS WHERE USERS BURNED MORE CALORIES THAN THE AVERAGE

SELECT AVG(Calories) FROM [Bellabeat Data].dbo.dailyActivity_merged

SELECT Id, ActivityDate, Calories
FROM [Bellabeat Data].dbo.dailyActivity_merged
WHERE Calories > (SELECT AVG(Calories) FROM [Bellabeat Data].dbo.dailyActivity_merged)
ORDER BY Calories

--- USERS WITH HIGHER THAN AVERAGE CALORIES BURNED

SELECT Id, AVG(Calories) AS Average_Calories_Burned
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
HAVING AVG(Calories) > (SELECT AVG(Calories) FROM [Bellabeat Data].dbo.dailyActivity_merged)

--- COMBINED TABLE FOR CALORIES BURNED AND SEDENTARY TIME

CREATE TABLE calories_burned(
	Id bigint,
	Average_calories_burned smallint
)
INSERT INTO calories_burned(Id, Average_calories_burned)
SELECT Id, AVG(Calories)
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
HAVING AVG(Calories) > (SELECT AVG(Calories) FROM [Bellabeat Data].dbo.dailyActivity_merged)

SELECT * FROM calories_burned
DROP TABLE calories_burned

CREATE TABLE sedentary_time(
	Id bigint,
	Average_sedentary_time smallint
)
INSERT INTO sedentary_time(Id, Average_sedentary_time)
SELECT Id, AVG(SedentaryMinutes)
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
HAVING AVG(SedentaryMinutes) > (SELECT AVG(SedentaryMinutes) FROM [Bellabeat Data].dbo.dailyActivity_merged)

SELECT * FROM sedentary_time
DROP TABLE sedentary_time

SELECT *
FROM calories_burned AS cb
FULL JOIN sedentary_time AS st ON cb.Id = st.Id

--- AVERAGE TOTAL MINUTES ACTIVE VS TOTAL SEDENTARY TIME
ALTER TABLE [Bellabeat Data].dbo.dailyActivity_merged
ALTER COLUMN VeryActiveMinutes smallint;

ALTER TABLE [Bellabeat Data].dbo.dailyActivity_merged
ALTER COLUMN FairlyActiveMinutes smallint;


CREATE TABLE total_active_time(
	Id bigint,
	total_active_minutes int
)
INSERT INTO total_active_time(Id, total_active_minutes)
SELECT Id, SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes)
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id
ORDER BY Id

SELECT * FROM total_active_time
DROP TABLE total_active_time

CREATE TABLE total_sedentary_time(
	Id bigint,
	sedentary_time int
)
INSERT INTO total_sedentary_time(Id, sedentary_time)
SELECT Id, SUM(SedentaryMinutes)
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id

SELECT * FROM total_sedentary_time
DROP TABLE total_sedentary_time

Select tat.ID, tat.total_active_minutes, tst.sedentary_time
FROM total_active_time AS tat
INNER JOIN total_sedentary_time AS tst ON tst.Id = tat.Id

--- AVERAGE ACTIVE MINUTES VS. AVERAGE SEDENTARY TIME

CREATE TABLE total_active_time_bydate(
	Id bigint,
	ActivityDate date,
	total_active_minutes int
)
INSERT INTO total_active_time_bydate(Id, ActivityDate, total_active_minutes)
SELECT Id, ActivityDate, SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes)
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id, ActivityDate

SELECT * FROM total_active_time_bydate

CREATE TABLE average_sedentary_time(
	Id bigint,
	avg_sedentary_time int
)
INSERT INTO average_sedentary_time(Id, avg_sedentary_time)
SELECT Id, AVG(SedentaryMinutes)
FROM [Bellabeat Data].dbo.dailyActivity_merged
GROUP BY Id

SELECT * FROM average_sedentary_time
DROP TABLE average_sedentary_time

CREATE TABLE average_of_TotalActivetime(
	Id bigint,
	Avg_Active_time int
)
INSERT INTO average_of_TotalActivetime(Id, Avg_Active_time)
SELECT Id, AVG(total_active_minutes)
FROM total_active_time_bydate
GROUP BY Id

SELECT * FROM average_of_TotalActivetime
DROP TABLE average_of_TotalActivetime

Select ast.ID, atat.Avg_Active_time, ast.avg_sedentary_time
FROM average_sedentary_time AS ast
INNER JOIN average_of_TotalActivetime AS atat ON ast.Id = atat.Id

--- AVERAGE MINUTES ASLEEP AND TIME IN BED
SELECT SleepDay, AVG(TotalMinutesAsleep) AS Avg_Time_Asleep, AVG(TotalTimeInBed) AS Avg_Time_in_Bed
FROM [Bellabeat Data].[dbo].[sleepDay_merged]
GROUP BY SleepDay