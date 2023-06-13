#!/bin/bash

blue=$(tput setaf 4)
yellow=$(tput setaf 11)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)
magneta=$(tput setaf 5)

if [ ! $(whoami) = "overlord" ]; then
	N="\n"
fi

stty -echo
printf "\n"

#Check If GLaDOS Is Already Installed
if [[ $(command -v glados) ]]; then
	printf "${red}GLaDOS Is Already Installed, If You Want To Update Glados:\n'glados -u' (SUDO Is Nedded For Global Installs)\n$N"
	stty echo
	exit
fi

#Check If Sudo
if [[ $EUID -ne 0 ]]; then
  printf "${red}Sudo is needed to install GLaDOS (Later you can select Local mode to update without sudo)\n"
  stty echo
  exit
else
  sudo=true
  if id "$1" >/dev/null 2>&1; then
    user=$1
  else
    user=$SUDO_USER
  fi
fi

#Cleanup funcions
function cleanup {
	cd
	rm -rf "$HOME/$Downloads_Folder"
	printf "${blue}Cleaning Up...  ${green}Done!\n"
}

function cleanup_sig {
	cd $directory_path
	rm -r -f ./tgpt 2>/dev/null
	rm -r -f ./glados 2>/dev/null
	cd
	stty echo
	printf "\n${magneta}----------------------------------\n\n${blue}User Ordered SIGINT. ${yellow}Cleaning Up...\n$N"
	exit
}

function cleanup_fail {
	cd $directory_path
	rm -r -f ./tgpt 2>/dev/null
	rm -r -f ./glados 2>/dev/null
	cd
	stty echo
	printf "\n${magneta}----------------------------------\n\n${red}Installation Failed! ${yellow}Cleaning Up...\n$N"
	exit
}

#Give Installation Type Chance
printf "${blue}What Installation Type Do You Want:\n${yellow}1) Global Install (Anyone On The System Can Access Glados, But Needs SUDO To Be Updated)\n2) Local Install (The Program Will Be On Your Local Bin (You Can Change Destination Bin))\n"
stty echo
printf "${normal}Type number here: " && read C && printf "\033[1A\033[2K\033[1A\033[2K\033[1A\033[2K\033[1A\033[2K"
stty -echo
if [ "$C" = "1" ]; then
  install_location=/usr/local/bin
  type=Global
elif [ "$C" = "2" ]; then
  if id "$1" >/dev/null 2>&1; then
    install_location=/home/$1/.local/bin
  else
    install_location=$HOME/.local/bin
  fi
  type=Local
else
  printf "\n${red}Invalid Input! ${yellow}Terminating Install.\n"
  cleanup_fail
fi
printf "${blue}Selected installation type: $type\n"
printf "${magneta}----------------------------------\n\n"

#Prepare & Download
trap cleanup_sig SIGINT
printf "${yellow}Getting Latest Release Of GLaDOS-GPT...\n"
if tput setaf 4 && curl -SL --progress-bar "https://github.com/GamerBlue208/GLaDOS/releases/latest/download/gpt-glados" -o $install_location/gpt-glados && sleep 2; then
	printf "\033[1A\033[2K\033[1A\033[2K\r${green}Successfully Got Lastest Release Of GLaDOS-GPT!\n"
else
	printf "\033[1A\033[2K\033[1A\033[2K\r${red}Failed To Get Lastest Release Of GLaDOS-GPT!\n"
	cleanup_fail
fi
stty echo
printf "${yellow}Getting Lastest Release Of GLaDOS...\n"
if tput setaf 4 && curl -SL --progress-bar "https://github.com/GamerBlue208/GLaDOS/releases/latest/download/glados" -o $install_location/glados && sleep 2; then
	printf "\033[1A\033[2K\033[1A\033[2K\r${green}Successfully Got Lastest Release Of GLaDOS!\n"
else
	printf "\033[1A\033[2K\033[1A\033[2K\r${red}Failed To Get Lastest Release Of GLaDOS!\n"
	cleanup_fail
fi
stty -echo
chmod +x $install_location/glados && chmod +x $install_location/gpt-glados 2>/dev/null
printf "${magneta}----------------------------------\n\n"

#Change perms
if [ "$type" = "Local" ]; then
	sudo chown $user $install_location/glados && chown $user $install_location/gpt-glados && chown $user $install_location/gpt-old 2>/dev/null
fi

#Clean Up
printf "${green}Installation Succeded!\n"
printf "${blue}\nExiting...\n$N"
stty echo
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$HOME/.local/bin"
exit
