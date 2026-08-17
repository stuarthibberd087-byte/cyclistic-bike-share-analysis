-- SAVED QUERY NAME: 16_analyze_weekday_usage_by_rider_type
--
-- ANALYZE PHASE: USAGE BY DAY OF THE WEEK
--
-- Purpose:
-- Compare the number and duration of member and casual rides
-- across each day of the week.
--
-- This will help determine whether casual rides are more associated
-- with weekends and whether member rides are more associated with weekdays.
--
-- Each record represents one ride, not one individual rider.
-- This query only summarises rides_clean and changes nothing.


WITH weekday_summary AS (

  SELECT

    ride_day_number,
    -- Numerical weekday value created during the Process phase.
    -- BigQuery uses Sunday = 1 through Saturday = 7.
    -- This field allows the weekday names to be arranged correctly.

    ride_day_name,
    -- Display the full weekday name, such as Monday or Saturday.

    member_casual,
    -- Separate the results into member and casual rides.

    COUNT(*) AS total_rides,
    -- Count the rides made by each rider category on each weekday.

    ROUND(
      AVG(ride_duration_minutes),
      2
    ) AS average_ride_minutes,
    -- Calculate the average ride duration for the category and weekday.
    -- ROUND(..., 2) displays the result to two decimal places.

    ROUND(
      APPROX_QUANTILES(
        ride_duration_minutes,
        100
      )[OFFSET(50)],
      2
    ) AS median_ride_minutes
    -- Calculate the approximate middle ride duration.
    -- The median is less affected by unusually long rides than the average.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`
  -- Read only the verified cleaned table.

  GROUP BY
    ride_day_number,
    ride_day_name,
    member_casual
  -- Produce one result for each weekday and rider-type combination.
)


SELECT

  ride_day_number,

  ride_day_name,

  member_casual,

  total_rides,

  ROUND(
    100 * total_rides
    / SUM(total_rides) OVER (
        PARTITION BY member_casual
      ),
    2
  ) AS percentage_of_rider_type_rides,
  -- SUM(total_rides) calculates the total number of rides separately
  -- for members and casual riders.
  --
  -- Each weekday count is divided by its rider category's total.
  -- This shows the percentage of all member or casual rides occurring
  -- on each day of the week.

  average_ride_minutes,

  median_ride_minutes

FROM weekday_summary
-- Use the weekday results calculated above.

ORDER BY
  ride_day_number,
  member_casual;
-- Arrange the days from Sunday through Saturday.
-- Within each day, display casual followed by member.
