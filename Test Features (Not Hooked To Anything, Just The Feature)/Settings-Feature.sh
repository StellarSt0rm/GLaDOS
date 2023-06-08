#!/bin/bash

blue=$(tput setaf 4)
yellow=$(tput setaf 11)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)
magneta=$(tput setaf 5)

#Check If Sudo
if [[ $EUID -ne 0 ]]; then
	sudo="false"
	user=$USER
else
	sudo="true"
	user=$SUDO_USER
fi

function cleanup() {
  stty echo
  printf \\33\[\?1047l
  tput rc
  exit
}

trap cleanup SIGINT
stty -echo
function clr() {
  for ((i=0; i<$1; i++)); do
    printf "\033[F\033[2K\r"
  done
}

function main() {
  printf "${blue}Welcome To The Settings Prompt! What Do You Want To Do?\n${yellow}1) Personality\n2) Exit\n" && printf "${normal}Option: " && stty echo && read C && stty -echo
  if [ "$C" = 1 ]; then
    clr 4
    personality
  elif [ "$C" = 2 ]; then
   	printf \\33\[\?1047l
    tput rc
    stty echo
    exit
  else
    printf "${red}Invalid Input! Press Enter To Try Again" && read && printf "\033[2K" && clr 4
    main
  fi
}

function personality() {
  printf "${blue}Personality:  What Do You Want To Do?\n${yellow}1) Set Personality\n2) Clear Personality\n3) Back\n" && printf "${normal}Option: " && stty echo && read C && stty -echo
  if [ "$C" = 1 ]; then
    clr 5
    personality_2
  elif [ "$C" = 2 ]; then
    printf \\33\[\?1047l
    tput rc
    printf "${green}\nSuccesfully Cleared Personality\n"
    rm /home/$user/.config/glados/settings-p.txt
    stty echo
    exit
  elif [ "$C" = 3 ]; then
    clr 5
    main
  else
    printf "${red}Invalid Input! Press Enter To Try Again" && read && printf "\033[2K" && clr 5
    personality
  fi
}

function personality_2() {
  printf "${blue}Set Personality:  What Personality Do You Want? (If You Want Two Or More Use Option 6)\n${yellow}1) Sarcastic\n2) Funny\n3) Comedic\n4) Rude\n5) Custom\n6) Cancel/Back\n" && printf "${normal}Option: " && stty echo && read C && stty -echo
  if [ "$C" = 1 ]; then
    P="sarcastic"
  elif [ "$C" = 2 ]; then
    P="funny"
  elif [ "$C" = 3 ]; then
    P="comedic"
  elif [ "$C" = 4 ]; then
    P="rude"
  elif [ "$C" = 5 ]; then
    clr 8 && printf "${blue}Write The Personalites You Want (EX: 'sweet, really funny and a bit sarcastic'):\n" && stty echo && read -e -p "${green}> ${normal}" P && stty -echo
  elif [ "$C" = 6 ]; then
    clr 8
    personality
  else
    printf "${red}Invalid Input! Press Enter To Try Again" && read && printf "\033[2K" && clr 8
    personality_2
  fi
  if [ -f "/home/$user/.config/glados" ]; then
    $P > /home/$user/.config/glados/settings-p.txt
  else
    touch /home/$user/.config/glados/settings.txt
  fi

  if [ ! "$C" = 5 ]; then
    printf \\33\[\?1047l
    tput rc
    printf "\n${green}Successfully Set Personality!\n"
		printf "${normal}"
		stty echo
		exit
  else
    printf \\33\[\?1047l
    tput rc
    printf "\n${green}Successfully Set Personality!\n"
    printf "${normal}"
		stty echo
		exit
  fi
}

tput sc
printf \\33\[\?1047h
clear
main