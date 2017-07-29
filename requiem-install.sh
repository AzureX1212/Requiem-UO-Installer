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
#
#

# Declaring basic variables I'll need to run the script
install_dir=$HOME/.RequiemUO
cache_dir=$HOME/.cache/RequiemUO
# and lets set the prefix and arch variable for the entire script
export WINEPREFIX=$HOME/.RequiemUO
export WINEARCH=win32

wine_setup() {
echo "Installing to $install_dir"
echo "We will install into $WINEPREFIX"
}

dir_setup() {
#This will initialize our directory for storing the downloaded files for install, we keep it to speed up the script for reinstalls
mkdir -p $cache_dir
}

dl_files() {
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

winetricks() {
#Setup winetricks from official source, as this is better updated than most distro versions, and installs required dotnet45 library for launcher.
if [ -f "$cache_dir/winetricks" ]
then
	echo "Oh hey look! I found winetricks!"
else
	curl -o $cache_dir/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x $cache_dir/winetricks
fi
$cache_dir/winetricks -q dotnet45 > /dev/null
$cache_dir/winetricks windowmanagerdecorated=n > /dev/null
$cache_dir/winetricks win7 > /dev/null #sets our wine version over to windows 7 for the launcher
}

install_UO () {
wine "$cache_dir/UO.exe"
wine "$cache_dir/UOSteam.exe"
}

patch_UO () {
wine "$cache_dir/ReqAutoPatcher_Setup.exe" > /dev/null
read -p "Press enter once patcher is completed..."
}
final_install () {

/bin/cat <<EOM > $HOME/.RequiemUO/uolaunch
#!/bin/bash
cd "$HOME/.RequiemUO/drive_c/Program Files/UOS"
WINEPREFIX="$HOME/.RequiemUO" wine UOS.exe
EOM

chmod +x $HOME/.RequiemUO/uolaunch

/bin/cat <<EOM > $HOME/.local/share/applications/uolaunch.desktop
[Desktop Entry]
Encoding=UTF-8
Name="Launch UO"
Exec="bash $HOME/.RequiemUO/uolaunch"
Type=Application
Terminal=false
Comment="Launch UOSteam to play Requiem UO"
Categories=Games
EOM

/bin/cat <<EOM > $HOME/.local/share/applications/req_patcher.desktop
[Desktop Entry]
Encoding=UTF-8
Name="Launch Requiem Patcher"
Exec="WINEPREFIX=$HOME/.RequiemUO wine $HOME/.RequiemUO/drive_c/Program Files/Requiem\ AutoPatcher"
Type=Application
Terminal=false
Comment="Launch UOSteam to play Requiem UO"
Categories=Games
EOM
}
clear
echo "You must Understand the following rules:"
echo "1. This is an EXPERIMENTAL script"
echo "2. Do not post issues with the script to development team"
echo "3. This is not a native souliton, it does require wine"
echo "4. This is not a stable solution."
read -p "Press enter when you're ready to proceed..."
clear
wine_setup
dir_setup
dl_files
winetricks
install_UO
patch_UO
final_install
