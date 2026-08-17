WITH duplicate_ids AS (

  SELECT
    ride_id  -- Select each repeated ride ID

  FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`
  -- Read all 12 monthly tables

  GROUP BY ride_id
  -- Put matching ride IDs into groups

  HAVING COUNT(*) > 1
  -- Keep only IDs occurring more than once
)

SELECT
  t.ride_id,  -- Display the duplicated ride ID

  COUNT(*) AS occurrences,
  -- Count the records found for this ride ID

  COUNT(DISTINCT TO_JSON_STRING(t)) AS distinct_record_versions,
  -- Convert each complete row to text and count how many different versions exist

  STRING_AGG(
    DISTINCT _TABLE_SUFFIX,
    ', '
    ORDER BY _TABLE_SUFFIX
  ) AS tables_found
  -- Show which monthly tables contain the ride ID

FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*` AS t
-- Read all ride records and give the tables the short name t

INNER JOIN duplicate_ids AS d
  ON t.ride_id = d.ride_id
-- Keep only records whose ride ID is in the duplicate list

GROUP BY t.ride_id
-- Produce one result row for each duplicated ride ID

ORDER BY t.ride_id;
-- Arrange the results by ride ID
