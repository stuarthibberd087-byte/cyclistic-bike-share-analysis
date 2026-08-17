-- SAVED QUERY NAME: 20_identify_top_casual_start_stations
--
-- ANALYZE PHASE: IDENTIFY THE TOP STARTING STATIONS FOR CASUAL RIDES
--
-- Purpose:
-- Find the starting stations with the greatest number of casual rides.
--
-- The result will also show:
-- 1. Member ride volume at each station.
-- 2. Total recorded rides at each station.
-- 3. The percentage of station rides made by casual riders.
--
-- Ranking by casual ride volume identifies locations with substantial
-- casual use for further comparison.
--
-- This analysis only includes rides with a recorded start_station_id.
-- It does not represent rides beginning outside the named station network.


SELECT

  start_station_id,
  -- Use the station ID as the grouping key.
  -- Station IDs are preferable to names because names can occasionally
  -- change or be written differently while the ID remains consistent.


  MAX(start_station_name) AS start_station_name,
  -- Return a readable station name to accompany the station ID.
  --
  -- MAX normally finds the largest value, but when applied to text it
  -- selects the value appearing last alphabetically.
  -- The purpose here is simply to return one available name.
  -- All ride counts continue to be grouped by the station ID.


  COUNTIF(
    member_casual = 'casual'
  ) AS casual_rides,
  -- Count casual rides beginning at the station.


  COUNTIF(
    member_casual = 'member'
  ) AS member_rides,
  -- Count member rides beginning at the station.


  COUNT(*) AS total_station_rides,
  -- Count all recorded rides beginning at the station.


  ROUND(
    100 * COUNTIF(
      member_casual = 'casual'
    ) / COUNT(*),
    2
  ) AS percentage_casual_rides
  -- Divide casual rides by all rides beginning at the station.
  -- Multiply by 100 to produce the casual percentage.
  --
  -- This provides context because a station can have many casual rides
  -- while still being used mainly by members.


FROM `cyclistic-capstone-202601.cyclistic_capstone.rides_clean`
-- Read only the verified cleaned table.


WHERE
  start_station_id IS NOT NULL
  AND TRIM(start_station_id) != ''
-- Include only rides with a usable starting-station ID.
-- Rides without an ID remain in the cleaned table but cannot be assigned
-- to a named station for this comparison.


GROUP BY start_station_id
-- Combine all rides with the same starting-station ID into one result row.


ORDER BY
  casual_rides DESC,
  start_station_id
-- Rank stations from the greatest to the smallest casual ride volume.
-- The station ID provides consistent ordering if two stations have
-- the same casual ride count.


LIMIT 20;
-- Return only the 20 stations with the greatest number of casual rides.
-- This keeps the result focused enough for the capstone and later visualisation.
