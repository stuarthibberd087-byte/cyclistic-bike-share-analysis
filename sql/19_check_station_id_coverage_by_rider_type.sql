-- SAVED QUERY NAME: 19_check_station_id_coverage_by_rider_type
--
-- ANALYZE PHASE: CHECK STATION-ID COVERAGE BY RIDER TYPE
--
-- Purpose:
-- Measure how much usable start and end station information is available
-- for member and casual rides.
--
-- Some rides have no station ID because they began or ended outside the
-- named station network. These records were intentionally retained during
-- cleaning because they remain valid for the core time and duration analysis.
--
-- This query does not remove those records. It only measures how much of
-- each rider category can be included in a station-level comparison.


SELECT

  member_casual,
  -- Separate the results into member and casual rides.


  COUNT(*) AS total_rides,
  -- Count every cleaned ride in the rider category.


  COUNTIF(
    start_station_id IS NOT NULL
    AND TRIM(start_station_id) != ''
  ) AS rides_with_start_station_id,
  -- Count rides containing a usable starting-station ID.
  --
  -- IS NOT NULL checks that a value was recorded.
  -- TRIM removes any outside spaces.
  -- != '' confirms that the remaining value is not empty.


  ROUND(
    100 * COUNTIF(
      start_station_id IS NOT NULL
      AND TRIM(start_station_id) != ''
    ) / COUNT(*),
    2
  ) AS percentage_with_start_station_id,
  -- Divide rides with a starting-station ID by all rides in the category.
  -- Multiply by 100 to produce a percentage.


  COUNTIF(
    end_station_id IS NOT NULL
    AND TRIM(end_station_id) != ''
  ) AS rides_with_end_station_id,
  -- Count rides containing a usable ending-station ID.


  ROUND(
    100 * COUNTIF(
      end_station_id IS NOT NULL
      AND TRIM(end_station_id) != ''
    ) / COUNT(*),
    2
  ) AS percentage_with_end_station_id,
  -- Calculate the percentage of rides with a usable ending-station ID.


  COUNTIF(
    start_station_id IS NOT NULL
    AND TRIM(start_station_id) != ''
    AND end_station_id IS NOT NULL
    AND TRIM(end_station_id) != ''
  ) AS rides_with_both_station_ids,
  -- Count rides containing both a starting- and ending-station ID.
  -- These rides could be used for a station-to-station route analysis.


  ROUND(
    100 * COUNTIF(
      start_station_id IS NOT NULL
      AND TRIM(start_station_id) != ''
      AND end_station_id IS NOT NULL
      AND TRIM(end_station_id) != ''
    ) / COUNT(*),
    2
  ) AS percentage_with_both_station_ids
  -- Calculate what percentage of the rider category has both station IDs.


FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`
-- Read only the verified cleaned table.


GROUP BY member_casual
-- Produce one coverage summary for casual rides and one for member rides.


ORDER BY member_casual;
-- Display casual followed by member.
