-- SAVED QUERY NAME: 18_analyze_bicycle_type_by_rider_type
--
-- ANALYZE PHASE: BICYCLE-TYPE USAGE BY RIDER TYPE
--
-- Purpose:
-- Compare how members and casual riders use the available bicycle types.
--
-- We will calculate:
-- 1. The number of rides for each rider and bicycle-type combination.
-- 2. How each rider category divides its rides between bicycle types.
-- 3. How rides on each bicycle type divide between members and casual riders.
-- 4. The average and median ride duration for each combination.
--
-- Each record represents one ride, not one individual rider.
-- This query only summarises rides_clean and changes nothing.


WITH bicycle_summary AS (

  SELECT

    rideable_type,
    -- Display the bicycle category exactly as recorded in the cleaned table.

    member_casual,
    -- Separate each bicycle category into member and casual rides.

    COUNT(*) AS total_rides,
    -- Count the rides in each bicycle-type and rider-type combination.

    ROUND(
      AVG(ride_duration_minutes),
      2
    ) AS average_ride_minutes,
    -- Calculate the average ride duration for the combination.
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
    rideable_type,
    member_casual
  -- Produce one result for every bicycle-type and rider-type combination.
)


SELECT

  rideable_type,

  member_casual,

  total_rides,

  ROUND(
    100 * total_rides
    / SUM(total_rides) OVER (
        PARTITION BY member_casual
      ),
    2
  ) AS percentage_of_rider_type_rides,
  -- Calculate the total number of rides separately for members and casual riders.
  -- Divide each bicycle-type count by that rider category's total.
  --
  -- This answers:
  -- "What percentage of member or casual rides used this bicycle type?"


  ROUND(
    100 * total_rides
    / SUM(total_rides) OVER (
        PARTITION BY rideable_type
      ),
    2
  ) AS percentage_of_bicycle_type_rides,
  -- Calculate the total rides separately for each bicycle type.
  -- Divide each rider category's count by the bicycle-type total.
  --
  -- This answers:
  -- "What percentage of rides on this bicycle type were member or casual rides?"


  average_ride_minutes,

  median_ride_minutes

FROM bicycle_summary
-- Use the bicycle-type results calculated above.

ORDER BY
  rideable_type,
  member_casual;
-- Arrange the results by bicycle type.
-- Within each type, display casual followed by member.
