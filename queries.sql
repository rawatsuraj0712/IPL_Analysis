-- Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order.
SELECT
	*
FROM
	DELIVERIES
LIMIT
	20;

-- Select the top 20 rows of the matches table.
SELECT
	*
FROM
	MATCHES
LIMIT
	20;

-- Fetch data of all the matches played on 2nd May 2013 from the matches table.
SELECT
	*
FROM
	MATCHES
WHERE
	DATE = '2-5-2013';

-- Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs.
SELECT
	*
FROM
	MATCHES
WHERE
	(
		RESULT = 'runs'
		AND RESULT_MARGIN > 100
	);

-- Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.
SELECT
	*
FROM
	MATCHES
WHERE
	RESULT = 'tie'
ORDER BY
	DATE DESC;

-- Get the count of cities that have hosted an IPL match.
SELECT
	COUNT(DISTINCT CITY) AS TOTAL_HOST_CITIES
FROM
	MATCHES;

/* Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional column ball_result containing values boundary, dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)
 (Hint 1 : CASE WHEN statement is used to get condition based results)
 (Hint 2: To convert the output data of select statement into a table, you can use a subquery. Create table table_name as [entire select statement]. */
CREATE TABLE DELIVERIES_V02 AS
SELECT
	*,
	CASE
		WHEN TOTAL_RUNS >= 4 THEN 'boundary'
		WHEN TOTAL_RUNS = 0 THEN 'dot'
		ELSE 'other'
	END AS BALL_RESULT
FROM
	DELIVERIES;

-- Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.
SELECT
	BALL_RESULT,
	COUNT(*) AS BALL_COUNT
FROM
	DELIVERIES_V02
GROUP BY
	BALL_RESULT;

-- Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of boundaries scored.
SELECT
	BATTING_TEAM,
	COUNT(*)
FROM
	DELIVERIES_V02
WHERE
	BALL_RESULT = 'boundary'
GROUP BY
	BATTING_TEAM
ORDER BY
	COUNT DESC;

-- Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the total number of dot balls bowled.
SELECT
	BOWLING_TEAM,
	COUNT(*)
FROM
	DELIVERIES_V02
WHERE
	BALL_RESULT = 'dot'
GROUP BY
	BOWLING_TEAM
ORDER BY
	COUNT DESC;

-- Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA
SELECT
	DISMISSAL_KIND,
	COUNT(*) AS DISMISSALS
FROM
	DELIVERIES
WHERE
	DISMISSAL_KIND <> 'NA'
GROUP BY
	DISMISSAL_KIND
ORDER BY
	DISMISSALS DESC;

-- Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table
SELECT
	BOWLER,
	SUM(EXTRA_RUNS) AS MAX_EXTRAS
FROM
	DELIVERIES
GROUP BY
	BOWLER
ORDER BY
	MAX_EXTRAS DESC
LIMIT
	5;

-- Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) of venue and date from table matches
CREATE TABLE DELIVERIES_V03 AS
SELECT
	A.*,
	B.VENUE,
	B.DATE
FROM
	DELIVERIES_V02 AS A
	LEFT JOIN (
		SELECT
			MAX(VENUE) AS VENUE,
			MAX(DATE) AS DATE,
			ID
		FROM
			MATCHES
		GROUP BY
			ID
	) AS B ON A.ID = B.ID;

-- Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.
SELECT
	DISTINCT(VENUE) AS VENUE,
	SUM(TOTAL_RUNS)
FROM
	DELIVERIES_V03
GROUP BY
	VENUE
ORDER BY
	TOTAL_RUNS DESC;

-- Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.
SELECT
	EXTRACT(
		YEAR
		FROM
			DATE
	) AS YEARS,
	SUM(TOTAL_RUNS) AS RUNS
FROM
	DELIVERIES_V03
WHERE
	VENUE = 'Eden Gardens'
GROUP BY
	YEARS
ORDER BY
	RUNS DESC;

-- Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants.  Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns.
CREATE TABLE matches_corrected AS
SELECT
	*,
	REPLACE(
		TEAM1,
		'Rising Pune Supergiants',
		'Rising Pune Supergiant'
	) AS team1_corr,
	REPLACE(
		TEAM1,
		'Rising Pune Supergiants',
		'Rising Pune Supergiant'
	) AS team2_corr
FROM
	MATCHES;

SELECT
	DISTINCT team1_corr
FROM
	matches_corrected;

-- Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03)
CREATE TABLE DELIVERIES_V04 AS
SELECT
	CONCAT(
		ID || '-' || INNING || '-' || OVER || '-' || BALL
	) AS BALL_ID,
	*
FROM
	DELIVERIES_V03;

-- Compare the total count of rows and total count of distinct ball_id in deliveries_v04;
SELECT
	COUNT(*) AS TOTAL_ROWS,
	COUNT(DISTINCT(BALL_ID)) AS TOTAL_UNIQUE_IDS
FROM
	DELIVERIES_V04;

-- SQL Row_Number() function is used to sort and assign row numbers to data rows in the presence of multiple groups. For example, to identify the top 10 rows which have the highest order amount in each region, we can use row_number to assign row numbers in each group (region) with any particular order (decreasing order of order amount) and then we can use this new column to apply filters. Using this knowledge, solve the following exercise. You can use hints to create an additional column of row number.
-- Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. (HINT : Syntax to add along with other columns,  row_number() over (partition by ball_id) as r_num)
CREATE TABLE DELIVERIES_V05 AS
SELECT
	*,
	Row_Number() OVER (PARTITION BY BALL_ID) AS r_num
FROM
	DELIVERIES_V04;

-- Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. (HINT : select * from deliveries_v05 WHERE r_num=2;)
SELECT
	*,
FROM
	DELIVERIES_V05
WHERE
	r_num = 2
ORDER BY
	r_num;

-- Use subqueries to fetch data of all the ball_id which are repeating. (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2);
SELECT
	*
FROM
	deliveries_v05
WHERE
	ball_id in (
		select
			BALL_ID
		from
			deliveries_v05
		WHERE
			r_num = 2
	);