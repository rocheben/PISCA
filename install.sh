#!/bin/bash

welcome="\nPISCA v0.9 Installer\n"
plugin_name="PISCA.PISCALoader.jar"
usage="\nUsage: $0 beast_directory\nPlease, indicate the root directory of the BEAST 1.8.X software in which PISCA will be installed\n"
source_error="This script has been intended to install the compiled version of PISCA, while it seems that you have downloaded the source code. Please, find the last release of PISCA at https://github.com/adamallo/PISCA/releases/latest\n"
wrong_folder_error="\nThe directory $1 does not look like the root directory of a BEAST 1.8.X instalation"
permission_error="\nYou do not have writting permission in the BEAST directory. Please, execute this script with sudo or change the write permissions of $1 and subdirectories\n"
successfull_script="\nPISCA has been successfully copied in the plugin directory\n"
error_script="\nError copying PISCA to the plugin directory\n"
edited_error="\nYour BEAST program had already been modified for the execution of plugins. This script is not modifying it and the installation of PISCA may, or may have not been successful\n"
noplist="\nNo Info.plist detected. If your BEAST program contains a graphical interface version, it will not have access to the plugin\n"
noStub="\nInfo.plist detected, but Stub not found. This is a problem of this script. Contact the author\n"
done="\nPISCA has been successfully installed. Please, read the README.md file before starting using it. Remember that so far we do not provide Beauti capabilities\n"

echo -e $welcome

if [[ ! -f dist/$plugin_name ]]
then
	echo -e $source_error
	exit 1
fi

if [[ $# -ne 1 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]
then
	echo -e $usage
	exit 1

elif [[ ! -d $1 ]] || [[ ! -f $1/bin/beast ]] || [ ! -d $1/lib ]
then
	echo -e $wrong_folder_error 
	echo -e $usage
	exit 1

elif [[ ! -w $1/lib ]] || [[ ! -w $1/bin ]]
then
	echo -e $permission_error
	echo -e $usage
	exit 1
fi

beast_root=$1

mkdir $beast_root/lib/plugins
cp dist/$plugin_name $beast_root/lib/plugins

if [[ -f $beast_root/lib/plugins/$plugin_name ]]
then
	echo -e $successfull_script
else
	echo -e $error_script
	exit 1
fi


if [[ $(grep -c '\-Dbeast.plugins.dir=${BEAST_LIB}/plugins' $beast_root/bin/beast) -ne 0 ]]
then
	echo -e $edited_error 
else
	cp $beast_root/bin/beast $beast_root/bin/beast_bkp
	sed 's/-cp/-Dbeast.plugins.dir=${BEAST_LIB}\/plugins -cp/g' $beast_root/bin/beast_bkp > $beast_root/bin/beast
	echo "##Modified by PISCA installer. If you have any problems running BEAST, rename or delete this file and rename the file beast_bkp to beast" >> $beast_root/bin/beast
	echo "##Backup generated by the instalation script of PISCA" >> $beast_root/bin/beast_bkp
	echo -e $done
fi

appdir=$(find $beast_root -name "BEAST*.app")

if [[ -f "$appdir/Contents/Info.plist" ]]
then
	if [[ $(grep -c 'beast.plugins.dir' "$appdir/Contents/Info.plist") != 0 ]]
	then
		echo -e $edited_error
	else
		backlashed_root=$(echo $beast_root | sed 's./.\\/.g')
		cp "$appdir/Contents/Info.plist" "$appdir/Contents/Info.plist_bkp"
		perl -0777 -pne "s/\<key\>java.library.path\<\/key\>/\<key\>beast.plugins.dir\<\/key\>\n        \<string\>$backlashed_root\/lib\/plugins\<\/string\>\n        <key\>java.library.path\<\/key\>/gsm" "$appdir/Contents/Info.plist_bkp" > "$appdir/Contents/Info.plist"
		#perl -0777 -pne 's/\<key\>java.library.path\<\/key\>\n\s*\<string\>\$JAVAROOT\:\/usr\/local\/lib\<\/string\>/\<key\>beast.plugins.dir\<\/key\>\n        \<string\>\$APP_PACKAGE\/..\/lib\/plugins\<\/string\>\n        \<\!\-\-\<key\>java.library.path\<\/key\>\n        \<string\>\$JAVAROOT\:\/usr\/local\/lib\<\/string\>--\>\n/gsm' "$appdir/Contents/Info.plist_bkp" > "$appdir/Contents/Info.plist"
		echo "<!--Modified by PISCA installer. If you have any problems running BEAST, rename or delete this file and rename the file Info.plist_bkp to Info.plist-->" >> "$appdir/Contents/Info.plist"
		echo "<!--Backup generated by the instalation script of PISCA-->" >> "$appdir/Contents/Info.plist_bkp"

#		if [[ -f "$appdir/Contents/MacOs/universalJavaApplicationStub" ]]
#		then
#			if [[ $( grep -c 'eval "echo ${JVMOptions}"\n# read StartOnMainThread' "$appdir/Contents/MacOs/universalJavaApplicationStub") != 0 ]]
#			then
#				echo -e $edited_error
#			else
#				cp "$appdir/Contents/MacOs/universalJavaApplicationStub" "$appdir/Contents/MacOs/universalJavaApplicationStub_bkp"
#				perl -0777 -pne 's/# read StartOnMainThread/JVMOptions=`eval "echo \${JVMOptions}"`\n\t# read StartOnMainThread/gsm' "$appdir/Contents/MacOs/universalJavaApplicationStub_bkp" | perl -0777 -pne 's/\$\{JVMOptions\:\+\$JVMOptions \}/\"\$\{JVMOptions\:\+\$JVMOptions \}\"/gsm' > "$appdir/Contents/MacOs/universalJavaApplicationStub"
#				echo "##Modified by PISCA installer. If you have any problems running BEAST, rename or delete this file and rename the file Info.plist_bkp to Info.plist" >> "$appdir/Contents/MacOs/universalJavaApplicationStub"
#				echo "##Backup generated by the instalation script of PISCA" >> "$appdir/Contents/MacOs/universalJavaApplicationStub_bkp"
#			fi
#		else
#			echo -e $noStub
#			exit 1
#		fi
	fi
else
	echo -e $noplist
fi



exit 0
