#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]] #aka - if we aren't looking at the first csv row...
  then
    #get unique team names from winner column
    #check each existing team ID and team name in teams table to see if current winner is there
    #get team_id first
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  
    #if team id isn't found in teams table with matching name, insert $WINNER as new row in teams
    if [[ -z $WINNER_ID ]]
    then
      #insert $WINNER
      INSERT_WINNER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted Winner into teams, $WINNER
      fi

      #still need winner id for games table row addition below
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    fi
    #get unique team names from opponent columnn
    #check each existing team ID and team name in teams table to see if current opponent is there
    #get team_id first
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #if team id isn't found in teams table with matching name, insert $OPPONENT as new row in teams
    if [[ -z $OPP_ID ]]
    then
      #insert $OPPONENT
      INSERT_OPP_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPP_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted Opponent into teams, $OPPONENT
      fi

      #still need opponent id for games table row addition below
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    fi

    #while looping through each line for teams, lets also add the games
    #this should be a straightforward addition for each line (1 line = 1 game)
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPP_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo Inserted Game into Games, $YEAR $ROUND $WINNER $OPPONENT
    fi

  fi
done

