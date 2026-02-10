#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to my salon, How can I help you?\n"

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

MAIN_MENU(){
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

echo "$SERVICES" | while IFS="|" read ID NAME
do
  echo "$ID) $NAME"
done

read SERVICE_ID_SELECTED

if [[ -z $SERVICE_ID_SELECTED || !  $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
    return
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $SERVICE_NAME ]]
then
   echo -e "\nI could not find that service. What would you like today?"
   MAIN_MENU
else
   echo "the service_name is $SERVICE_NAME"
   echo "What's your phone number?"
   read CUSTOMER_PHONE

   CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

   if [[ -z $CUSTOMER_NAME ]]
   then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers (name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
   fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
     echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
     read SERVICE_TIME

     $PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')"

     echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
   
fi
}
MAIN_MENU

