#!/bin/bash

# Greeting
echo "Welcome to password generator"

# ask the user how long password should be
echo "Please enter the length of the password:"

# read the input given by user and store in variable
read  PASS_LENGTH

#Validate input
if ! [[ $PASS_LENGTH =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a valid number."
    exit 1
fi
#Creating an array named passwords to capture generated passwords 
passwords=()

# loop will create 3 passwords according to user as per length given by user and save them to array
for p in $(seq 1 3);
do
    passwords+=("$(openssl rand -base64 48 | cut -c1-$PASS_LENGTH )")
done

#Display generated passwords
echo "Here are the generated passwords:"
printf "%s\n" "${passwords[@]}"

# Ask user if they want to save the passwords to a file
echo "Do you want to save these passwords to a file? (y/n)"
read  choice
if [ "$choice" = "y" ]; then

      #Encrypt passwords before saving
        for password in "${passwords[@]}"; do
            # Encrypt each password using ccrypt and store in the file
            echo "$password" | ccrypt -e -K "$PASSPHRASE" > "passwords.txt.cpt"
        done

    echo "Passwords saved securely to passwords.txt.cpt"
       #printf "%s\n" "${passwords[@]}" >>passwords.txt.cpt

elif [ "$choice" = "n" ]; then
     echo "Passwords not saved."
fi





# Ask user if they want to save the passwords to a file
echo "Do you want to save these passwords to a file? (y/n)"
read choice
if [ "$choice" = "y" ]; then
    echo "Enter a passphrase to encrypt the file:"
    read -s PASSPHRASE

    printf "%s\n" "${passwords[@]}" > passwords.txt

    # Encrypt with gpg
    echo "$PASSPHRASE" | gpg --batch --yes --passphrase-fd 0 -c passwords.txt

    rm passwords.txt   # delete plain file
    echo "Passwords saved securely to passwords.txt.gpg"
elif [ "$choice" = "n" ]; then
    echo "Passwords not saved."
fi
