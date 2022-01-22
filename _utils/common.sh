#!/bin/bash

########################################
### Colors 
########################################
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White


#
###   a bash script that echoes its argument 2 character
###   per second.
###

# Get the desired string to print
function slowecho(){
    text=$1
    color="${2:-'\033[0;33m'}"
    # Loop over the text
    for (( i=0; i < ${#text}; i+=1 )) ; 
    do
        # Print out the next letter
        echo -n -e "${color}${text:$i:1}${Color_Off}"
        # Sleep for 0.5 seconds
        sleep 0.01
    done
    echo
}