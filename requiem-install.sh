#!/bin/bash
#---------------------------------------
#      RequiemUO Linux Installer
# This is a test script to install RequiemUO using Wine and
# and some of it's extra libraries. The goal is to make an
# easy method of installation, thats also not very complex to
# maintain.
#
# This is a side project of AzureX and thus is not *officially* supported
# by RequiemUO staff.
#
# DO NOT REPORT ANY ISSUES TO ANY STAFF MEMBER.
# YOUR ANIMUS == 0.
#
# REPORT BUGS VIA THIS GITHUB PAGE:
# https://github.com/AzureX1212/RequiemUOLinuxScript/issues
#
# That is all.

# Declaring basic variables I'll need to run the script
install_dir=$HOME/.RequiemUO
cache_dir=$HOME/.cache/RequiemUO
contentUrl="http://13thrones.com/patches/MUL/Updates.xml"
update_dir="$install_dir/drive_c/Program Files/Electronic Arts/Ultima Online Classic/"
dl_dir=$cache_dir/Downloads
# and lets set the prefix and arch variable for the entire script
export WINEPREFIX=$HOME/.RequiemUO
export WINEARCH=win32
export WINEDEBUG=-all # To get rid of error messages
bold=$(tput bold)
normal=$(tput sgr0)


dir_setup() {
#This will initialize our directory for storing the downloaded files for install, we keep it to speed up the script for reinstalls
mkdir -p $cache_dir
}

dl_files () {
#Check and download all our our missing files from verified sources. These may be changed later on if we need new sources.
if [ -f "$cache_dir/UO.exe" ]
then
	echo "UO.exe Found!"
else
	clear
	echo "Downloading the client."
	curl -o $cache_dir/UO.exe http://www.13thrones.com/files/UO.exe
fi

if [ -f "$cache_dir/UOSteam.exe" ]
then
    echo "UOSteam.exe Found!"
else
	clear
	echo "Downloading UOSteam."
	curl -o $cache_dir/UOSteam.exe http://uos-update.github.io/UOS_Latest.exe
fi

if [ -f "$cache_dir/ReqAutoPatcher_Setup.exe" ]
then
    echo "ReqAutoPatcher_Setup.exe Found!"
else
	clear
	echo "Downloading the patcher."
	curl -o $cache_dir/ReqAutoPatcher_Setup.exe http://www.13thrones.com/files/ReqAutoPatcher_Setup.exe
fi
}

winetricks_set() {
#Setup winetricks from official source, as this is better updated than most distro versions, and installs required dotnet45 library for launcher.
clear

if [ -f "$cache_dir/winetricks" ]
then
	echo "Found winetricks"
else
	curl -o $cache_dir/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x $cache_dir/winetricks
fi
clear
echo "Generating wine prefix."
WINEPREFIX=$install_dir WINEARCH=win32 $cache_dir/winetricks settings list > /dev/null # sets up the prefix which will fix a bug later on
clear
#echo "It may take a while to install dotnet libraries"
#echo ""
#echo "Do not close the terminal, the output is suppressed unless an error occurs!"
#WINEPREFIX=$install_dir $cache_dir/winetricks -q dotnet45 msxml6 > /dev/null
#WINEPREFIX=$install_dir $cache_dir/winetricks windowmanagerdecorated=n > /dev/null
#WINEPREFIX=$install_dir $cache_dir/winetricks win7 > /dev/null #sets our wine version over to windows 7 for the launcher
#WINEPREFIX=$install_dir $cache_dir/winetricks vd=800x600
}

pre_install () {
clear
echo "We are going to change some settings before installing... "
$cache_dir/winetricks vd=800x600 > /dev/null
$cache_dir/winetricks win7 > /dev/null #sets our wine version over to windows 7 for the launcher
}

install_UO () {
clear
echo "Installing UO Classic Client"
WINEPREFIX=$install_dir $cache_dir/winetricks vd=800x600
wine "$cache_dir/UO.exe"
clear
echo "Now UOSteam"
wine "$cache_dir/UOSteam.exe"
clear
}

patch_UO () {
clear
filenamesList=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/DisplayName/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')

fileDl=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/FileName/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')

hashList=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/Hash/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')

urlList=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/URL/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')

fileCount=1

echo "Downloading update manifest..."

curl -s -o "$cache_dir/Updates.xml" "$contentUrl"
    
mkdir -p $dl_dir

declare -a Files
declare -a Hash
declare -a Url
declare -a Dl


for file in $filenamesList 
do
	Files[$fileCount]=$file
    fileCount=$(($fileCount+1))
done

fileCount=1

for file in $hashList
do 
    Hash[$fileCount]=$file
    fileCount=$(($fileCount+1))
done

fileCount=1

for file in $urlList
do
    Url[$fileCount]=$file
    fileCount=$(($fileCount+1))
done

fileCount=1

for file in $fileDl
do
	Dl[$fileCount]=$file
    fileCount=$(($fileCount+1))
done

lengthFiles=${#Files[@]}
lengthHash=${#Hash[@]}

if [ $lengthFiles = $lengthHash ]
    then
    echo $lengthFiles "files to check."
    fileCount=1
    else
    echo "Something is wrong."
    exit
fi

if hash md5 2>/dev/null
then
    HashCmd="md5 -r"
else
    HashCmd="md5sum"
fi

echo "Checking Files..."

filesBad=0

while (("$fileCount" <= "$lengthFiles")); do
    localHash=$($HashCmd "$update_dir/${Files[$fileCount]}" | awk '{ print $1 }')
    if [ "$localHash" != "${Hash[$fileCount]}" ] 
    then
        echo "Updating" ${Files[$fileCount]}
        curl -o "$dl_dir/${Dl[$fileCount]}" "${Url[$fileCount]}" >/dev/null
        unzip -o -d "$update_dir" "$dl_dir/${Dl[$fileCount]}" >/dev/null
        filesBad=$(($filesBad+1))
    fi
    fileCount=$(($fileCount+1))
done

if (("$filesBad" != 0))
then
    echo $filesBad "out of" $lengthFiles "updated."
else
    echo "All files are already up to date."
fi

rm -rf $dl_dir
clear
}

post_install () {
$cache_dir/winetricks vd=off > /dev/null
$cache_dir/winetricks windowmanagerdecorated=n > /dev/null

mkdir -p $HOME/bin
curl -o $HOME/bin/uolaunch "https://raw.githubusercontent.com/AzureX1212/RequiemUOLinuxScript/master/Extras/uolaunch" > /dev/null
curl -o $HOME/bin/uopatch "https://raw.githubusercontent.com/AzureX1212/RequiemUOLinuxScript/master/Extras/uopatch" > /dev/null
chmod +x $HOME/bin/uolaunch
chmod +x $HOME/bin/uopatch
touch $cache_dir/.installed

}

help_m () {
	echo "Reqiuem UO Linux Helper:"
	echo "	-r	Uninstall UO."
    echo "  -p  Patch UO."
	echo "	-u	Update this script."
	echo "	-h	Show this message."
	echo "	${bold}uolaunch ${normal}from a terminal to launch UO. "
	echo "Or you can use the shortcuts on the desktop, however ${bold}they may not work properly.${normal}"
}

update () {
	clear
	echo "Updating the script!"
	mkdir -p $cache_dir
	curl -o $cache_dir/updater https://raw.githubusercontent.com/AzureX1212/RequiemUOLinuxScript/master/Extras/updater > /dev/null
	chmod +x $cache_dir/updater #make updater executable
	$cache_dir/updater $PWD
	exit 0
}
# This starts the main body of the script.
# I placed everything in functions incase we want to skip steps later on.

while getopts ":ruph" opt; do
  case $opt in
    r)
			echo "Removing $install_dir and $cache_dir"
            rm -rf $install_dir
			rm -rf $cache_dir
			echo "Removing uolaunch and uopatch"
			rm $HOME/bin/uolaunch
			rm $HOME/bin/uopatch
			exit 0
      ;;
		u)
			update
			;;
        p)
            patch_UO
            exit 0
            ;;
		h)
      help_m
		  exit 0
		  ;;
       \?)
		  echo "Invalid option: -$OPTARG" >&2
		  exit 1
		  ;;
  esac
done

clear
echo "You must Understand the following rules:"
echo "1. This is an EXPERIMENTAL script"
echo "2. Do not post issues with this script to the development team"
echo "3. This is not a native souliton, it does require wine"
echo "4. This is not a stable solution."
read -p "Press enter when you're ready to proceed..."
clear
dir_setup
dl_files
winetricks_set
pre_install
install_UO
patch_UO
post_install
clear
help_m
read -p "Press enter to exit..."
