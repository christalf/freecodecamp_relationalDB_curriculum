#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip titles
  if [[ $YEAR != "year" ]]
  then
    
    # Get winner team_id
    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    # If not found
    if [[ -z $W_TEAM_ID ]]
    # insert name of the winner team into teams table
    then
      INSERT_W_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_W_NAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted winner into teams, $WINNER
      fi
      # get the new team_id associated to the inserted winner team
      # (we'll need it to add the correct id into the games table)
      W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi
    
    # Get opponent team_id
    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # If not found
    if [[ -z $O_TEAM_ID ]]
    # insert name of the opponent team into teams table
    then
      INSERT_O_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_O_NAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted opponent into teams, $OPPONENT
      fi
      # get the new team_id associated to the inserted opponent team
      O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi

    # Insert row to the games table
    INSERT_GAME_ROW_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $W_TEAM_ID, $O_TEAM_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_ROW_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, y: $YEAR r: $ROUND w_id: $W_TEAM_ID o_id: $O_TEAM_ID w_g: $WINNER_GOALS o_g: $OPPONENT_GOALS
    fi

  fi  
done

