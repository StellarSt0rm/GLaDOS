#!/bin/bash

blue=$(tput setaf 4)
yellow=$(tput setaf 11)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)
magneta=$(tput setaf 5)

stty -echo
printf "\n"

#Check If GLaDOS Is Already Installed
if [[ $(command -v glados) ]]; then
	printf "${red}GLaDOS Is Already Installed, If You Want To Update Glados:\n'glados -u' (SUDO Is Nedded For Global Installs)\n"
	stty echo
	exit
fi

#Check Language
if [ $(locale | grep "LANG=en_US.UTF-8") ]; then
	Downloads_Folder="Downloads"
elif [ $(locale | grep "LANG=ca_ES.UTF-8") ]; then
	Downloads_Folder="Baixades"
else
	mkdir $HOME/"TMP_DELETE-ME"
	Downloads_Folder="TMP_DELETE-ME"
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

#Check Os
if ! [ -x "$(command -v lsb_release)" ]; then
  printf "${red}'lsb_release' Command Not Found. ${yellow}Exiting...${normal}"
	stty echo
  exit
fi

OS_NAME=$(lsb_release -si)
OS_ID=$(lsb_release -sr)

if [[ "$OS_NAME" == "Fedora" ]]; then
  PACKAGE_MANAGER="apt"
elif [[ "$OS_NAME" =~ "Ubuntu"|"Debian" ]]; then
  PACKAGE_MANAGER="apt"
else
  printf "${red}Unsupported OS: ${blue}$OS_NAME - $OS_ID\nIf You Want Your OS To Be Supported, Contact Me Trough\n${yellow}GitHub:${normal} 'GamerBlue208'   ${yellow}Email:${normal} 'gamerblue208+dev@gmail.com'\n${blue}Provide: OS, Package Manager; And You Can Include Anything Else You Want To Tell Me,\nLike Any New Feature You'd Like!\n"
	stty echo
  exit
fi

#Check If Dependences
if [[ ! $(command -v git) ]]; then
  printf "${yellow}Installing git\n" && sudo $PACKAGE_MANAGER install git -y >/dev/null 2>&1 && printf "${green}  Done!"
else
  printf "${green}Git is installed!\n"
fi

if [[ ! $(command -v go) ]]; then
	if [ "$PACKAGE_MANAGER" = "apt" ]; then
  	printf "${yellow}Installing go..." && sudo snap install go --classic >/dev/null 2>&1 && printf "${green}  Done!\n"
	else
		printf "${yellow}Installing go..." && sudo dnf install go -y >/dev/null 2>&1 && printf "${green}  Done!\n"
	fi
else
  printf "Go is installed!\n"
fi
printf "${magneta}----------------------------------\n\n"

#Cleanup funcions
function cleanup {
	cd $directory_path
	rm -r -f ./tgpt 2>/dev/null
	rm -r -f ./glados 2>/dev/null
	cd
	printf "${blue}Cleaning Up...  ${green}Done!\n"
}

function cleanup_sig {
	cd $directory_path
	rm -r -f ./tgpt 2>/dev/null
	rm -r -f ./glados 2>/dev/null
	cd
	stty echo
	printf "\n${magneta}----------------------------------\n\n${blue}User Ordered SIGINT. ${yellow}Cleaning Up...\n"
	exit
}

function cleanup_fail {
	cd $directory_path
	rm -r -f ./tgpt 2>/dev/null
	rm -r -f ./glados 2>/dev/null
	cd
	stty echo
	printf "\n${magneta}----------------------------------\n\n${red}Installation Failed! ${yellow}Cleaning Up...\n"
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

#Prepare
if [ "$sudo" = true ]; then
	directory_path="$HOME/$Downloads_Folder"
else
	directory_path="$HOME/$Downloads_Folder"
fi
cd $directory_path
trap cleanup_sig SIGINT
printf "${yellow}Getting Latest Release Of TGPT..."
if git clone -q https://github.com/aandrew-me/tgpt $directory_path/tgpt 2>/dev/null; then
	printf "\033[2K\r${green}Successfully Got Lastest Release Of TGPT!\n"
else
	printf "\033[2K\r${red}Failed To Get Lastest Release Of TGPT!\n"
	cleanup_fail
fi
stty echo
printf "${yellow}Getting Lastest Release Of GLaDOS..."
if git clone -q https://github.com/GamerBlue208/GLaDOS $directory_path/glados 2>/dev/null; then
	printf "\033[2K\r${green}Successfully Got Lastest Release Of GLaDOS!\n"
else
	printf "\\033[2K\r${red}Failed To Get Lastest Release Of GLaDOS!\n"
	cleanup_fail
fi
stty -echo
cd ./tgpt
printf "${magneta}----------------------------------\n\n"

#Cut Parts
printf "${yellow}Modifying TGPT..."
sed -i 's/"tgpt", //g' "./main.go" 2>/dev/null
sed -i '/\/\/ Print the Question/,+8d' "./functions.go" 2>/dev/null
printf "\033[2K\r${green}Successfully Modified TGPT!\n"

#Build
printf "${yellow}Building TGPT..."
if go build -ldflags="-s -w" -o $install_location/gpt 2>/dev/null; then 
	printf "\033[2K\r${green}Successfully Built TGPT!\n"
else
	printf "\033[2K\r${red}Failed To Build TGPT!\n"
	mv "$install_location/gpt-old" "/$install_location/gpt" 2>/dev/null
	cleanup_fail
fi
cd .. && cd ./glados && chmod +x ./glados && mv ./glados $install_location 2>/dev/null
printf "${magneta}----------------------------------\n\n"

#Change perms
if [ "$type" = "Local" ]; then
	sudo chown $user $install_location/glados && chown $user $install_location/gpt && chown $user $install_location/gpt-old 2>/dev/null
fi

#Clean Up
if [ $Downloads_Folder="TMP_DELETE-ME" ]; then
	cd
	rm -rf "TMP_DELETE-ME"
fi
printf "${green}Installation Succeded!\n"
cleanup
printf "${blue}\nExiting...\n"
stty echo
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$HOME/.local/bin"
exit
