# Requiem UO Linux Helper Script

This script is designed to use wine and a wonderful helper script winetricks to automate an installation of the Ultima Online Client and Reqiuem UO Patcher to play on the [Reqiuem Shard](http://www.13thrones.com/wordpress/).

It works by using wine's [prefix](https://wiki.winehq.org/FAQ#Can_I_store_the_virtual_Windows_installation_somewhere_other_than_.7E.2F.wine.3F) system. The script will isolate RequiemUO in it's own prefix, and make changes to it as required. This allows the script to fully control wine's settings and implement fixes without breaking user's other wine installations. It's core functionality of other projects like [PlayOnLinux](https://www.playonlinux.com/en/).


It's designed by AzureX and is **--EXPERIMENTAL--**. Although it is offered by Requiem UO staff, we ask that you report all issues via [git-hub's issue tracker for the project](https://github.com/AzureX1212/RequiemUOLinuxScript/issues). Do not use the ReqiuemUO Trello or any other issue tracker.

## Requirements:

The script requires little requirements to run, however users will need **wine** (or wine-staging but is not recommended),**curl**, **winbind**, and **cabextract** to install Ultima Online.

_Adittional: Package names may not match, use your package managers search function!_
_Additional Additional: cabextract and/or winbind may be a reqiurement of wine in your distribution!_

* Ubuntu/Debian: `sudo apt-get install wine-stable curl cabextract winbind`

* Fedora: `sudo dnf install wine curl cabextract winbind`

* OpenSUSE: `sudo zypper in wine curl cabextract winbind`

* Arch Linux (really?): `sudo pacman -S wine curl cabextract winbind`

* Gentoo: `Good luck!`

One important requirement is that **wine needs to be at 1.7 or above.** This means those on Ubuntu 16.04 or older releases may need to seek an alternative source for wine. One can check their version by running the following:

      wine --version

All other requirements are satisfied by the script automatically.

## Installation:

1. The script itself requires no installation. Simply download the script using this bit of code in your terminal:

    `curl -o requiem-install.sh  https://raw.githubusercontent.com/AzureX1212/RequiemUOLinuxScript/master/requiem-install.sh`

    This will download the script in your current folder.

2. Make the script executable by running:

    `chmod +x requiem-install.sh`

3. Then finally execute the script using:

    `./requiem-install.sh`

4. Follow through all the prompts.

## Usage
* Install UO:

    `./requiem-install.sh`

* Uninstall UO:

    `./requiem-install.sh -r`

* To update the script:

    `./requiem-install.sh -u`

* To get a help prompt:

    `./requiem-install.sh -h`

* Launch UO:

    `uolaunch`

* Patch UO:

    `uopatch`

## Troubleshooting

If for any reason you have an issue during the installation, or the script/terminal has crashed during install, simply use the scripts switch **-r** to remove the installation and rerun the script.

It's also a good idea to **update** the script using **-u**. Many bugs may have been fixed in newer versions of the script!

**Verify** that you have **wine >= 1.7**.

## Known issues
- [ ] The Requiem Launcher does crash occasionally, behavior is the same on windows, so not a wine issue. May need to run `uopatch` after install to correct.

- [x] Gecko may crash and cause the Requiem Launcher to go black, simply move your mouse around the launcher to bring items back. (Workaround but no fix available.)
