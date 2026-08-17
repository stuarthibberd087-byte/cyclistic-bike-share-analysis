-- SAVED QUERY NAME: 21_analyze_time_patterns_at_top_casual_stations
--
-- ANALYZE PHASE: TIME PATTERNS AT HIGH-CASUAL STARTING STATIONS
--
-- Purpose:
-- Determine when member and casual rides begin at the high-volume stations
-- where casual rides outnumber member rides.
--
-- The query:
-- 1. Identifies the 12 highest-volume casual-majority starting stations.
-- 2. Divides rides into weekdays and weekends.
-- 3. Divides the day into five understandable time periods.
-- 4. Compares member and casual ride volume within those periods.
--
-- These time periods are analytical groupings created for this project.
-- They are not categories supplied by Divvy.
--
-- This query only summarises rides_clean and changes nothing.


WITH station_totals AS (

  SELECT

    start_station_id,
    -- Use the station ID as the reliable grouping key.

    COUNTIF(
      member_casual = 'casual'
    ) AS casual_rides,
    -- Count casual rides beginning at each station.

    COUNTIF(
      member_casual = 'member'
    ) AS member_rides
    -- Count member rides beginning at each station.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`

  WHERE
    start_station_id IS NOT NULL
    AND TRIM(start_station_id) != ''
  -- Include only rides with a usable starting-station ID.

  GROUP BY start_station_id
),


top_casual_stations AS (

  SELECT

    start_station_id
    -- Retain the IDs needed to match these stations back to rides_clean.

  FROM station_totals

  WHERE casual_rides > member_rides
  -- Keep stations where casual rides outnumber member rides.

  ORDER BY casual_rides DESC
  -- Rank the remaining stations by casual ride volume.

  LIMIT 12
  -- Select the 12 highest-volume casual-majority stations.
  -- These correspond to the leading casual-majority stations found
  -- in the previous station query.
),


cluster_time_summary AS (

  SELECT

    r.member_casual,
    -- Separate the cluster's rides into member and casual categories.


    CASE

      WHEN r.ride_day_number IN (1, 7)
      THEN 'Weekend'

      ELSE 'Weekday'

    END AS day_type,
    -- BigQuery weekday numbers use Sunday = 1 and Saturday = 7.
    -- IN (1, 7) therefore identifies weekend rides.
    -- Every other day is labelled as a weekday.


    CASE

      WHEN r.start_hour BETWEEN 0 AND 5
      THEN 'Overnight: 00:00-05:59'

      WHEN r.start_hour BETWEEN 6 AND 9
      THEN 'Morning: 06:00-09:59'

      WHEN r.start_hour BETWEEN 10 AND 14
      THEN 'Midday: 10:00-14:59'

      WHEN r.start_hour BETWEEN 15 AND 18
      THEN 'Afternoon: 15:00-18:59'

      ELSE 'Evening: 19:00-23:59'

    END AS time_period,
    -- CASE assigns each starting hour to one of five time periods.
    -- BETWEEN includes both numbers at its boundaries.
    -- For example, BETWEEN 6 AND 9 includes hours 6, 7, 8 and 9.


    CASE

      WHEN r.start_hour BETWEEN 0 AND 5 THEN 1
      WHEN r.start_hour BETWEEN 6 AND 9 THEN 2
      WHEN r.start_hour BETWEEN 10 AND 14 THEN 3
      WHEN r.start_hour BETWEEN 15 AND 18 THEN 4
      ELSE 5

    END AS time_period_order,
    -- Create a numerical value so the time periods can be arranged
    -- chronologically rather than alphabetically.


    COUNT(*) AS total_rides
    -- Count rides for each rider-type, day-type and time-period combination.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean` AS r

  INNER JOIN top_casual_stations AS s
    ON r.start_station_id = s.start_station_id
  -- INNER JOIN keeps only rides whose starting-station ID appears
  -- in the list of 12 selected stations.
  --
  -- r and s are short aliases for the two data sources.

  GROUP BY
    r.member_casual,
    day_type,
    time_period,
    time_period_order
  -- Produce one result for each combination of rider type,
  -- weekday/weekend and time period.
)


SELECT

  member_casual,

  day_type,

  time_period,

  total_rides,

  ROUND(
    100 * total_rides
    / SUM(total_rides) OVER (
        PARTITION BY member_casual
      ),
    2
  ) AS percentage_of_cluster_rider_type_rides
  -- Calculate each result as a percentage of all cluster rides
  -- belonging to that rider type.
  --
  -- Member and casual percentages are calculated separately.
  -- This makes their time patterns comparable despite different totals.


FROM cluster_time_summary


ORDER BY

  CASE
    WHEN day_type = 'Weekday' THEN 1
    ELSE 2
  END,
  -- Display weekday results before weekend results.

  time_period_order,

  member_casual;
  -- Arrange each day type chronologically.
  -- Within each period, display casual followed by member.
