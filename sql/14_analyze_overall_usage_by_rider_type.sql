-- ANALYZE PHASE: OVERALL USAGE BY RIDER TYPE
--
-- Purpose:
-- Establish the overall difference in ride volume and ride duration
-- between member and casual rides.
--
-- Each record represents one ride, not one individual rider.
-- This query only summarises rides_clean and changes nothing.

WITH rider_summary AS (

  SELECT

    member_casual,
    -- Separate the records into member and casual rides.


    COUNT(*) AS total_rides,
    -- Count the number of cleaned rides in each rider category.


    ROUND(
      AVG(ride_duration_minutes),
      2
    ) AS average_ride_minutes,
    -- Calculate the arithmetic mean ride duration.
    -- Long rides can pull the average upwards, so the median is also calculated.


    ROUND(
      APPROX_QUANTILES(
        ride_duration_minutes,
        100
      )[OFFSET(50)],
      2
    ) AS median_ride_minutes,
    -- APPROX_QUANTILES divides the durations into 100 ordered groups.
    -- OFFSET(50) selects the middle value, giving the approximate median.
    -- The median is less affected by unusually long rides than the average.


    MIN(ride_duration_minutes) AS shortest_ride_minutes,
    -- Show the shortest retained ride in each category.


    MAX(ride_duration_minutes) AS longest_ride_minutes
    -- Show the longest retained ride in each category.

  FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`
  -- Read only the verified cleaned table.

  GROUP BY member_casual
  -- Produce one summary row for members and one for casual riders.
)

SELECT

  member_casual,

  total_rides,

  ROUND(
    100 * total_rides / SUM(total_rides) OVER (),
    2
  ) AS percentage_of_all_rides,
  -- SUM(total_rides) OVER() calculates the total across both result rows.
  -- Dividing each category by that total gives its share of all cleaned rides.


  average_ride_minutes,

  median_ride_minutes,

  shortest_ride_minutes,

  longest_ride_minutes

FROM rider_summary
-- Use the two summary rows created above.

ORDER BY member_casual;
-- Display casual followed by member.
