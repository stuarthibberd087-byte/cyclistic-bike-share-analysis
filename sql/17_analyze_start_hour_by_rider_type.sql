-- SAVED QUERY NAME: 17_analyze_start_hour_by_rider_type
--
-- ANALYZE PHASE: RIDE STARTING HOUR BY RIDER TYPE
--
-- Purpose:
-- Compare when member and casual rides begin during the day.
--
-- This will help identify whether member rides show morning and
-- evening commuting peaks and whether casual rides are concentrated
-- later in the day.
--
-- Each record represents one ride, not one individual rider.
-- This query only summarises rides_clean and changes nothing.


WITH hourly_summary AS (

  SELECT

    start_hour,
    -- start_hour was created during the Process phase.
    -- It records the hour in which the ride started using values from 0 to 23.
    --
    -- For example:
    -- 0 represents midnight to 00:59.
    -- 8 represents 08:00 to 08:59.
    -- 17 represents 17:00 to 17:59.

    member_casual,
    -- Separate the results into member and casual rides.

    COUNT(*) AS total_rides,
    -- Count how many rides began during each hour for each rider category.

    ROUND(
      AVG(ride_duration_minutes),
      2
    ) AS average_ride_minutes,
    -- Calculate the average duration of rides beginning during each hour.
    -- ROUND(..., 2) displays the result to two decimal places.

    ROUND(
      APPROX_QUANTILES(
        ride_duration_minutes,
        100
      )[OFFSET(50)],
      2
    ) AS median_ride_minutes
    -- Calculate the approximate median duration for each starting hour.
    -- The median is less affected by unusually long rides than the average.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`
  -- Read only the verified cleaned table.

  GROUP BY
    start_hour,
    member_casual
  -- Produce one result for every starting-hour and rider-type combination.
)


SELECT

  start_hour,

  FORMAT(
    '%02d:00',
    start_hour
  ) AS hour_label,
  -- Display the starting hour as a familiar time label.
  -- %02d means display the number using two digits.
  -- For example, 8 becomes 08:00 and 17 becomes 17:00.

  member_casual,

  total_rides,

  ROUND(
    100 * total_rides
    / SUM(total_rides) OVER (
        PARTITION BY member_casual
      ),
    2
  ) AS percentage_of_rider_type_rides,
  -- Calculate the total number of rides separately for each rider category.
  -- Divide each hourly count by that category's annual total.
  -- This allows the hourly patterns of members and casual riders to be
  -- compared even though members made more rides overall.

  average_ride_minutes,

  median_ride_minutes

FROM hourly_summary
-- Use the hourly results calculated above.

ORDER BY
  start_hour,
  member_casual;
-- Arrange the results chronologically from midnight through 23:00.
-- Within each hour, display casual followed by member.
