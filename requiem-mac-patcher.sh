#!/bin/bash
# Declaring basic variables I'll need to run the script
cache_dir=$HOME/.cache/RequiemUO
install_dir="/Applications/RequiemUO.app/Contents/Resources"
contentUrl="http://13thrones.com/patches/MUL/Updates.xml"
update_dir="$install_dir/drive_c/Program Files/Electronic Arts/Ultima Online Classic/"
dl_dir=$cache_dir/Downloads

clear
mkdir -p $cache_dir
touch $cache_dir/Updates.xml
echo "Downloading update manifest..."
curl --silent -o $cache_dir/Updates.xml "$contentUrl"   
mkdir -p $dl_dir
declare -a Files
declare -a Hash
declare -a Url
declare -a Dl
filenamesList=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/DisplayName/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')
fileDl=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/FileName/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')
hashList=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/Hash/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')
urlList=$(xmllint --shell $cache_dir/Updates.xml <<< `echo 'cat /Updates/UpdateCollection/UpdateObject/URL/text()'` | sed -e 's/ -------//' -e 's/\/ >//' -e '/^\s*$/d')
fileCount=1
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
        curl --silent -o "$dl_dir/${Dl[$fileCount]}" "${Url[$fileCount]}" >/dev/null
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