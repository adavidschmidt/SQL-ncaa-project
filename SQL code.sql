# Filter to the team with the most wins in all seasons

SELECT name, wins, losses, season
FROM
 `bigquery-public-data.ncaa_basketball.mbb_historical_teams_seasons` AS seasons
WHERE division = 1
ORDER BY wins DESC
LIMIT 1;


# Find the team with the highest number of wins per season

SELECT season, name, wins
FROM (
  SELECT season, name, wins,
    ROW_NUMBER() OVER (PARTITION BY season ORDER BY wins DESC) AS rank
  FROM `bigquery-public-data.ncaa_basketball.mbb_historical_teams_seasons`
  WHERE division = 1
)
WHERE rank = 1
ORDER BY season DESC;


# Find the team with the most losses per season

SELECT season, name, losses
FROM (
  SELECT season, name, losses,
    ROW_NUMBER() OVER ( PARTITION BY season ORDER BY losses DESC) AS rank
  FROM `bigquery-public-data.ncaa_basketball.mbb_historical_teams_seasons`
  WHERE division = 1
)
WHERE rank = 1
ORDER BY season DESC;
 
# Lets find who has the highest AVG win rate per season and add the mascot for the teams in for a join
 
SELECT seasons.season, seasons.university, seasons.name, ROUND(seasons.average*100), mascots.mascot
FROM (
  SELECT season, name, average,team_id, university,
    ROW_NUMBER() OVER ( PARTITION BY season ORDER BY average DESC) AS rank
  FROM (SELECT season, name, wins/NULLIF(wins + losses, 0) as average, team_id, market AS university
    FROM `bigquery-public-data.ncaa_basketball.mbb_historical_teams_seasons`
    WHERE division = 1)
) AS seasons
LEFT JOIN `bigquery-public-data.ncaa_basketball.mascots` AS mascots
ON
seasons.team_id = mascots.id
WHERE rank = 1
ORDER BY season DESC
