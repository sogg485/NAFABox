################################################
# Under GPL license
#     https://www.gnu.org/licenses/gpl.html
# Authors:	Sébasien Durand
# 			
# On Sept 05 2017
# V0.1
################################################
#!/bin/bash -i
######
# Recherche du répertoire ConfigTinker
######
if [ -z "$nafabox_path" ]
then
	echo "Run first Pre_Install.sh and reload Terminal"
	exit
fi
dirinstall=$nafabox_path

######
# detect processeur
######
source $dirinstall/proctype.sh

######
# detect language
######
source $dirinstall/detect_language.sh

figlet -k Install OnStep
echo "================================================="
echo "================================================="

######
# installation des dépendances
######
sudo apt-get install libusb-dev git

if $french
then
	dial[0]="Installation/Mise à jour des logiciels"
	dial[1]="Choisir le(s) logiciel(s) à installer"
	choice[0]="Installation OnStep (git et teensy)"
	choice[1]="Installation Arduino IDE (avec Teensyduino)"
	choice[2]="Installation OnStep Generator"
else
	dial[0]="Install/Update of software"
	dial[1]="Choose software(s) to install"
	choice[0]="Install OnStep (git and teensy)"
	choice[1]="Install Arduino IDE (with Teensyduino)"
	choice[2]="Install OnStep Generator"
fi

st=(true false false)

if chose=`yad --width=400 \
	--center \
	--form \
	--title="${dial[0]}" \
	--text="${dial[1]}" \
	--field=":LBL" \
	--field="${choice[0]}:CHK" \
	--field="${choice[1]}:CHK" \
	--field="${choice[2]}:CHK" \
	"" "${st[0]}" "${st[1]}" "${st[2]}"`
then
	onstep_c=$(echo "$chose" | cut -d "|" -f2)
	ide_arduino=$(echo "$chose" | cut -d "|" -f3)
	gen=$(echo "$chose" | cut -d "|" -f4)
else
	echo "cancel"
fi

# test version
if [[ $proc == "_amd64" ]]
then
	type="linux64"
elif [[ $proc == "_armhf" ]]
then
	type="linuxarm"
elif [[ $proc == "_x86" ]]
then
	type="linux32"
elif [[ $proc == "_aarch64" ]]
then
	type="linuxaarch64"
else
	type="no"
fi



if [[ $onstep_c == "TRUE" ]]
then
	######
	# install rules file
	######
	wget https://www.pjrc.com/teensy/49-teensy.rules -P /tmp/
	sudo cp /tmp/49-teensy.rules /etc/udev/rules.d/

	######
	# install teensy loader
	######

	if [[ $type == "no" ]]
	then	
		echo "teensy loader not support this platform"
	elif [[ $type == "linuxaarch64" ]]
	then
		echo "teensy loader not support this platform"
	else
		if [[ $type == "linuxarm" ]]
		then
			type="raspberrypi"
		fi
		# telechargeemnt de l'installateur
		file=teensy_$type.tar.gz
		wget https://www.pjrc.com/teensy/$file -P /tmp/
		mkdir -p /home/$USER/Teensy_loader
		cd /home/$USER/Teensy_loader
		tar -xzf /tmp/$file
		
	fi
	
	# telechargeemnt de onstep
	cd /home/$USER/
	if [ -d "/home/${USER}/Onstep/" ]
	then
		# mise a jour
		echo "update onstep git"
		cd /home/$USER/OnStep/
		git pull
	else
		# installation
		echo "install onstep git"
		git clone https://github.com/hjd1964/OnStep.git

	fi

	cd /home/$USER/OnStep/
	# choix de version de OnStep
	if ret=`yad --width 400 \
			--center \
			--entry \
			--title "Onstep branch" \
			--image=switch_language \
			--text "Chose install OnStep version" \
			--button="gtk-ok:1" \
			--button="gtk-close:0" \
			--entry-text "Beta" "Alpha" "stable"`
	then
		if [[ $ret == "Beta" ]]
		then
			git checkout Beta
		elif [[ $ret == "Alpha" ]]
		then
			git checkout Alpha
		else
			git checkout Stable
		fi
	else
		echo "OnStep Beta is install by default"
	fi
fi

# change if need
if [[ $type == "raspberrypi" ]]
then
	type="linuxarm"
fi

arduino_v="1.8.7"
teensduino_v="144"

if [[ $ide_arduino == "TRUE" ]]
then
	# Installation de l'IDE Arduino en version PPA
	if [[ $type == "linuxaarch64" ]]
	then
		lien="https://www.pjrc.com/teensy/td_144"
	elif [[ $type != "no" ]]
		lien="https://downloads.arduino.cc/"
	fi

	if [[ $type != "no" ]]
		wget $lien/arduino-$arduino_v-linuxaarch64.tar.xz -P /tmp/
		cd /home/$USER
		tar -xf /tmp/arduino-$arduino_v-linuxaarch64.tar.xz
		/home/$USER/arduino-$arduino_v/install.sh

		echo "Arduino folder is : /home/$USER/arduino-$arduino_v/"

	else
		# install ubuntu-make
		sudo add-apt-repository ppa:lyzardking/ubuntu-make -y
		sudo apt-get update
		sudo apt-get -y install ubuntu-make

		# install arduino IDE
		umake ide arduino

		$dirinstall/install_shortcut.sh arduino
		echo "Arduino folder is : ~/.local/share/umake/ide/arduino"

	sudo usermod -a -G dialout $USER

	# install teensduino
	file="TeensyduinoInstall.$type"

	wget https://www.pjrc.com/teensy/td_144/$file -P /tmp/
	chmod +x /tmp/TeensyduinoInstall.$type

	# run install process
	/tmp/TeensyduinoInstall.$type

fi
	
if [[ $ide_arduino == "TRUE" ]]
then
	echo "TO DO"
fi


