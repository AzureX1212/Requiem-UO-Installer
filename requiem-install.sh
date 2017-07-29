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
#
# REPORT BUGS VIA THIS GITHUB PAGE:
#
#

# Declaring basic variables I'll need to run the script

install_dir=$HOME/.RequiemUO
cache_dir=$HOME/.cache/RequiemUO

wine_setup() {
echo "Installing to $install_dir"
export WINEPREFIX=$HOME/.RequiemUO
export WINEARCH=win32

zenity --info --text "Select Windows 2003 at the bottom of the following dialog, then apply"

winecfg
}

dir_setup() {
mkdir -p $cache_dir
}

dl_files() {

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
if [ -f "$cache_dir/winetricks" ]
then
	echo "Oh hey look! I found winetricks!"
else
	curl -o $cache_dir/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
	chmod +x $cache_dir/winetricks
fi

mkdir -p $HOME/.RequiemUO/share/wine/gecko

curl -o $HOME/.RequiemUO/share/wine/gecko/ "http://dl.winehq.org/wine/wine-gecko/2.40/wine_gecko-2.40-x86.msi"

WINEPREFIX=$HOME/.RequiemUO $cache_dir/winetricks -q dotnet45 
}

#copy_files() {
#mkdir -p "$HOME/.RequiemUO/drive_c/Program Files/RequiemUO"
#cp -a $cache_dir "$HOME/.RequiemUO/drive_c/Program Files/"
#}

install_UO () {
zenity --info --text "We are now going to install UO, hold on to your butts!"
WINEPREFIX=$HOME/.RequiemUO wine "$cache_dir/UO.exe"
WINEPREFIX=$HOME/.RequiemUO wine "$cache_dir/UOSteam.exe"
zenity --info --text "Please set your windows version to Windows 7 in the next prompt, then apply."
winecfg
}

patch_UO () {
zenity --info --text "Now we are going to install and run the patcher! Once it is installed leave it to luanch it and setup the patcher as per the website. Once you have patched the game close the patcher"
WINEPREFIX=$HOME/.RequiemUO wine "$cache_dir/ReqAutoPatcher_Setup.exe"
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
zenity --info --text "Good News! We are done! You should now be able to launch and patch UO from your applications menu!"
} 

wine_setup
dir_setup
dl_files
winetricks
install_UO
patch_UO
final_install
