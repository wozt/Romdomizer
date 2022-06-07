#/bin/bash
shopt -s extglob globasciiranges
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
#~ WHITE=$(tput setaf 7)
#~ CYAN=$(tput setaf 6)
#~ PURPLE=$(tput setaf 5)
#~ BLUE=$(tput setaf 4)
#~ YELLOW=$(tput setaf 3)
#~ GREEN=$(tput setaf 2)
#~ RED=$(tput setaf 1)
#~ BLACK=$(tput setaf 0)
#~ NC=$(tput sgr0)
#~ PURPLEYELLOW=$(tput setaf 5)$(tput setab 3)
#~ YELLOWPURPLE=$(tput setaf 3)$(tput setab 5)
#~ YELLOWGREEN=$(tput setaf 3)$(tput setab 2)
#~ BLACKWHITE=$(tput setaf 0)$(tput setab 7)
#~ BLACKCYAN=$(tput setaf 0)$(tput setab 6)
#~ BLACKPURPLE=$(tput setaf 0)$(tput setab 5)
#~ BLACKBLUE=$(tput setaf 0)$(tput setab 4)
#~ BLACKYELLOW=$(tput setaf 0)$(tput setab 3)
#~ BLACKGREEN=$(tput setaf 0)$(tput setab 2)
#~ BLACKRED=$(tput setaf 0)$(tput setab 1)
end=0
nbrand=0
executionpathcd="cd `pwd`"
echo $ececutionpathcd
listc=()
addpath() {
	#$1 linux directory
	#~ file=consolelist.txt
	#~ Lines=$(cat $file)
	#~ for Line in $Lines
	#~ do
		#~ p=$(echo $Line | cut -d"|" -f5)
		#~ PATH=$PATH:$p
	#~ done
	PATH=$PATH:$1
}
addpathatstart() {
	#~ #$1 linux directory
	file=consolelist.txt
	Lines=$(cat $file)
	for Line in $Lines
	do
		p=$(echo $Line | cut -d"|" -f5)
		PATH=$PATH:$p
	done
}
checkdependances() {
	if [ -e `whereis tput | cut -d" " -f2` ] ; then 
		sleep 0
	else 
		echo "tput not found" 
		installdependances 
	fi
	if [ -e `whereis unzip | cut -d" " -f2` ] ; then 
		sleep 0
	else 
		echo "unzip not found" 
		installdependances
	fi
	if [ -e `whereis zip | cut -d" " -f2` ] ; then 
		sleep 0
	else 
		echo "zip not found" 
		installdependances
	fi
	if [ -e `whereis lynx | cut -d" " -f2` ] ; then 
		sleep 0
	else 
		echo "lynx not found" 
		installdependances
	fi
	if [ -e `whereis 7z | cut -d" " -f2` ] ; then 
		sleep 0
	else 
		echo "7z not found" 
		installdependances
	fi
	#~ if [ -e `whereis phantomjs | cut -d" " -f2` ] ; then 
		#~ sleep 0
	#~ else 
		#~ echo "phantomjs not found" 
		#~ installdependances
	#~ fi
}

isWSL() { #assume os is wsl
	wsl=$(uname -a | grep WSL)
	if echo $wsl | grep WSL ; then return 0 ; else return 1  ; fi
}
isDebian() {
	if [ -e `whereis apt | cut -d" " -f2` ] ; then return 0 ; else return 1 ; fi
}
isArch() {
	#also manjaro
	#if pacman exist
	if [ -e `whereis pacman | cut -d" " -f2` ] ; then return 0 ; else return 1 ; fi
}
isRedhat() {
	#if rpm exist
	if [ -e `whereis rpm | cut -d" " -f2` ] ; then return 0 ; else return 1 ; fi

}
determineOS() {
	if isWSL; then  
		if isDebian ;then 
			echo "wsldebian"
			return 1 #wsldebian
		fi 
		if isArch ;then 
			echo "wslarch"
			return 2 #wslarch 
		fi
		if isRedhat ;then 
			echo "wslredhat"
			return 3 #wslredhat
		fi
	else
		if isDebian ;then 
			echo "debian"
			return 4 #debian
		fi 
		if isArch ;then 
			echo "arch"
			return 5 #arch 
		fi
		if isRedhat ;then 
			echo "redhat"
			return 6 #redhat
		fi
	fi 
	
}
installdependances() {
	echo "Installing dependencies ...."
	sleep 2
	determineOS
	local OStype=$?
	#~ echo $OStype
	case $OStype in 
		1) #wsldebian
			sudo apt-get install ncurses-bin unzip zip lynx p7zip-full
		;;
		#~ 2)#wslarch
		#~ ;;
		#~ 3)#wslredhat
		#~ ;;
		
		4)#debian
			sudo apt-get install ncurses-bin unzip zip lynx p7zip-full
		;;
		#~ 5)#arch
		#~ ;;
		#~ 6)#redhat
		#~ ;;
		*)
			echo "place"
		;;
	esac
}

downloadEmu() {
	determineOS
	local OStype=$?
	#~ echo $OStype
	case $OStype in 
		1) #wsldebian
			echo -e "${BLACKCYAN}Quel Emulateur voulez vous installer ?${NC}${CYAN}\n1 - Retroarch\n2 - PCSX2 nightly\n3 - PCSX2\n4 - Dolphin\nm - Retour au menu principale\nx - Quitter${NC}"
			read rep
			case $rep in
				1)
					echo "${BLACKCYAN}Installation de Retroarch${NC}"
					wget https://buildbot.libretro.com/nightly/windows/x86_64/RetroArch-Win64-setup.exe
					chmod +x RetroArch-Win64-setup.exe
					powershell.exe Start "RetroArch-Win64-setup.exe"
					#~ rm RetroArch-Win64-setup.exe
					echo "${BLACKGREEN}Dossier d'installation de retroarch? (format windows)${NC}"
					read -r retroarchdir
					rm RetroArch-Win64-setup.exe
					retroarchdir=$(winpathtowsl $retroarchdir)$(echo "/cores")
					echo "${BLACKYELLOW}Downloading Cores ....${NC}"
					sleep 2
					wget -e robots=off -nH -r --no-parent --cut-dirs=5 --reject="index.html*" https://buildbot.libretro.com/nightly/windows/x86_64/latest/ -P `echo $retroarchdir`
					cd $retroarchdir
					unzip -o '*.zip'
					
					rm *.zip
					eval $executionpathcd
					echo "${BLACKWHITE}Veuillez ajouter au moins une console - Entrer un nom de console (ex: GBA,N64,SNES,PSX,PS3)${NC}${WHITE}"
					read nomconsole
					addconsolefromemudownload $nomconsole $retroarchdir
					echo "${BLACKRED}Premier lancement, veuillez configurer l'emulateur a votre guise${NC}"
					sleep 4
					eval retroarch.exe
					
										
				;;
				2)
					#NEED BIOS DOWNLOAD
					echo "${BLACKCYAN}Installation de PCSX2 nightly${NC}"
					#~ echo 'export PATH=$PATH:/path/to/driver' >> ~/.bash_profile
					#~ source ~/.bash_profile
					echo "Ou voulez vous installer PCSX2 nightly?"
					read -r pcsxnightly2dir
					pcsxnightly2dir=$(winpathtowsl $pcsxnightly2dir)
					wget $(lynx -dump https://github.com/PCSX2/pcsx2/releases/ | grep 'SSE4-Qt.7z'|grep 'release' | awk {'print $2'} | sed -n '1p') -P `echo $pcsxnightly2dir`
					cd $pcsxnightly2dir
						7za x -y '*SSE4-Qt.7z'
						rm *SSE4-Qt.7z
						commandline=$(ls *.exe)
						mkdir -p bios
						cd bios
							wget https://archive.org/download/playstation-2-ps2-bios/PlayStation%C2%AE%202%20%28PS2%20BIOS%29.zip
							unzip -o '*.zip'
							cd `ls -d */ 2> /dev/null`
									cp * ../
							cd ../
							rm -r `ls -d */ 2> /dev/null`	
							rm *.zip
						cd ../						
						#~ echo $commandline
					eval $executionpathcd					
					addconsolefromemudownload $(echo PS2nightly) $pcsxnightly2dir $commandline
					echo "${BLACKRED}Premier lancement, veuillez configurer l'emulateur a votre guise${NC}"
					echo ""
					sleep 4
					eval $commandline
					
				;;
				3)
					#NEED BIOS DOWNLOAD
					echo "${BLACKCYAN}Installation de PCSX2${NC}"
					echo "Ou voulez vous installer PCSX2 ? (sintaxe Windows)"
					read -r pcsx2dir
					pcsx2dir=$(winpathtowsl $pcsx2dir)
					#~ echo $pcsx2dir
					#~ wget $(lynx -dump https://github.com/PCSX2/pcsx2/releases/ | grep 'SSE4.7z'|grep 'release' | awk {'print $2'} | sed -n '1p') -P `echo $pcsx2dir`
					#~ echo $pcsxdir"oizajoidjazijiodjioazjidjiozjaiojdiojaziojdojazidzoiaj"
					wget $(lynx -dump https://github.com/PCSX2/pcsx2/releases/latest | grep portable.7z | awk {'print $2'} | sed -n '2p') -P `echo $pcsx2dir`
					cd $pcsx2dir
						7za x -y '*.7z'
						cd `ls -d */ 2> /dev/null`
							#~ cp * ../
							commandline=$(ls *.exe)
							pcsx2dir="`pwd`"
							mkdir -p bios
							cd bios
								wget https://archive.org/download/playstation-2-ps2-bios/PlayStation%C2%AE%202%20%28PS2%20BIOS%29.zip
								unzip -o '*.zip'
								cd `ls -d */ 2> /dev/null`
										cp * ../
								cd ../
								rm -r `ls -d */ 2> /dev/null`	
								rm *.zip
							cd ../
						cd ../
						rm *.7z
					eval $executionpathcd
					addconsolefromemudownload $(echo PS2) $pcsx2dir $commandline					
					echo "${BLACKRED}Premier lancement, veuillez configurer l'emulateur a votre guise${NC}"
					echo""
					#~ echo $PATH
					sleep 4
					eval $commandline
					
				;;
				4)
					#WHYNOT BIOS DOWNLOAD
					echo "${BLACKCYAN}Installation de Dolphin${NC}"
					echo "${BLACKGREEN}Ou voulez vous installer dolphin? (format windows)${NC}"
					read -r dolphindir
					dolphindir=$(winpathtowsl $dolphindir)
					cd $dolphindir
						wget $(lynx -dump https://fr.dolphin-emu.org/download/ | grep ".7z" | awk {'print $2'} | sed -n '1p')
						7za x -y '*.7z'
						cd `ls -d */ 2> /dev/null`
							commandline="$(ls *olphin.exe)$(echo " -e")"
							dolphindir="`pwd`"
						cd ../
						rm *.7z
					eval $executionpathcd
					echo "${BLACKWHITE}Ajouter les roms Gamecube ? [y/n]${NC}"
					read rep1
					case $rep1 in
						y)
							addconsolefromemudownload $(echo NGC) $dolphindir "$commandline"
							#~ echo "${BLACKGREEN}$PATH${NC}"
						;;
						*)
							echo "Jeux Gamecube non ajoutés"
						;;
					esac
					echo "${BLACKWHITE}Ajouter les roms Wii ? [y/n]${NC}"
					read rep2
					case $rep2 in
						y)
							addconsolefromemudownload $(echo Wii) $dolphindir "$commandline"
						;;
						*)
							echo "Jeux Wii non ajoutés"
						;;
					esac
					echo "${BLACKRED}Premier lancement, veuillez configurer l'emulateur a votre guise${NC}"
					sleep 4
					#~ echo "${CYAN}$PATH${NC}"
					eval Dolphin.exe
				;;
				m)
					#~ return 1
				;;
				x)
					exit
				;;
				*)
					echo "${RED}Mauvais caractère, Retour au menu principale${NC}"
					#~ return 1
				;;
			esac

		;;
		#~ 2)#wslarch
			#~ return 0
		#~ ;;
		#~ 3)#wslredhat
		#~ ;;
		
		4)#debian
			sudo apt-get install retroarch
			#Retroarch https://buildbot.libretro.com/nightly/linux/x86_64/latest/
			echo "Dossier d'installation de retroarch? (format linux)"
			read -r dir
			dir=$(winpathtows $dir)
			wget -e robots=off -nH -r --no-parent --cut-dirs=5 --reject="index.html*" https://buildbot.libretro.com/nightly/linux/x86_64/latest/ -P `echo $dir`
			#~ wget -e robots=off -nH -r --no-parent --cut-dirs=5 --reject="index.html*" https://buildbot.libretro.com/nightly/linux/x86_64/latest/ -P ./
			eval $executionpathcd

			
		;;
		#~ 5)#arch
		#~ ;;
		#~ 6)#redhat
		#~ ;;
		*)
			echo "place"
		;;
	esac

}

die() {
  printf >&2 '%s\n' "$1"
  #exit 1
}
winpathtowsl(){
	#$1=windows path string
	line=$(sed -e 's~\\~/~g' -e 's~\ ~\\\ ~g' -e "s/\([ABCDEFGHIJKLMNOPQRSTUVWXYZ]\):/\L\1/" -e "s/^/\/mnt\//g" <<< "$1")
	echo -e $line
	#return wsl path string
}
wslpathtowin() {
	#$1=wslpath
	line=$(sed -e 's~/~\\~g' <<< $1)
	line=$(sed -e 's~^.....~~g' <<< $line)
	line=$(sed -e "s/^./\U&:/g" <<< $line)
	line=$(sed "s/\\\''//g" <<< $line)
	echo $line
	#Exemple
	# ./wslpathtowin.sh  "/mnt/e/test/All Star - Tennis '\''99 (Europe) (En,Fr,De,Es,It) (Track 35).bin"
	#Result
	# E:\test\All Star - Tennis '99 (Europe) (En,Fr,De,Es,It) (Track 35).bin
}
createlistconsoleifnotexist(){
	if [ -e consolelist.txt ]; then
		#~ echo "Liste des consoles existante"
		echo ""
	else
		echo "Creation de la liste des consoles existante"
		echo "" > consolelist.txt
	fi
}
getlistconsole(){
	listc=()
	file=consolelist.txt
	Lines=$(cat $file)
	for Line in $Lines
	do
		listc=( "${listc[@]}" "`echo $Line`" )
	done
}
listconsole () {
	for elem in "${listc[@]}"    
	do  
        echo -e "${YELLOW}`echo $elem | cut -d"|" -f1`"  
	done
}
savelistconsole(){
	for elem in "${listc[@]}"    
	do   
        echo $elem >> consolelist.txt  
	done
	sort -u consolelist.txt > consolelist2.txt
	rm consolelist.txt
	mv consolelist2.txt consolelist.txt
	sed -i '/^$/d' consolelist.txt		#supprime les lignes vides
}
addconsole(){
	if isWSL ;then
		echo ""
		getlistconsole
		echo "${BLACKWHITE}Entrer un nom de console (ex: GBA,PS3)${NC}${WHITE}"
		read cons
		echo "${BLACKWHITE}Entrer la commande de l'émulateur (sans la rom)(ex: pcsx2.exe --nogui , syntaxe Windows)${NC}${WHITE}"
		read -r emu
		
		echo "${BLACKWHITE}Entrer le chemin de l'émulateur (ex: D:\PCSX2 , syntaxe Windows)${NC}${WHITE}"
		read -r emufolderwindows
		emufolderlinux="`winpathtowsl $emufolderwindows`"
		
		emu=$(sed -e 's~\\~\\\\~g' <<< "$emu")
		echo "${BLACKWHITE}Entrer le dossier des roms $cons (syntaxe Windows)(ex: C:\Jeuc\ngc)${NC}${WHITE}"
		read -r romfolderwindows
		romfolderlinux="`winpathtowsl $romfolderwindows`"
		romfolderwindows=$(sed -e 's~\\~\\\\~g' <<< "$romfolderwindows")
		while [ ! -d "$romfolderlinux" ]; do
			echo "${BLACKWHITE}Chemin incorrect, entrer le chemin des roms $cons (syntaxe Windows)(ex: C:\Jeuc\ngc)${NC}${WHITE}"
			read -r romfolderwindows
			romfolderlinux="`winpathtowsl $romfolderwindows`"
		done
		listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderwindows`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )
		savelistconsole
		creategamelistifnotexist $cons
		addpath $emufolderlinux
	else
		echo ""
		getlistconsole
		echo "${BLACKWHITE}Entrer un nom de console (ex: GBA,PS3)${NC}${WHITE}"
		read cons
		echo "${BLACKWHITE}Entrer la commande de l'émulateur (sans la rom)(ex: dolphin -e , syntaxe Linux)${NC}${WHITE}"
		read -r emu
		#~ echo "${BLACKWHITE}Entrer le chemin de l'émulateur (ex: /mnt/d/dolphin , syntaxe linux)${NC}${WHITE}"
		#~ read -r emufolderlinux
		emufolderlinux=$(whereis $(echo $emu | cut -d" " -f1) | cut -d" " -f2)
		
		emu=$(sed -e 's~\\~\\\\~g' <<< "$emu")
		echo "${BLACKWHITE}Entrer le dossier des roms $cons (syntaxe Linux)(ex: /home/truc)${NC}${WHITE}"
		read -r romfolderlinux
		#~ romfolderlinux="`winpathtowsl $romfolderwindows`"
		#~ romfolderwindows=$(sed -e 's~\\~\\\\~g' <<< "$romfolderwindows")
		while [ ! -d "$romfolderlinux" ]; do
			echo "${BLACKWHITE}Chemin incorrect, entrer le chemin des roms $cons (syntaxe linux)(ex: /home/truc)${NC}${WHITE}"
			read -r romfolderlinux
			#~ romfolderlinux="`winpathtowsl $romfolderwindows`"
		done
		#~ listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderlinux`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )
		listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderlinux`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )

		savelistconsole
		creategamelistifnotexist $cons
		addpath $emufolderlinux
	fi
}
addconsolefromemudownload() {
	echo addconsolelollllll
	#$1=console $2=emupath $3=commandline #
	if isWSL ;then
		echo ""
		getlistconsole
		echo "${BLACKWHITE}Ajoute $1 ...${NC}${WHITE}"
		cons=$1
		echo "${BLACKWHITE}Ajoute le chemin de l'émulateur ....${NC}"
			emufolderlinux=$2
			echo $emufolderlinux
			#~ echo $PATH
		if [ -z "$3" ] ;then
			echo "${BLACKWHITE}Entrer la commande de l'émulateur (sans la rom)"
			echo "(ex: retroarch.exe -L \"C:\RetroArch-Win64\cores\vbam_libretro.dll\" -c \"C:\RetroArch-Win64\retroarch.cfg\" , syntaxe Windows)${NC}${WHITE}"
			read -r emu			
		else
			echo "${BLACKWHITE}Ajoute la commande de l'émulateur ....${NC}"
			emu="$3"
			#~ echo $emu
		fi
		
		#~ emufolderlinux=$2
		
		emu=$(sed -e 's~\\~\\\\~g' <<< "$emu")
		echo $emu
		echo "${BLACKWHITE}Entrer le dossier des roms $cons (syntaxe Windows)(ex: C:\Jeuc\ngc)${NC}${WHITE}"
		read -r romfolderwindows
		romfolderlinux="`winpathtowsl $romfolderwindows`"
		romfolderwindows=$(sed -e 's~\\~\\\\~g' <<< "$romfolderwindows")
		while [ ! -d "$romfolderlinux" ]; do
			echo "${BLACKWHITE}Chemin incorrect, entrer le chemin des roms $cons (syntaxe Windows)(ex: C:\Jeuc\ngc)${NC}${WHITE}"
			read -r romfolderwindows
			romfolderlinux="`winpathtowsl $romfolderwindows`"
		done
		listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderwindows`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )
		savelistconsole
		creategamelistifnotexist $cons
		addpath $emufolderlinux
	else
		echo ""
		getlistconsole
		echo "${BLACKWHITE}Ajoute $1 ...${NC}${WHITE}"
		cons=$1
		#~ echo "${BLACKWHITE}Entrer la commande de l'émulateur (sans la rom)(ex: dolphin -e , syntaxe Linux)${NC}${WHITE}"
		#~ read -r emu
		#~ if $3;then
		emu=$3
		#~ echo "${BLACKWHITE}Entrer le chemin de l'émulateur (ex: /mnt/d/dolphin , syntaxe linux)${NC}${WHITE}"
		#~ read -r emufolderlinux
		#~ echo "${BLACKWHITE}Ajoute le chemin de l'émulateur ...${NC}"
		emufolderlinux=$(whereis $(echo $emu | cut -d" " -f1) | cut -d" " -f2)
		
		emu=$(sed -e 's~\\~\\\\~g' <<< "$emu")
		echo "${BLACKWHITE}Entrer le dossier des roms $cons (syntaxe Linux)(ex: /home/truc)${NC}${WHITE}"
		read -r romfolderlinux
		#~ romfolderlinux="`winpathtowsl $romfolderwindows`"
		#~ romfolderwindows=$(sed -e 's~\\~\\\\~g' <<< "$romfolderwindows")
		while [ ! -d "$romfolderlinux" ]; do
			echo "${BLACKWHITE}Chemin incorrect, entrer le chemin des roms $cons (syntaxe linux)(ex: /home/truc)${NC}${WHITE}"
			read -r romfolderlinux
			#~ romfolderlinux="`winpathtowsl $romfolderwindows`"
		done
		#~ listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderlinux`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )
		listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderlinux`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )

		savelistconsole
		creategamelistifnotexist $cons
		addpath $emufolderlinux
	fi	
}
#~ addconsolefromemudownloadforretroarch(){
	#~ #$1=console $2=emu path $3=commandline
	#~ echo "placeholderz"
	#~ if isWSL ;then
		#~ echo ""
		#~ getlistconsole
		#~ echo "${BLACKWHITE}Ajoute $1 ...${NC}${WHITE}"
		#~ cons=$1
		#~ echo "${BLACKWHITE}Entrer la commande de l'émulateur (sans la rom)(ex: pcsx2.exe --nogui , syntaxe Windows)${NC}${WHITE}"
		#~ read -r emu		
		#~ emufolderlinux=$2		
		#~ emu=$(sed -e 's~\\~\\\\~g' <<< "$emu")
		#~ echo "${BLACKWHITE}Entrer le dossier des roms $cons (syntaxe Windows)(ex: C:\Jeuc\ngc)${NC}${WHITE}"
		#~ read -r romfolderwindows
		#~ romfolderlinux="`winpathtowsl $romfolderwindows`"
		#~ romfolderwindows=$(sed -e 's~\\~\\\\~g' <<< "$romfolderwindows")
		#~ while [ ! -d "$romfolderlinux" ]; do
			#~ echo "${BLACKWHITE}Chemin incorrect, entrer le chemin des roms $cons (syntaxe Windows)(ex: C:\Jeuc\ngc)${NC}${WHITE}"
			#~ read -r romfolderwindows
			#~ romfolderlinux="`winpathtowsl $romfolderwindows`"
		#~ done
		#~ listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderwindows`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )
		#~ savelistconsole
		#~ creategamelistifnotexist $cons
	#~ else
		#~ echo ""
		#~ getlistconsole
		#~ echo "${BLACKWHITE}Ajoute $1 ...${NC}${WHITE}"
		#~ cons=$1
		#~ emu=$3
		#~ emufolderlinux=$(whereis $(echo $emu | cut -d" " -f1) | cut -d" " -f2)	
		#~ emu=$(sed -e 's~\\~\\\\~g' <<< "$emu")
		#~ echo "${BLACKWHITE}Entrer le dossier des roms $cons (syntaxe Linux)(ex: /home/truc)${NC}${WHITE}"
		#~ read -r romfolderlinux
		#~ while [ ! -d "$romfolderlinux" ]; do
			#~ echo "${BLACKWHITE}Chemin incorrect, entrer le chemin des roms $cons (syntaxe linux)(ex: /home/truc)${NC}${WHITE}"
			#~ read -r romfolderlinux
		#~ done
		#~ listc=( "${listc[@]}" "$cons|`echo $emu`|\"`echo $romfolderlinux`|\"`echo -e "$romfolderlinux"`\"|`echo -e "$emufolderlinux"`" )
		#~ savelistconsole
		#~ creategamelistifnotexist $cons
	#~ fi
#~ }
removeconsole(){	
	sed -i "/$1/d" consolelist.txt
	getlistconsole
}
choixconsole() {
	echo "" > selec.txt
	while [ $end == 0 ]; do
		echo ""
		choix="0"
		while [ $choix != "f" ];do
			echo "${BLACKYELLOW}Choix de la console${NC}"
			echo -e "`listconsole`\nf - fin de selection "
			echo ""
			echo "${BLACKGREEN}Selection en cours:${NC}${GREEN} `printlist`"	
			read selec
			echo ""
			case $selec in
				("") die "Can't be empty";;
				f)
					choix=f
					end=1
				;;
				*([a-zA-Z0-9]))
					echo $selec >> selec.txt
					choix=0;;			
				*)		
					exit
				;;
			esac
		done
		sed -i '/^$/d' selec.txt		#supprime les lignes vides
		echo "${BLACKGREEN}Selection:${NC}${GREEN} `printlist`"
		#~ cat selec.txt
	done; 
}
printlist(){
		file=selec.txt
		Lines=$(cat $file)
		for Line in $Lines
		do
			listselec=$listselec$Line","
		done
		echo $(sed '$ s/.$//' <<< $listselec)
}
fullrandomselec(){
		echo "" > selec.txt
		file=consolelist.txt
		Lines=$(cat $file)
		for Line in $Lines
		do	
			echo $Line | cut -d"|" -f1 >> selec.txt
		done
		sed -i '/^$/d' selec.txt		#supprime les lignes vides
}
creategamelistifnotexist() {
	#$1=console
	cd="cd `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f4 | sed -n '1p'`"
	eval $cd
	if [ -e list.txt ]; then
		#~ echo "Liste existante"
		if [ `wc -l < list.txt` -eq 0 ]; then #CONDITION si le nombre de ligne = ZERO
			echo "Liste vide !"
			creategamelist
		fi
	else
		creategamelist
	fi
	eval $executionpathcd
}
regengamelist() {
	#$1=console
	cd="cd `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f4`"
	eval $cd
	rm list.txt
	echo "${BLACKWHITE}Régénération de la liste de $1 ..... ${NC}"
	creategamelist
	eval $executionpathcd
}
creategamelist(){
	#Récupère la liste et trie les fichiers du script###
	echo "Création de la liste"
	ls > listglobal.txt
	cp listglobal.txt list.txt			
	sed -i -e "s/*Shuffler.sh//g" list.txt						###
	sed -i -e "s/list.txt//g" list.txt						###
	sed -i -e "s/listglobal.txt//g" list.txt	
	sed -i '/(Disc 2)/d' list.txt
	sed -i '/(Disc 3)/d' list.txt
	sed -i '/(Disc 4)/d' list.txt
	sed -i '/(Track 2)/d' list.txt
	sed -i '/.cue/d' list.txt	#supprime les .cue de la liste			###
	sed -i '/^$/d' list.txt		#supprime les lignes vides			###
}
removefromlist() {
	#$1=console $2=jeu
	cd="cd `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f4`"
	eval $cd
	echo "${BLACKYELLOW}Voulez vous supprimer le jeu de la liste ? [x=exit] [y/n]${NC}${YELLOW}"
    read reponse
	case $reponse in
		y)
			sed -i -e "s/"`echo $2`"//g" list.txt     #supprime le nom de la liste
			sed -i '/^$/d' list.txt
			echo "${YELLOW}Jeu supprimé de la liste${NC}"
		;;
		n)
			echo "${YELLOW}Jeu toujours dans la liste${NC}"
		;;
		x)
			exit
		;;
		*)
			echo "${YELLOW}Veullez entrer un caractèce correct, jeu non supprimé de la liste${NC}"
		;;	
	esac
	eval $executionpathcd              
}
removefromdisk(){
	#$1=console $2=jeu
	cd="cd `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f4`"
	eval $cd
	
	echo "${BLACKRED}Voulez vous supprimer ce jeu ? [x=exit] [y/n]${NC}${RED}"
	read reponse
	case $reponse in
		y)
			if ls "`echo $2`";  then
				sed -i -e "s/"`echo $2`"//g" list.txt     #supprime le nom de la liste
				sed -i '/^$/d' list.txt
				rm "`echo $2`"
				echo "${RED}a été supprimé du disque et de la liste${NC}"
			else
	        	echo "${RED}fichier non trouvé${NC}"
	        	eval $executionpathcd
				return 0
			fi
			eval $executionpathcd
			return 1
		;;
		n)
			echo "${RED}le jeu n'a pas été supprimé${NC}"
			eval $executionpathcd
			return 0
		;;
		x)
			exit
		;;
		*)
			echo "${RED}Veuillez entrer un caractère correct, jeu non supprimé${NC}"
			eval $executionpathcd
			return 0
		;;
	esac
}
randoconsole() {
	nbline=$(wc -l selec.txt | cut -d ' ' -f 1)
	nbrand=$(shuf -i 1-`echo $nbline` -n 1)
	consolename=$(sed -n `echo $nbrand`p selec.txt)
	echo "$consolename"
}
getnbjeu() {
	#$1=console
	cd="cd `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f4`"
	#~ echo $cd
	eval $cd
	nb=$(wc -l list.txt | cut -d ' ' -f 1)
	eval $executionpathcd
	echo $nb
	
}
getnojeu() {
	#$1=console $2=jeu
	cd="cd `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f4`"
	eval $cd
	nojeu=$(sed -n "/$2/=" list.txt)
	eval $executionpathcd
	echo $nojeu
	
}

getnbjeutotal() {
	
	file=consolelist.txt
	total=0
	Lines=$(cat $file)
	for Line in $Lines
	do
		creategamelistifnotexist `echo $Line | cut -d"|" -f1`
		j=$(getnbjeu `echo $Line | cut -d"|" -f1`)
		#~ echo $j
		total=$(expr $total + $j)
		#~ echo test
		#~ echo $Line
	done
	echo $total
}

randogame() {
	#$1=console
	cd="cd `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f4`"
	eval $cd
	nbline=$(wc -l list.txt | cut -d ' ' -f 1)
	nbrand=$(shuf -i 1-`echo $nbline` -n 1)
	filename=$(sed -n `echo $nbrand`p list.txt)
	echo "\\$filename"
	eval $executionpathcd
}
execgame() {
	#$1=console $2=jeux
	echo "${BLACKCYAN}Voulez vous executer le jeu? [x=exit][m=menu] [y/n]${NC}${CYAN}"
	read execution
	case $execution in
		y)
			e="`sed -n "/$1|/p" consolelist.txt | cut -d"|" -f2` `sed -n "/$1|/p" consolelist.txt | cut -d"|" -f3`$2\""
			##echo $e
			e=$(sed -e 's~\\\\~\\~g' <<< "$e")
			startchrono=$SECONDS
			eval $e
			duration=$(( SECONDS - startchrono ))
			awk -v t=$duration 'BEGIN{t=int(t*1000); printf "Vous avez joué %dh%02dm%02ds\n", t/3600000, t/60000%60, t/1000%60}'
		;;
		n)
			echo "${CYAN}Jeu non executé${NC}"
			return 0
		;;
		x)
			exit
		;;
		m)
			return 1
		;;
		*)
			echo "${CYAN}Veuillez entrer un caractère correct, Jeu non executé${NC}"
			return 0
		;;
	esac
	
}
execgameroutine(){
	#$1=console
	creategamelistifnotexist $1
	rando="`randogame $1`"	
	echo "${CYAN}Jeu "$(getnojeu $1 $rando)" sur "$(getnbjeu $1)" | "$(sed -e 's/^.//' <<< $rando)"${NC}"
	if execgame $1 $rando ;then
		if removefromdisk $1 $rando;then	
			removefromlist $1 $rando
		fi
	else
		echo "......Retour au menu......."
		eval $executionpathcd 
		return 1
	fi
	eval $executionpathcd 
}
menu() {
	#	first to be excuted

	#
	createlistconsoleifnotexist
	getlistconsole
	echo "${BLACKGREEN}MENU PRINCIPALE${NC}${GREEN}"
	echo -e "1 - Ajouter Console\n2 - Supprimer Console\n3 - Lister les consoles\n4 - Choisir Console\n5 - FullRandom\n6 - Regen liste de jeux\n7 - Télécharger un Emulateur\nx - Quitter "
	echo ""
	echo "Total de jeux : `getnbjeutotal`${NC}"
	echo ""
	read r
	case $r in
		1)
			addconsole
			savelistconsole
		;;
		2)
			echo "${BLACKYELLOW}Quelle console enlever?${NC}"
			listconsole
			read rem
			removeconsole $rem
		;;
		3)	
			echo ""
			echo "${BLACKYELLOW}Liste des Consoles${NC}"
			getlistconsole
			listconsole
		;;
		4)
			getlistconsole
			choixconsole
			m="0"
			while [ $m == "0" ];do
				console="`randoconsole`"
				echo ""
				echo "${BLACKWHITE}Console: "$console"${NC}"
				if execgameroutine $console ;then
					m="0"
				else
					m="1"
				fi
			done
		;;
		5)
			fullrandomselec
			m="0"
			while [ $m == "0" ];do
				console="`randoconsole`"
				echo ""
				echo "${BLACKWHITE}Console: "$console"${NC}"
				if execgameroutine $console ;then
					m="0"
				else
					m="1"
				fi
			done
		;;
		6)	
			echo ""
			echo "${BLACKYELLOW}Liste des consoles${NC}"
			listconsole
			echo ""
			echo "${BLACKWHITE}De quel console régénerer la liste?${NC}${WHITE}"
			read regen
			regengamelist $regen
		;;
		7)
			downloadEmu
		;;
		x)
			return 1
		;;
		*);;
	esac
}
checkdependances
addpathatstart
######Tput colors
	WHITE=$(tput setaf 7)
	CYAN=$(tput setaf 6)
	PURPLE=$(tput setaf 5)
	BLUE=$(tput setaf 4)
	YELLOW=$(tput setaf 3)
	GREEN=$(tput setaf 2)
	RED=$(tput setaf 1)
	BLACK=$(tput setaf 0)
	NC=$(tput sgr0)
	PURPLEYELLOW=$(tput setaf 5)$(tput setab 3)
	YELLOWPURPLE=$(tput setaf 3)$(tput setab 5)
	YELLOWGREEN=$(tput setaf 3)$(tput setab 2)
	BLACKWHITE=$(tput setaf 0)$(tput setab 7)
	BLACKCYAN=$(tput setaf 0)$(tput setab 6)
	BLACKPURPLE=$(tput setaf 0)$(tput setab 5)
	BLACKBLUE=$(tput setaf 0)$(tput setab 4)
	BLACKYELLOW=$(tput setaf 0)$(tput setab 3)
	BLACKGREEN=$(tput setaf 0)$(tput setab 2)
	BLACKRED=$(tput setaf 0)$(tput setab 1)
######Tput colors
echo "${PURPLE}###################################################"
echo "#####Bienvenue dans le Romdomizer Multiconsole#####"
echo "###################################################${NC}"
n=0
while [ $n == 0 ];do
	if menu ;then
		n="0"
	else
		n="1"
	fi	
done
IFS=$SAVEIFS
