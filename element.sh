#!/bin/bash
PSQL="psql -X --username=postgres --dbname=periodic_table --tuples-only -c"

#Searches through the limited periodic table looking for a matching atomic number, symbol, or name
ELEMENT_SEARCH(){
  if [[ ! $1 =~ ^[0-9]+$ ]]
    #If statement to check if its a valid argument
    then 
    ELE_SEARCH=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1' OR symbol='$1' ")
    else
    ELE_SEARCH=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1 ")
    fi

    if [[ -z $ELE_SEARCH ]]
      #if the search returned no matches in the database
      then
       echo "I could not find that element in the database."
      else
      #if results were returned it will now query the database for the requested values and format them appropriately to be displayed.
        ELE_RESULTS=$($PSQL "SELECT name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements on properties.atomic_number=elements.atomic_number WHERE properties.atomic_number=$ELE_SEARCH" )
        #two queries are used to avoid joining three tables
        ELE_TYPE=$($PSQL "SELECT type FROM types INNER JOIN properties on types.type_id=properties.type_id WHERE properties.atomic_number=$ELE_SEARCH")  
        echo "$ELE_RESULTS" | while read NAME BAR SYMBOL BAR MASS BAR MELT BAR BOIL
        do
          echo -e "The element with atomic number $(echo $ELE_SEARCH | sed -r 's/^[ \t]*//g') is $NAME ($SYMBOL). It's a$ELE_TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
        done    
   fi 
  }
#Allow script to be ran with initial argument, if not ask for an element and then run the search function
MAIN_MENU(){
    if [[ $1 ]]
  then
    ELEMENT_SEARCH $1
      else
      echo Please provide an element as an argument.
      #read ELE_SEARCH
      #ELEMENT_SEARCH "$ELE_SEARCH"

  fi

}


MAIN_MENU "$1"

#ask for element
#if not atomic number symbol or name reject and "I could not find that element in the database"
#if exists return info about that element from joined table
#delete the incorrect 