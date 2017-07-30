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
n


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
	curl -o $cache_dir/UO.exe http://www.13thrones.com/files/UO.exe
fi

if [ -f "$cache_dir/UOSteam.exe" ]
then
        echo "UOSteam.exe Found!"
else
	curl -o $cache_dir/UOSteam.exe http://uos-update.github.io/UOS_Latest.exe
fi

if [ -f "$cache_dir/ReqAutoPatcher_Setup.exe" ]
then
        echo "ReqAutoPatcher_Setup.exe Found!"
else
	curl -o $cache_dir/ReqAutoPatcher_Setup.exe http://www.13thrones.com/files/ReqAutoPatcher_Setup.exe
fi
}

winetricks_set() {
#Setup winetricks from official source, as this is better updated than most distro versions, and installs required dotnet45 library for launcher.
clear
echo "Generating wine prefix."
WINEPREFIX=$install_dir WINEARCH=win32 $cache_dir/winetricks settings list >& /dev/null

if [ -f "$cache_dir/winetricks" ]
then
	echo "Found winetricks"
else
	curl -o $cache_dir/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x $cache_dir/winetricks
fi
clear
echo "It may take a while to install dotnet libraries"
WINEPREFIX=$install_dir $cache_dir/winetricks -q dotnet45 msxml6 > /dev/null
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
echo "Now installing Requiem Patcher"
wine "$cache_dir/ReqAutoPatcher_Setup.exe" > /dev/null
read -p "Press enter once patcher is completed..."
}

post_install () {
$cache_dir/winetricks vd=off > /dev/null
$cache_dir/winetricks windowmanagerdecorated=n > /dev/null

/bin/cat <<EOM > $HOME/.RequiemUO/uolaunch
#!/bin/bash
cd "$HOME/.RequiemUO/drive_c/Program Files/UOS"
WINEPREFIX="$HOME/.RequiemUO" wine UOS.exe
EOM

chmod +x $HOME/.RequiemUO/uolaunch

}
# This starts the main body of the script.
# I placed everything in functions incase we want to skip steps later on.
clear
echo "You must Understand the following rules:"
echo "1. This is an EXPERIMENTAL script"
echo "2. Do not post issues with the script to development team"
echo "3. This is not a native souliton, it does require wine"
echo "4. This is not a stable solution."
read -p "Press enter when you're ready to proceed..."
clear
dir_setup
dl_files
winetricks_set
pre_install
install_UO
post_install
