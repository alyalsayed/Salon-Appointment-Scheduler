#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Function to display the numbered list of services
display_services() {
    SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services;")
    DELIMITER="|"
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo "Welcome to My Salon, how can I help you?"
    echo "$SERVICES_LIST" | while IFS=$DELIMITER read -r service_id service_name; do
        echo "$service_id) $service_name"
    done
}

# Function to get a valid service selection
get_valid_service() {
    while true; do
        display_services
        echo -e "\nWhat would you like today?"
        read SERVICE_ID_SELECTED

       # Check if the service exists
        SERVICE_EXISTS=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        if [ "$SERVICE_EXISTS" -eq 1 ]; then
            break
        else
            echo -e "\nI could not find that service. Please choose again.\n"
        fi
    done
}

# Read inputs
get_valid_service
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if the phone number exists in the customers table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
if [ -z "$CUSTOMER_ID" ]; then
   # Customer does not exist, get customer name and insert into customers table
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Insert into customers table
    $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
    
    # Retrieve the customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
    # Customer already exists, retrieve the customer name from the database
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# Read the appointment time
echo -e "\nEnter the appointment time (e.g., 10:30):"
read SERVICE_TIME

# Insert the appointment into the appointments table
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES (
        $CUSTOMER_ID,
        $SERVICE_ID_SELECTED,
        '$SERVICE_TIME')"


SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Output confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
