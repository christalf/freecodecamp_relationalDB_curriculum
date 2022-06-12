#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  echo -e "1) cut\n2) wash\n3) manicure"
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1 | 2 | 3) HANDLE_APPOINTMENT ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

HANDLE_APPOINTMENT() {
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # get customer phone and name
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if customer does not exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask new customer for his name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # enter new customer info into the customers table
    NEW_CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # get service time
  echo -e "\nWhat time would you like your$SERVICE_SELECTED, $CUSTOMER_NAME"
  read SERVICE_TIME
  # write down the appointment
  NEW_APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a$SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU

