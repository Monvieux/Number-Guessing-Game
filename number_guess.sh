#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USER_NAME

DB_USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USER_NAME';")
# if user not in database
if [[ -z $DB_USER_ID ]]
then
  USER_INSERT=$($PSQL "INSERT INTO users(user_name) VALUES('$USER_NAME');")
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  DB_USER_ID=$($PSQL "SELECT user_id FROM users WHERE user_name='$USER_NAME';")
# if user in database
else
  DATA_GAME=$($PSQL "SELECT COUNT(game_id) AS total_game, MIN(number_guesses) as best_guesses FROM games WHERE user_id=$DB_USER_ID;")
  IFS='|' read -a DATAS <<< "$DATA_GAME"
  echo -e "\nWelcome back, $USER_NAME! You have played ${DATAS[0]} games, and your best game took ${DATAS[1]} guesses."
 
fi

# Add data in table games
if [[ ! -z $DB_USER_ID ]]
then
  RANDOM_NUMBER=$(($RANDOM%(1000)+1))
  #use nim vlue random for testing
  #RANDOM_NUMBER=$(($RANDOM%(10)+1))
  USER_NUMBER=0
  let USER_GUESSES=1
  
  echo -e "\nGuess the secret number between 1 and 1000:"
  while [ $USER_NUMBER -ne $RANDOM_NUMBER ]
  do
    read USER_NUMBER
    
    if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
    elif [[ $USER_NUMBER -lt $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      let USER_GUESSES++
    elif [[ $USER_NUMBER -gt $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      let USER_GUESSES++
    elif [[ $USER_NUMBER -eq $RANDOM_NUMBER ]]
    then
      GAME_INSERT=$($PSQL "INSERT INTO games(user_id,secret_number,number_guesses) VALUES($DB_USER_ID,$RANDOM_NUMBER,$USER_GUESSES);")
      echo -e "\nYou guessed it in $USER_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  done

fi

