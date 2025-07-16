#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear tables
echo "$($PSQL "TRUNCATE games, teams RESTART IDENTITY;")"

# Read CSV and insert data
tail -n +2 games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Insert winner if not exists
  if [[ $($PSQL "SELECT COUNT(*) FROM teams WHERE name='$WINNER';") -eq 0 ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$WINNER');"
  fi

  # Insert opponent if not exists
  if [[ $($PSQL "SELECT COUNT(*) FROM teams WHERE name='$OPPONENT';") -eq 0 ]]
  then
    $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');"
  fi

  # Get IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

  # Insert game row
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
done
