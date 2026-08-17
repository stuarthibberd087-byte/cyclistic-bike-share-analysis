-- SAVED QUERY NAME: 23_check_station_name_variants
--
-- DATA-QUALITY CHECK: VALIDATE THE STATION NAME FIELD
--
-- Purpose:
-- Check whether any start_station_id is recorded under more than one
-- start_station_name.
--
-- This matters because station-level analysis groups rides by station ID
-- while names are used as display labels. Identifying name variations
-- prevents them from being mistaken for separate stations.
--
-- Expected result:
-- Any returned rows identify station IDs associated with more than one
-- recorded station name. These are treated as name variations rather
-- than separate stations because the analysis groups rides by station ID.
--
-- Returned rows are recorded as a data-quality limitation and help explain
-- why station IDs are used as the grouping key throughout the analysis.
--
-- This check only covers rides with a recorded start_station_id.


SELECT

  start_station_id,
  -- The grouping key, consistent with the station-level analysis queries.


  COUNT(DISTINCT start_station_name) AS name_variants,
  -- The number of different names recorded against this station ID.
  --
  -- COUNT(DISTINCT ...) counts unique values rather than rows, so a
  -- station recorded consistently returns 1 regardless of ride volume.


  STRING_AGG(DISTINCT start_station_name, ' | ') AS names_found
  -- List the differing names side by side so that any variation can be
  -- read directly rather than investigated with a further query.

FROM
  `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`

WHERE
  start_station_id IS NOT NULL
  -- Restrict to rides that begin at an identified station.

GROUP BY
  start_station_id

HAVING
  name_variants > 1
  -- Return only the station IDs that carry more than one name.
  --
  -- This condition must sit in HAVING rather than WHERE because
  -- name_variants is calculated from the grouped rows and does not exist
  -- until grouping has taken place.

ORDER BY
  name_variants DESC;
