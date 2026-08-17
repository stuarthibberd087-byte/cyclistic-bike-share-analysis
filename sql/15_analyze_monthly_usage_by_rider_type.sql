-- SAVED QUERY NAME: 15_analyze_monthly_usage_by_rider_type
--
-- ANALYZE PHASE: MONTHLY USAGE BY RIDER TYPE
--
-- Purpose:
-- Compare how member and casual ride numbers and ride durations
-- change across the twelve months.
--
-- This will show whether casual use is more seasonal and whether
-- member use remains more consistent throughout the year.
--
-- Each row in rides_clean represents one ride, not one rider.
-- This query only summarises the data and changes nothing.


WITH monthly_summary AS (

  SELECT

    ride_month,
    -- ride_month is the first day of the month in which the ride started.
    -- For example, every ride starting in July 2025 has 2025-07-01.

    member_casual,
    -- Separate the results into member and casual rides.

    COUNT(*) AS total_rides,
    -- Count the rides made by each rider category during each month.

    ROUND(
      AVG(ride_duration_minutes),
      2
    ) AS average_ride_minutes,
    -- Calculate the average ride duration for each category and month.
    -- ROUND(..., 2) displays the result to two decimal places.

    ROUND(
      APPROX_QUANTILES(
        ride_duration_minutes,
        100
      )[OFFSET(50)],
      2
    ) AS median_ride_minutes
    -- Divide the durations into 100 ordered groups.
    -- OFFSET(50) selects the middle value, giving the approximate median.
    -- The median is less affected by unusually long rides than the average.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`
  -- Read only the verified cleaned table.

  GROUP BY
    ride_month,
    member_casual
  -- Produce one result for each month and rider-type combination.
)


SELECT

  FORMAT_DATE(
    '%Y-%m',
    ride_month
  ) AS month,
  -- Display the month in year-month format, such as 2025-07.

  member_casual,

  total_rides,

  ROUND(
    100 * total_rides
    / SUM(total_rides) OVER (
        PARTITION BY member_casual
      ),
    2
  ) AS percentage_of_rider_type_annual_rides,
  -- SUM(total_rides) calculates the annual total separately for each rider type.
  -- PARTITION BY member_casual keeps the member and casual totals separate.
  -- Each monthly count is divided by its category's annual total.
  -- This shows what percentage of all member or casual rides occurred that month.

  average_ride_minutes,

  median_ride_minutes

FROM monthly_summary
-- Use the monthly results calculated above.

ORDER BY
  ride_month,
  member_casual;
-- Arrange the results chronologically.
-- Within each month, display casual followed by member.
