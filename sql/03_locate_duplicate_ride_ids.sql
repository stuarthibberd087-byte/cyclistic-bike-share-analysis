SELECT
  ride_id,  -- Display the ride ID being checked

  COUNT(*) AS occurrences,  -- Count how many times this ride ID appears

  STRING_AGG(
    DISTINCT _TABLE_SUFFIX,  -- Take each different monthly table containing the ID
    ', '                     -- Separate the table months with a comma and space
    ORDER BY _TABLE_SUFFIX   -- Arrange the table months chronologically
  ) AS tables_found          -- Name the resulting list tables_found

FROM `cyclistic-capstone-202601.cyclistic_capstone.trips_*`
-- Read every table whose name begins with trips_

GROUP BY ride_id
-- Put all records with the same ride ID into one group

HAVING COUNT(*) > 1
-- Keep only ride IDs that occur more than once

ORDER BY occurrences DESC, ride_id;
-- Show the most frequently repeated IDs first, then sort by ride ID
