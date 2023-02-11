APPENDIX 1 – LANCED  

 

 

#####  INSTALLER  ##### 

### APPENDIX ### 

 

 

 

#####  INSTALLER  ##### 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 

#!/bin/bash 

    #title          :installersuidrootLANCED.sh 

    #description    :installer tool for LANCED 

    #author         :rektosauruz 

    #date           :20181127 

    #version        :v0.1 

    #usage          :./installersuidrootLANCED.sh 

    #notes          :lanced version update for thesis 

    #bash_version   :4.4-5 

    #============================================ 

 

#File Declarations 

#/home/pi/lanced_logs/                    [raw data files are saved here from kismet_server.] 

#/home/pi/lanced_arch/                    [files are transferred after each run to this location to be processed.] 

#/home/pi/lanced_arch/{date}/             [a dated folder is created for that day.] 

#/home/pi/lanced_arch/BSSID.list          [unique MACs are held here for counting and comparison for uniqueness.] 

#/home/pi/lanced_arch/datapool.txt        [datapool.txt holds the unique data, populated after each run, a simple database file holds raw data.] 

#/home/pi/lanced_arch/temp.list           [for each run MACs in the respective .nettxt file are passed to temp.list for comparison with BSSID.list] 

#/home/pi/lanced_arch_processed/          [processed files are saved here under the same respective dates.] 

#/home/pi/lanced_arch_processed/{date}/   [dated folders are directly transferred under processed section after the sequence.] 

#/etc/kismet/timechk             [timechk file is created after the first date correction, at the end of each run, this file is removed.] 

 

##For both GUI and CLI, automation script 

##will automatically install and configure lanced system to latest version. 

##For debugging, an echo can be return if a specific process is failed.

#Color Declerations 

ESC="#[" 

RESET=$ESC"39m" 

RED=$ESC"31m" 

GREEN=$ESC"32m" 

LYELLOW=$ESC"36m" 

YELLOW=$ESC"34m" 

YELLOW=$ESC"33m" 

RB=$ESC"48;5;160m" 

RESET1=$ESC"0m" 

 

##check for root 

if [[ "${EUID}" -ne 0 ]]; then 

  echo -e "${GREEN}run${RESET} ${RED}installer.sh${RESET} ${GREEN}with${RESET} ${RED}root !${RESET}" 

  exit 1 

fi 

 

##fix locale 

#if [ "`locale | tail -1`" == "LC_ALL=" ];then 

#  export LC_ALL=C 

#  sudo dpkg-reconfigure locales 

#fi 

 

####FIRST SECTION#### 

##initialization of required folders used by LANCED.sh 

sudo mkdir /home/pi/lanced_logs 

sudo mkdir /home/pi/lanced_arch 

sudo mkdir /home/pi/lanced_arch/processed 

sudo touch /home/pi/lanced_arch/BSSID.list 

sudo touch /home/pi/lanced_arch/datapool.txt 

 

 

 

#initialize v{1-20} 

for i in `seq 1 23`;do 

  c="`sed ""$i"q;d" /home/pi/LANCED/lanced_handler/dep.list`" 

  eval "v${i}=${RED}[${c}]${RESET}" 

done 

 

 

###Loading bar indicates while download and initialization progress### 

ledger () { 

clear 

cat <<-ENDOFMESSAGE 

${RB}                                       ${RESET1} 

${RB} ${RESET1}$v21   $v22   $v23${RB} ${RESET1} 

${RB} ${RESET1}$v1   $v2     $v3${RB} ${RESET1} 

${RB} ${RESET1}$v4 $v16${RB} ${RESET1} 

${RB} ${RESET1}$v6  $v7   $v8${RB} ${RESET1} 

${RB} ${RESET1}$v9  $v10  $v13${RB} ${RESET1} 

${RB} ${RESET1}$v11$v12$v14  $v20${RB} ${RESET1} 

${RB} ${RESET1}$v15    $v5${RB} ${RESET1} 

${RB} ${RESET1}$v17   $v18  $v19${RB} ${RESET1} 

${RB}                                       ${RESET1} 

ENDOFMESSAGE 

 

} 

 

ledger 

 

###using the dep.list, this iteration handles the apt-get update/upgrade/dist-upgrade 

for i in `seq 21 23`; do 

a="`sed ""$i"q;d" /home/pi/LANCED/lanced_handler/dep.list`" 

sed ""$i"q;d" /home/pi/LANCED/lanced_handler/dep.list | xargs apt-get -y > /dev/null 2>&1 && eval "v${i}=${GREEN}[${a}]${RESET}" || 

echo -e "$a" >> /home/pi/LANCED/lanced_handler/error.list 

ledger 

done 

 

###using the dep.list this iteration hadnles the apt-get install 

echo -e "update - upgrade - dist-upgrade DONE" >> /home/pi/LANCED/lanced_handler/progress.list 

 

for i in `seq 1 19`; do 

 	a="`sed ""$i"q;d" /home/pi/LANCED/lanced_handler/dep.list`" 

 	sed ""$i"q;d" /home/pi/LANCED/lanced_handler/dep.list | xargs apt-get install -y > /dev/null 2>&1 && eval "v${i}=${GREEN}[${a}]${RESET}" || 

 	echo -e "$a" >> /home/pi/LANCED/lanced_handler/error.list 

  ledger 

done 

 

#echo -e "essential files DONE" >> /home/pi/LANCED/lanced_handler/progress.list 

 

#sudo apt-get install locate 

#sudo apt-get install libpcre3 libpcre3-dev 

sudo wget https://www.kismetwireless.net/code/kismet-2016-07-R1.tar.xz > /dev/null 2>&1 

sudo tar -xf kismet-2016-07-R1.tar.xz 

cd kismet-2016-07-R1/ 

 

sudo ./configure > /dev/null 2>&1 

 

sudo make dep > /dev/null 2>&1 

 

sudo make > /dev/null 2>&1 

 

sudo make suidinstall > /dev/null 2>&1 

 

sudo usermod -a -G kismet pi 

 

v20=${GREEN}[kismet]${RESET} 

ledger 

 

 

 

#echo -e "kismet DONE" >> /home/pi/LANCED/lanced_handler/progress.list 

 

####SECOND SECTION#### 

 

##git folder 

#/home/pi/LANCED/lanced_handler/ 

#/etc/kismet/ 

#/etc/kismet/kismet.conf 

#/etc/kismet/oui2.txt 

#/etc/kismet/correct_date.py 

 

 

##/etc/kismet/ folder contained file operations are handled here 

#sudo mv /usr/local/etc/kismet_drone.conf /usr/local/etc/kismet_drone.conf.orig 

sudo rm /usr/local/etc/kismet.conf 

sudo cp /home/pi/LANCED/config_files/suidins/{kismet.conf,oui2.txt,correct_date.py} /usr/local/etc/ 

#sudo chmod 777 /etc/kismet/kismet.conf 

#sudo chmod 777 /etc/kismet/oui2.txt 

sudo chmod 777 /usr/local/etc/correct_date.py 

 

 

##get mac address of wlan0 then pass it for kismet.conf for filtering the AP 

##filter_tracker=BSSID(!--:--:--:--:--:--) is the defined format 

holder="`sudo ip -o link | awk '{print $2,$(NF-2)}' | grep wlan0 | cut -d' ' -f2`" 

sed -i "198s/.*/filter_tracker=BSSID(!$holder)/" /usr/local/etc/kismet.conf 

 

#echo -e "/etc/kismet/ files done" >> /home/pi/LANCED/lanced_handler/progress.list 

 

 

##/etc/default/gpsd 

##/etc/default/hostapd 

##/etc/default/ folder file operations are handled in this part 

sudo mv /etc/default/gpsd /etc/default/gpsd.origin 

sudo mv /etc/default/hostapd /etc/default/hostapd.origin 

sudo cp /home/pi/LANCED/config_files/{gpsd,hostapd} /etc/default/ 

#sudo chmod 777 /etc/default/gpsd 

#sudo chmod 777 /etc/default/hostapd 

 

#echo -e "gpsd - hostapd files done" >> /home/pi/LANCED/lanced_handler/progress.list 

 

#/etc/network/interfaces 

sudo mv /etc/network/interfaces /etc/network/interfaces.origin 

sudo cp /home/pi/LANCED/config_files/interfaces /etc/network/ 

 

#echo -e "interfaces done" >> /home/pi/LANCED/lanced_handler/progress.list 

 

 

####/etc/hostapd/### 

#/etc/hostapd/hostapd.conf 

if [ -e /etc/hostapd/hostapd.conf ]; then 

  sudo mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.origin 

fi 

sudo cp /home/pi/LANCED/config_files/hostapd.conf /etc/hostapd/ 

 

#echo -e "hostapd.conf done" >> /home/pi/LANCED/lanced_handler/progress.list 

 

#allow ssh 

#change the default port if needed 

####/etc/ssh/### 

#/etc/ssh/sshd_config 

 

#allow ssh 

#change timezone 

#sudo raspi-config 

 

#echo -e "raspi-config done" >> /home/pi/LANCED/lanced_handler/progress.list 

 

####/etc/#### 

 

#/etc/dnsmasq.conf file operations are handled in this part 

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.origin 

sudo cp /home/pi/LANCED/config_files/dnsmasq.conf /etc/ 

 

 

#/etc/dhcpcd.conf file operations are handled in this part 

sudo mv /etc/dhcpcd.conf /etc/dhcpcd.conf.origin 

sudo cp /home/pi/LANCED/config_files/dhcpcd.conf /etc/
 

 

#/etc/sysctl.conf file operations are handled in this part 

sudo mv /etc/sysctl.conf /etc/sysctl.conf.origin 

sudo cp /home/pi/LANCED/config_files/sysctl.conf /etc/ 

 

 

#ipv4 port forward section 

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward" 

sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 

sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 

sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT 

sudo sh -c "iptables-save > /etc/iptables.ipv4.nat" 


#/etc/rc.local 

sudo mv /etc/rc.local /etc/rc.local.origin 

sudo cp /home/pi/LANCED/config_files/rc.local /etc/ 

 

sudo systemctl disable dhcpcd.service > /dev/null 2>&1 

 

##transfer the latest a.sh file to /home/pi by renaming the script and set priviliges. 

sudo mv /home/pi/LANCED/lanced_handler/asuidroot.sh /home/pi/asuidroot.sh 

sudo chmod 777 /home/pi/asuidroot.sh 

 

sleep 5 

echo "${RED}Shutting down!${RESET}" 

sudo shutdown +0 

 

#echo -e "/etc/ done" >> /home/pi/LANCED/lanced_handler/progress.list 

 

#echo -e "FINALIZED" >> /home/pi/LANCED/lanced_handler/progress.list 

 

=== 

 

 

 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 

 

 

 

###### LANCED ###### 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

#!/bin/bash 

    #title          :a.sh 

    #description    :Providing powerful yet simle UI for both cli an desktop, this script handles automation  via bash scripting. 

    #author         :rektosauruz 

    #date           :20181005 

    #version        :v2.5 

    #usage          :#pi./a.sh 

    #notes          :Single module usage is implemented for v2.0. Cell phone gps usage is implemented in addition to pl2303 gps usage. 

    #bash_version   :4.4-5 

    =============================== 

 

 

 

#File Declarations 

#/home/pi/lanced_logs/                    [raw data files are saved here from kismet_server.] 

#/home/pi/lanced_arch/                    [files are transferred after each run to this location to be processed.] 

#/home/pi/lanced_arch/{date}/             [a dated folder is created for that day.] 

#/home/pi/lanced_arch/BSSID.list          [unique MACs are held here for counting and comparison for uniqueness.] 

#/home/pi/lanced_arch/datapool.txt        [datapool.txt holds the unique data, populated after each run, a simple database file holds raw data.] 

#/home/pi/lanced_arch/temp.list           [for each run MACs in the respective .nettxt file are passed to temp.list for comparison with BSSID.list] 

#/home/pi/lanced_arch_processed/          [processed files are saved here under the same respective dates.] 

#/home/pi/lanced_arch_processed/{date}/   [dated folders are directly transferred under prcessed section after the sequence.] 

#/home/pi/etc/kismet/timechk             [timechk file is created after the first date correction, at the end of each run, this file is removed.] 

 

# colors 

ESC="#[" 

RESET=$ESC"39m" 

RED=$ESC"31m" 

GREEN=$ESC"32m" 

LYELLOW=$ESC"36m" 

YELLOW=$ESC"34m" 

YELLOW=$ESC"33m" 

RB=$ESC"48;5;160m" 

RESET1=$ESC"0m" 

RESETU=$ESC"24m" 

GB=$ESC"48;5;40m" 

 

 

wst1="${RB}    ${RESET1}" 

wst2="${RB}    ${RESET1}" 

gpsm="${RB}    ${RESET1}" 

gpfx="${RB}    ${RESET1}" 

dat0="${RB}    ${RESET1}" 

 

wst11="${RED}=====${RESET}" 

wst22="${RED}===========${RESET}" 

gpsmm="${RED}=====${RESET}" 

gpfxx="${RED}===========${RESET}" 

dat00="${RED}=====${RESET}" 

 

 

ledger () { 

 

cat <<-ENDOFMESSAGE 

 ${RED}_____      ______${RESET} 

${RED}/${RESET}$wst1${RED}|${RESET}$wst11${RED}/ W1 __\ ${RESET} 

${RED}\_____\    \___|   _____${RESET} 

${RED}/${RESET}$wst2 ${RED}|${RESET}$wst22${RED}/ W2 /${RESET} 

${RED}\_____\      _____\___|${RESET} 

${RED}/${RESET}$gpsm ${RED}|${RESET}$gpsmm${RED}/ GPS /${RESET} 

${RED}\_____\     \____| _____${RESET} 

${RED}/${RESET}$gpfx ${RED}|${RESET}$gpfxx${RED}/Gfix/${RESET} 

${RED}\_____\      _____\____| ${RESET} 

${RED}/${RESET}$dat0 ${RED}|${RESET}$dat00${RED}/ DATE/${RESET} 

${RED}\____/      \____/${RESET} 

ENDOFMESSAGE 

 

} 

 

if [ -n "`sudo pidof gpsd`" ]; then 

sudo pkill gpsd 

fi 

 

 

##use these later 

#FOR THE GREEN BACKGORUND BLOCK 

#echo -e "\e[48;5;40m \e[0m" 

#above line prints a single block of green on tty 

 

#init var(1-4) 

for i in `seq 1 4`; do 

  eval "var${i}=${RED}X${RESET}" 

done 

 

var5="${RED}NOT READY${RESET}" 

var6="${RED}X${RESET}" 

timeloc=/usr/local/etc/timechk 

kiss_state="`sudo pidof kismet_server`" 

chk1="${RED}[Wlan1]${RESET}" 

chk2="${RED}[Wlan2]${RESET}" 

chk3="${RED}[GPS]${RESET}" 

chk4="${RED}[GPSfix]${RESET}" 

chk5="${RED}[Date]${RESET}" 

reset 

 

##check for the kismet server if the a.sh is armed then closed, after a rerun state is fixed to armed. 

if [ -n "$kiss_state" ]; then 

      var5="${RED}ARMED${RESET}" 

fi 

 

#refresh() { 

#if [ -n "`ls -A /home/pi/lanced_logs/`" ]; then 

#   tempcalc="`ls /home/pi/lanced_logs/ | grep .nettxt`" 

#   kk="${GREEN}`cat /home/pi/lanced_logs/"$tempcalc" | grep Network | uniq | wc -l`${RESET}" 

#else 

#   kk="${GREEN}0${RESET}" 

#fi 

#} 

 

 

 

 

 

count() { 

kk="${RED}`wc -l /home/pi/lanced_arch/BSSID.list | cut -d' ' -f1`${RESET}" 

} 

 

count 

 

 

 

 

 

##check if hostapd is active or not, this option is for monitored runs and while no hostapd is needed. 

##also ip address is printed in the LANCED GUI for easy usage. 

apdip() { 

 

if [ -z "`pidof hostapd`" ]; then 

      var7="${RED}X${RESET}" 

      var8="${RED}IP${RESET}    ${RED}>${RESET} ${RED}X${RESET}" 

else 

      var7="${GREEN}OK${RESET}" 

      var8="${GREEN}`ifconfig wlan0 | grep "inet " | cut -d't' -f2 | cut -d'n' -f1 | xargs`${RESET}" 

fi 

 

} 

 

apdip 

 

 

##this is data sorter function for the LANCED. After every use, data is collected under lanced_logs is first transferred to lanced_arch 

d_sorter() { 

 

##declare 

datum="`date +%Y%m%d`" 

locA=/home/pi/lanced_logs/ 

locB=/home/pi/lanced_arch/ 

locC=/home/pi/lanced_arch/processed/ 

 

#check for dated folder /home/pi/lanced_arch/ . Multiple runs in the same day are collected under the same folder such as 20180513 

if [ ! -d "$locB""$datum" ];then 

    sudo mkdir "$locB""$datum" 

    sudo chmod 777 "$locB""$datum"/ 

fi 

 

#check for dated folder /home/pi/lanced_arch/processed/ 

if [ ! -d "$locC""$datum" ];then 

    sudo mkdir "$locC""$datum" 

    sudo chmod 777 "$locC""$datum"/ 

fi 

 

##create data count list for different dates 

sudo touch "$locB"datac.list 

sudo chmod 777 "$locB"datac.list 

 

##check for different dated files then pass it to datac.list 

echo "`ls "$locA" | grep "$datum"`" >> "$locB"datac.list 

 

##pass the dated files from lanced_logs to respective dated folder 

for i in $(cat /home/pi/lanced_arch/datac.list);do 

    #copy option 

   sudo cp "$locA"$i "$locB""$datum" 

done 

sudo rm -r "$locA"* 

 

 

##clear the datac.list 

sudo rm "$locB"datac.list 

 

 

#check for datapool file, create at /home/pi/lanced_arch/ if needed 

if [ ! -f "$locB""$datum"/datapool.txt ];then 

    sudo touch "$locB"datapool.txt 

    sudo chmod 777 "$locB"datapool.txt 

fi 

 

 

####check for temporary list, this list is used to compare with BSSID.list to keep track of unique MACs for the run. 

if [ ! -f "$locB""$datum"/templ.list ];then 

   sudo touch /home/pi/lanced_arch/templ.list 

   sudo chmod 777 /home/pi/lanced_arch/templ.list 

fi 

 

##this line gets the exact name of the .nettxt file then picks the MACs then pushed it to temprary list named templ.list 

filenom="`ls "$locB""$datum" | grep ".nettxt"`" 

echo -e "`grep "Network " "$locB""$datum"/"$filenom" | cut -d' ' -f4`" >> "$locB"templ.list 

 

##comparison is made in this for loop. For every MAC address located in templ.list, BSSID.list is checked, if no match then the MAC is unique. 

##unique MACs then passed to datapool.txt file with certain lines(line 125). Also BSSID list is populated with new unique MACs. 

for i in $(cat /home/pi/lanced_arch/templ.list);do 

if [ "`grep "$i" "$locB"BSSID.list`" == "" ];then 

test1="`grep "Network " "$locB""$datum"/"$filenom" | grep "$i"`" 

                sed -n "/$test1/,/Network /{/$test1/{p};/Network /{d};p}" "$locB""$datum"/"$filenom" >> "$locB"datapool.txt 

echo -e "$i" >> /home/pi/lanced_arch/BSSID.list 

 

    fi 

done 

 

##temporary list is cleared. 

sudo rm /home/pi/lanced_arch/templ.list 

 

##moving the processed dated folder under lanced_arch to processed folder under lanced_arch 

sudo mv -v /home/pi/lanced_arch/"$datum"/* /home/pi/lanced_arch/processed/"$datum"/ 1>/dev/null 

 

count 

 

} 

 

 

##device probe function 

components_chk() { 

clear 

ledger 

if [ "`iwconfig 2>&1 | sed -n -e 's/wlan1     //p'| cut --bytes=1`" == "I" ]; then 

#if [ "`iwconfig wlan1 | cut -d' ' -f1 | xargs`" == "wlan1" ]; then 

#if [ "`iwconfig wlan1: | cut -d':' -f1 | cut -d' ' -f1 | xargs`" == "wlan1" ]; then 

#	chk1="${GREEN}[Wlan1]${RESET}" 

#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

  wst11="${GREEN}=====${RESET}" 

  clear 

  ledger 

  sleep 1 

  wst1="${GB}    ${RESET1}" 

  clear 

  ledger 

  var1="${GREEN}OK${RESET}" 

elif [ "`iwconfig 2>&1 | sed -n -e 's/wlan1     //p'| cut --bytes=1`" != "I" ];then 

#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

var1="${RED}X${RESET}" 

 

fi 

 

if [ "`iwconfig 2>&1 | sed -n -e 's/wlan2     //p' | cut --bytes=1`" == "I" ]; then 

#if [ "`iwconfig wlan2 | cut -d' ' -f1 | xargs`" == "wlan2" ]; then 

#if [ "`iwconfig wlan2: | cut -d':' -f1 | cut -d' ' -f1 | xargs`" == "wlan2" ]; then 

#	chk2="${GREEN}[Wlan2]${RESET}" 

#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

  clear 

  ledger 

  wst22="${GREEN}===========${RESET}" 

  sleep 1 

  wst2="${GB}    ${RESET1}" 

  clear 

  ledger 

var2="${GREEN}OK${RESET}" 

elif [ "`iwconfig 2>&1 | sed -n -e 's/wlan2     //p'| cut --bytes=1`" != "I" ];then 

#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

var2="${RED}X${RESET}" 

fi 

 

if [ "`dmesg | grep "pl2303 converter now attached to ttyUSB0" | cut -d':' -f2 | xargs`" == "pl2303 converter now attached to ttyUSB0" ]; then 

#	chk3="${GREEN}[GPS]${RESET}" 

#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

  clear 

  ledger 

  gpsmm="${GREEN}=====${RESET}" 

  gpfxx="${GREEN}===========${RESET}" 

  dat00="${GREEN}===========${RESET}" 

  clear 

  ledger 

  sleep 1 

  clear 

  ledger 

  gpsm="${GB}    ${RESET1}" 

var3="${GREEN}OK${RESET}" 

 

else 

#	echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

var3="${RED}X${RESET}" 

#	gpsd -b -n tcp://172.24.1.150:50000 

#	return 1 

fi 

 

testv=`ping -c 1 -w 1 172.24.1.150 | grep ttl` 

if [ -n "$testv" ]; 

    then 

    clear 

    ledger 

    gpsmm="${GREEN}=====${RESET}" 

    clear 

    ledger 

    sleep 1 

    gpsm="${GB}    ${RESET1}" 

    clear 

    ledger 

    sleep 1 

    gpfxx="${GREEN}===========${RESET}" 

    clear 

    ledger 

    sleep 1 

    dat00="${GREEN}=====${RESET}" 

    clear 

    ledger 

    sleep 1 

    gpsd -b -n tcp://172.24.1.150:50000 

    var3="${GREEN}OK${RESET}" 

else 

    return 1 

fi 

 

if [ "`timeout 6 gpspipe -w -n 5 | cut -d',' -f3 | grep mode | cut -d':' -f2`" != "3" ]; then 

    return 1 

fi 

 

while true ; do 

   if [ "`gpspipe -w -n 5 | cut -d',' -f3 | grep mode | cut -d':' -f2`" == "3" ]; then 

 #     chk3="${GREEN}[GPS]${RESET}" 

 #     chk4="${GREEN}[GPSfix]${RESET}" 

 #     echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

#      gpsm="${GB}    ${RESET1}" 

      var3="${GREEN}OK${RESET}" 

      var4="${GREEN}OK${RESET}" 

      gpfx="${GB}    ${RESET1}" 

      clear 

      ledger 

      sleep 1 

if [ ! -f "$timeloc"  ]; then 

           #correcttime 

           correcttime > /dev/null 2>&1 

 #  chk5="${GREEN}[Date]${RESET}" 

   #        echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

 

           dat0="${GB}    ${RESET1}" 

           clear 

           ledger 

           sleep 1 

 

           var5="${GREEN}READY${RESET}" 

   sudo touch "$timeloc" 

        else 

 #  chk5="${GREEN}[Date]${RESET}" 

   #        echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

           dat0="${GB}    ${RESET1}" 

           clear 

           ledger 

           sleep 1 

           var5="${GREEN}READY${RESET}" 

        fi 

      break 

   else 

      chk4="${RED}[GPSfix]${RESET}" 

   #   echo -ne "$chk1$chk2$chk3$chk4$chk5\r" 

   fi 

done 

 

##check WLAN1 WLAN2 GPS GPSfix 

if [ "$var1" == "${GREEN}OK${RESET}" ] && [ "$var2" == "${GREEN}OK${RESET}" ] && [ "$var3" == "${GREEN}OK${RESET}" ] && [ "$var4" == "${GREEN}OK${RESET}" ]; then 

      var5="${GREEN}READY${RESET}" 

elif [ "$var1" == "${GREEN}OK${RESET}" ] && [ "$var2" == "${RED}X${RESET}" ] && [ "$var3" == "${GREEN}OK${RESET}" ] && [ "$var4" == "${GREEN}OK${RESET}" ]; then 

      var5="${GREEN}READY${RESET}" 

 

else 

 var5="${RED}MISSING MODULE(s)${RESET}" 

 echo -e "\n${RED}reprobe needed${RESET}" 

 sleep 1 

 return 1 

fi 

if [ -z "`pidof hostapd`" ]; then 

      var7="${RED}X${RESET}" 

      var8="${RED}IP${RESET}    ${RED}>${RESET} ${RED}X${RESET}" 

else 

      var7="${GREEN}OK${RESET}" 

      #ifconfig wlan0 | grep "inet " | cut -d't' -f2 | cut -d'n' -f1 | xargs 

      var8="${GREEN}`ifconfig wlan0 | grep "inet " | cut -d't' -f2 | cut -d'n' -f1 | xargs`${RESET}" 

fi 

 

 

 

} 

 

#clock () { 

 

#while [1];do ledger;printf "\33[A";sleep 1;done 

 

#} 

#var5="${RED}READY${RESET}" 

##LANCED menu 

while : 

do 

    #clear 

    reset 

    cat<<EOF 

`echo -e "${RED}  _                  _   _   ____   _____  ____ ${RESET}"` 

`echo -e "${RED} | |         /\     | \ | | / ___| |___ / |  _ \ ${RESET}"` 

`echo -e "${RED} | |        /  \    |  \| || |       |_ \ | | | | ${RESET}"` 

`echo -e "${RED} | |___ _  / /\ \  _| |\  || |___ _ ___) || |_| |${RESET}"` 

`echo -e "${RED} |_____(${RESET}${RB} ${RESET1}${RED})/______\(${RESET}${RB} ${RESET1}${RED})_| \_(${RESET}${RB} ${RESET1}${RED})____(${RESET}${RB} ${RESET1}${RED})____(${RESET}${RB} ${RESET1}${RED})____(${RESET}${RB} ${RESET1}${RED})${RESET}"` 

 ${RED} _____      _____ ${RESET}   ${RED}__________________${RESET} 

${RED}//     \\${RESET}${RED}MENU${RESET}${RED}/     \\\\${RESET}  ${RED}\\${RESET}${RB}                ${RESET1}${RED}/${RESET} 

${RB} ${RESET1} ${RED}Device Probe${RESET} ${RED}[1]${RESET} ${RB} ${RESET1}   ${RED}\\${RESET}${RB}              ${RESET1}${RED}/${RESET} 

${RB} ${RESET1} ${RED}Quick Start${RESET}  ${RED}[2]${RESET} ${RB} ${RESET1}    ${RED}\\${RESET}  `printf "%-20s\n" "$var5"`${RED}/${RESET} 

${RB} ${RESET1} ${RED}ARM${RESET}          ${RED}[3]${RESET} ${RB} ${RESET1}     ${RED}\\${RESET}${RB}          ${RESET1}${RED}/${RESET} 

${RB} ${RESET1} ${RED}DISARM${RESET}       ${RED}[4]${RESET} ${RB} ${RESET1}      ${RED}\\${RESET}${RB}        ${RESET1}${RED}/${RESET} 

${RB} ${RESET1} ${RED}Quit${RESET}         ${RED}[Q]${RESET} ${RB} ${RESET1}       ${RED}\\${RESET}${RB}      ${RESET1}${RED}/${RESET} 

${RED}\\${RESET}${RED}\\${RESET}${RED}________________/${RESET}${RED}/${RESET}        ${RED}\\${RESET}${RB}    ${RESET1}${RED}/${RESET} 

${RED}Total APs >${RESET} `printf "%-20s\n" "$kk"`       ${RED}\\${RESET}${RB}  ${RESET1}${RED}/${RESET} 

`printf "%-31s\n" "$var8"`         ${RED}\\/${RESET} 

`ledger` 

 

 

 

 

 

 

EOF 

 

##while [ 1 ];do date;printf "\33[A";sleep 1;done 

 

##start function uses kismet_server 

start_ks() { 

#refresh 

#create a file named by YearMonthDay 

#sudo mkdir /home/pi/lanced_logs/"`date +%Y%m%d`" 

if [ "$var5" == "${GREEN}READY${RESET}" ];then 

/usr/local/bin/kismet_server --daemonize > /dev/null 2>&1 

var5="${RED}ARMED${RESET}" 

sleep 2 

else 

echo "${RED}!!!probe the devices!!!${RESET}" 

return 1 

fi 

 

} 

 

 

##stop function kills kismet_server then after 3 seconds sorts the data using d_sorter function 

stop_ks() { 

 

sudo killall kismet_server 

sleep 3 

if [ -z "$(ls -A /home/pi/lanced_logs)" ]; then 

return 1 

else 

    d_sorter 

    sleep 5 

fi 

if [ -n "`pidof gpsd`" ]; then 

        sudo pkill gpsd 

fi 

var5="${GREEN}UNARMED${RESET}" 

 

} 

 

 

##start function for selection 2. first the components are probed, then the kismet_server is run 

q_start() { 

components_chk 

start_ks 

return 1 

} 

 

 

    read -n1 -s 

    case "$REPLY" in 

    "1")  components_chk ;; 

    "2")  q_start  ;; 

    "3")  start_ks ;; 

    "4")  stop_ks  ;; 

#    "r")  refresh ;; 

    "Q")  sudo rm "$timeloc" 2>/dev/null 

  reset 

          exit 

                  ;; 

    "q")  sudo rm "$timeloc" 2>/dev/null 

  reset 

 	  exit 

  ;; 

     * )  echo "invalid option"  ;; 

    esac 

    sleep 1 

done 

 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 

 

 

 

###SETTING blue_hydra ### 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 

sudo git clone https://github.com/pwnieexpress/blue_hydra 

echo "ok!" 

 

sudo apt-get install bluez -y 

sudo apt-get install bluez-test-scripts -y 

sudo apt-get install pyhton-bluez -y 

sudo apt-get install python-dbus -y 

sudo apt-get install sqlite3 -y 

sudo apt-get install libsqlite3-dev -y 

sudo apt-get install ruby-dev bundler -y 

 

echo "ok!" 

 

 

cd blue_hydra/ 

sudo bundler 

sudo bundle install 

 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 

 

 

 

 

 

 

 

 

 

 

 

##SETTING ppp0 AS BRIDGED CONNECTION### 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward" 

 

#setting ipv4 forward option to 1 in here 

sudo nano /etc/sysctl.conf 

 

#iptables rulez 

sudo iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE 

sudo iptables -A FORWARD -i ppp0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 

sudo iptables -A FORWARD -i wlan0 -o ppp0 -j ACCEPT 

 

##to save iptables rules we set to run for each reboot 

sudo sh -c "iptables-save > /etc/iptables.ipv4.nat" 

 

##change rc.local file 

sudo nano /etc/rc.local 

above 0 add this line 

iptables-restore < /etc/iptables.ipv4.nat 

 

 

sudo service hostapd start 

sudo service dnsmasq start 

 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 

 

 

 

 

 

 

###GQRX SETUP for RPi3### 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 sudo wget https://github.com/csete/gqrx/releases/download/v2.11.5/gqrx-sdr-2.11.5-linux-rpi3.tar.xz 

sudo tar -xf gqrx-sdr-2.11.5-linux-rpi3.tar.xz 

sudo apt install gnuradio libvolk1-bin libusb-1.0-0 gr-iqbal 

sudo apt install qt5-default libqt5svg5 libportaudio2 

cd gqrx-sdr-2.11.5-linux-rpi3/ 

sudo cp udev/*.rules /etc/udev/rules.d/ 

##done here run gqrx for testing 

./gqrx 

 

====================================================================================================== 

====================================================================================================== 

====================================================================================================== 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

#!/bin/bash 

#author : rektosauruz 

#version : v3.2 

#definition : G.I.T.S. - Ghost In The Shell - A shell framework 

##ssh manager included 

 

### | Declerations          | ====================================================# 

# Color Declerations 

ESC="#[" 

RESET=$ESC"39m" 

RED=$ESC"31m" 

GREEN=$ESC"32m" 

LBLUE=$ESC"36m" 

BLUE=$ESC"34m" 

BLACK=$ESC"30m" 

YELLOW=$ESC"33m" 

 

#[*] Status Indicator with different colors. 

RLS=${RED}"[*]"${RESET} 

BLS=${BLUE}"[*]"${RESET} 

GLS=${GREEN}"[*]"${RESET} 

RES=${RED}"[!]"${RESET} 

 

 

 

##################!  MENU  !################## 

while : 

do 

    clear 

    cat<<EOF 

    `echo -e "${BLUE}==========================${RESET}${RED}=========================${RESET}${YELLOW}======================${RESET}"` 

    `echo -e "       ${BLUE}_               _${RESET}    ${RED}_       _   _                ${YELLOW}_          _ _${RESET} "` 

    `echo -e "  ${BLUE}__  | |__   ___  ___| |_${RESET} ${RED}(_)_ __ | |_| |__   ___   ${YELLOW}___| |__   ___| | |${RESET}"` 

    `echo -e " ${BLUE}/ _\_| '_ \ / _ \/ __| __${RESET} ${RED}| | '_ \| __| '_ \ / _ \ ${YELLOW}/ __| '_ \ / _ \ | |${RESET}"` 

    `echo -e "${BLUE}| (_| | | | | (_) \__ \ |_${RESET} ${RED}| | | | | |_| | | |  __/ ${YELLOW}\__ \ | | |  __/ | |${RESET}"` 

    `echo -e " ${BLUE}\__, |_| |_|\___/|___/\__${RESET} ${RED}|_|_| |_|\__|_| |_|\___|${YELLOW} |___/_| |_|\___|_|_|${RESET}"` 

    `echo -e " ${BLUE}|___/${RESET}                                       													 "` 

    `echo "${BLUE}==========================${RESET}${RED}=========================${RESET}${YELLOW}======================${RESET}"` 

    ${GREEN}=========================================================================${RESET} 

    `echo -e "${YELLOW}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<${RESET}${RED}  ${BLUE}G.${RESET}${RED}I.T.${RESET}${YELLOW}S.${RESET}${YELLOW} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${RESET}"` 

    `echo -e "${YELLOW}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<${RED} MAIN MENU${RESET} ${YELLOW}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${RESET}"` 

    ${GREEN}=========================================================================${RESET} 

    |${GREEN} [001] Line_Calculator${RESET}  ||| ${GREEN}[007] CryptoPaRseR${RESET}  ||| ${GREEN}[00n] NSlookup${RESET}  | 

    |${GREEN} [002] IPtables_BLK${RESET}     ||| ${GREEN}[008] Scan_ipv4${RESET}     ||| ${GREEN}[00v] Rec_V${RESET}     | 

    |${GREEN} [003] NetCaT${RESET}           ||| ${GREEN}[009] Conn_ChecK${RESET}    ||| ${GREEN}[00a] Rec_A${RESET}     | 

    |${GREEN} [004] MD5${RESET}              ||| ${GREEN}[00l] Ipv4_ChecK${RESET}    ||| ${GREEN}[00c] Rec_C${RESET}     | 

    |${GREEN} [005] SHA-256 ${RESET}         ||| ${GREEN}[00w] Whois     ${RESET}    ||| ${GREEN}[00s] SSH${RESET}       | 

    |${GREEN} [006] TaR/UnTaR${RESET}        ||| ${GREEN}[00d] DNS_L_Test${RESET}    ||| ${GREEN}[00p] Vpn${RESET}       | 

  ${RED}(q)uit${RESET}${GREEN}=====================================================================${RESET} 

 

EOF 

##################!  MENU  !################## 

 

 

 

 

 

 

md5() { 

 

echo "please give the string to be converted to md5 format / Q to quit" 

read u_input 

if [ "$u_input" == "Q" ]; 

then 

return 1 

else 

echo "md5 of $u_input : `echo -n "$u_input" | md5sum`" 

sleep 1 

echo "md5 of $u_input : `echo -n "$u_input" | md5sum`" >> "$default_out"md5.txt 

    fi 

 

} 

 

 

 

sha256() { 

 

echo "please give the string to be converted to md5 format / Q to quit" 

read u_input 

if [ "$u_input" == "Q" ]; 

then 

return 1 

else 

echo "sha256 of $u_input : `echo -n "$u_input" | sha256sum`" 

sleep 1 

echo "sha256 of $u_input : `echo -n "$u_input" | sha256sum`" >> "$default_out"sha256.txt 

fi 

} 

 

 

 

nc_manager() { 

 

echo  "<SEND>     1" 

echo  "<RECEIVE>  2" 

echo  "<QUIT>     Q" 

read user_c 

 

case "$user_c" in 

   "1") echo "ip / port / file" 

        read ipaddr 

        read port 

        read file 

        nc -nv $ipaddr $port < $file 

   ;; 

   "2") echo "port / file" 

        read port 

        read file 

        nc -nvlp $port > $file 

   ;; 

   "Q") return 1 #exit 0 

   ;; 

   "q") return 1 #exit 0 

   ;; 

   *) echo "use defined values, ending the program now." 

   ;; 

esac 

 

} 

 

 

 

line_calc() { 

 

#get the first parameter if not exist then ask for the directory 

if [ -z "$1" ]; then 

    echo "please give the path to directory / Enter "Q" to abort" 

    read user_input 

    path=$user_input 

else 

    path=$1 

fi 

 

if [ "$user_input" = "Q" ]; then 

    #exit 0 

    return 1 

fi 

 

#create the temporary file for listing the sub folders and files 

touch /root/filenames.txt 

chmod 755 /root/filenames.txt 

temp=/root/filenames.txt 

find $path | cat >> $temp ##/root/filenames.txt 

 

#define a counter for the line count 

inc=0 

sum=0 

total=0 

 

#loop for the wc -l command to read from the temporary file 

for ccb in $(cat $temp); do 

    fl_count=$(wc -l $ccb 2> /dev/null | cut -d ' ' -f1) 

    sum=$fl_count 

    total=$(( sum + total + 1 )) 

done 

 

echo "total number of lines in $path = $total" 

rm $temp 

sleep 2 

} 

 

 

 

iptables_blk() { 

 

#first line is to get the address to be blocked. 

echo "please input the IP address to be blocked / Enter "Q" to abort" 

read blk_addr 

if [ "$blk_addr" = "Q" ]; then 

    #exit 0 

    return 1 

fi 

 

iptables -I INPUT -s $blk_addr -j DROP 

iptables -I OUTPUT -s $blk_addr -j DROP 

iptables -I FORWARD -s $blk_addr -j DROP 

iptables-save > /etc/iptables.conf 

 

} 

 

 

 

tar_archiever() { 

 

echo  "<PacK>     1" 

echo  "<UnPacK>   2" 

echo  "<QUIT>     Q" 

read user_c 

 

case "$user_c" in 

   "1") echo "name the packed file" 

        read file_p1 

        echo "path/file_name" 

        read file_p2 

        tar -czvf /root/Desktop/"$file_p1".tar.gz --directory "$file_p2" . 

 

   ;; 

   "2") echo "path/filename" 

        read file_p3 

        tar -xzvf "$file_p3" -C /root/Desktop 

   ;; 

   "Q") return 1 #exit 0 

   ;; 

   *) echo "use defined values, ending the program now." 

   ;; 

esac 

 

} 

 

 

 

function scan_last_two() { 

 

for ipv4_4 in $(seq 1 255); do 

ping -c 1 192.168.1.$ipv4_4 | grep "ttl=" | cut -d" " -f4 & 

done 

sleep 4 

 

} 

 

 

 

 

test_connection() { 

 

testv=`ping -c 1 -w 1 8.8.8.8 | grep ttl` 

    if [ -z "$testv" ]; 

        then 

        echo "Internet Connection is ${RED}DOWN${RESET}" 

        sleep 1 

        return 1 

    else 

        echo "Internet Connection is ${GREEN}UP${RESET}" 

        sleep 1 

        return 1 

    fi 

 

} 

 

 

 

Ipv4_chk() { 

echo "your IP is ${GREEN}`ifconfig wlan0 | grep "inet " | cut -d't' -f2 | cut -d'n' -f1`${RESET}" 

sleep 1 

return 1 

} 

 

 

 

 

 

 

 

#nslookup function will be added laterz 

lookup () { 

 

echo -e "input the address / Q to exit" 

read que 

if [ "$que" == "Q" ]; 

then 

return 1 

else 

nslookup "$que" >> "$default_out"nslookup.txt 

fi 

 

} 

 

 

 

who_is() { 

 

echo -e "IP addr lookup / Q to exit" 

read iaddr 

if [ "$iaddr" == "Q" ]; 

then 

return 1 

else 

    whois "$iaddr" >> "$default_out"whois.txt 

fi 

 

} 

 

 

 

ssh_connect () { 

 

echo -e "[hostname/ip/port] / q to exit" 

echo -e "hostname ?" 

read uissh1 

if [ "$uissh1" == "q" ]; 

then 

   return 1 

    fi 

echo -e "ip ?" 

read uissh2 

if [ "$uissh2" == "q" ]; 

then 

   return 1 

fi 

echo -e "port ?" 

read uissh3 

if [ "$uissh3" == "q" ]; 

then 

   return 1 

fi 

 

ssh "$uissh1"@"$uissh2" -p "$uissh3" 

 

} 

 

 

 

 

 

 

 

 

 

 

 

 

    read -n1 -s 

    case "$REPLY" in 

#    "1")  sh /Desktop/GITS/linecalculator_v05.sh ;; 

    "1")  line_calc ;; 

#   "2")  sh /Desktop/GITS/fw_entry.sh ;; 

    "2")  iptables_blk ;; 

#    "3")  sh /Desktop/GITS/nc_manager.sh ;; 

    "3")  nc_manager ;; 

#    "4")  sh /Desktop/GITS/md5c.sh ;; 

    "4")  md5 ;; 

#    "5")  sh /Desktop/GITS/sha256c.sh ;; 

    "5")  sha256 ;; 

    "6")  tar_archiever ;; 

    "8")  scan_last_two  ;; 

    "9")  test_connection ;; 

    "l")  Ipv4_chk ;;      

    "w")  who_is ;; 

    "s")  ssh_connect ;; 

    "n")  lookup ;; 

    "q")  exit                      ;; 

#    "q")  echo "case sensitive!!"   ;; 

     * )  echo "invalid option"     ;; 

    esac 

    sleep 1 

done 

 

 

==================================================================== 

 

 

 

#!/bin/bash 

 

 

#/home/pi/lncd_arch/datapool_db.txt 

 

 

network_log() { 

 

BSSID="`grep "Network" <<< "$1" | cut -d' ' -f4`" 

manuf="`grep "Manuf" <<< "$1" | cut -d':' -f2 | xargs`" 

first_seen="`grep -m 1 "First" <<< "$1" | cut -d':' -f2-4 | xargs`" 

last_seen="`grep -m 1 "Last" <<< "$1" | cut -d':' -f2-4 | xargs`" 

type="`grep -m 1 "Type" <<< "$1" | cut -d':' -f2 | xargs`" 

SSID="`grep -m 1 "SSID       :" <<< "$1" | cut -d':' -f2 | xargs`" 

Beacon="`grep -m 1 "Beacon" <<< "$1" | cut -d':' -f2 | xargs`" 

packets="`grep -m 1 "Packets" <<< "$1" | cut -d':' -f2 | xargs`" 

WPS="`grep -m 1 "WPS" <<< "$1" | cut -d':' -f2 | xargs`" 

encryption="`grep -m 1 "Encryption" <<< "$1" | cut -d':' -f2 | xargs`" 

WPA_ver="`grep -m 1 "WPA Version" <<< "$1" | cut -d':' -f2 | xargs`" 

channel="`grep -m 1 "Channel" <<< "$1" | cut -d':' -f2 | xargs`" 

frequency="`grep -m 1 "Frequency" <<< "$1" | cut -d' ' -f5,9 | xargs`" 

max_seen_packets="`grep -m 1 "Max Seen" <<< "$1" | cut -d':' -f2 | xargs`" 

LLC="`grep -m 1 "LLC" <<< "$1" | cut -d':' -f2 | xargs`" 

data="`grep -m 1 "Data" <<< "$1" | cut -d':' -f2 | xargs`" 

crypt="`grep -m 1 "Crypt" <<< "$1" | cut -d':' -f2 | xargs`"  

fragments="`grep -m 1 "Fragments" <<< "$1" | cut -d':' -f2 | xargs`" 

retries="`grep -m 1 "Retries" <<< "$1" | cut -d':' -f2 | xargs`"  

total="`grep -m 1 "Total" <<< "$1" | cut -d':' -f2 | xargs`"  

datasize="`grep -m 1 "Datasize" <<< "$1" | cut -d':' -f2 | xargs`"  

min_position="`grep -m 1 "Min Pos" <<< "$1" | cut -d':' -f2 | xargs`" 

max_position="`grep -m 1 "Max Pos" <<< "$1" | cut -d':' -f2 | xargs`" 

peak_position="`grep -m 1 "Peak Pos" <<< "$1" | cut -d':' -f2 | xargs`"  

avg_position="`grep -m 1 "Avg Pos" <<< "$1" | cut -d':' -f2 | xargs`"  

last_BSSTS="`grep -m 1 "Last BSSTS" <<< "$1" | cut -d':' -f2-4 | xargs`"  

seen_by="`grep -m 1 "Seen By" <<< "$1" | cut -d' ' -f8 | xargs`" 

 

echo "$BSSID,$manuf,$first_seen,$last_seen,$type,$SSID,$Beacon,$packets,$WPS,$encryption,$WPA_ver,$channel,$frequency,$max_seen_packets,$LLC,$data,$crypt,$fragments,$retries,$total,$datasize,$min_position,$max_position,$peak_position,$avg_position,$last_BSSTS,$seen_by" 

 

} 

 

 

client_log() { 

 

c_network_id="`head -1 <<< "$test1" | cut -d' ' -f4`" 

c_mac="`grep "Client" <<< "$1" | cut -d' ' -f5`" 

c_manuf="`grep "Manuf" <<< "$1" | cut -d':' -f2 | xargs`" 

c_first_seen="`grep -m 1 "First" <<< "$1" | cut -d':' -f2-4 | xargs`" 

c_last_seen="`grep -m 1 "Last" <<< "$1" | cut -d':' -f2-4 | xargs`" 

c_type="`grep -m 1 "Type" <<< "$1" | cut -d':' -f2 | xargs`" 

c_channel="`grep -m 1 "Channel" <<< "$1" | cut -d':' -f2 | xargs`" 

c_frequency="`grep -m 1 "Frequency" <<< "$1" | cut -d' ' -f6,10 | xargs`" 

c_max_seen="`grep -m 1 "Max Seen" <<< "$1" | cut -d':' -f2 | xargs`" 

c_carrier="`grep -m 1 "Carrier" <<< "$1" | cut -d':' -f2 | xargs`" 

c_encoding="`grep -m 1 "Encoding" <<< "$1" | cut -d':' -f2 | xargs`" 

c_LLC="`grep -m 1 "LLC" <<< "$1" | cut -d':' -f2 | xargs`" 

c_data="`grep -m 1 "Data" <<< "$1" | cut -d':' -f2 | xargs`" 

c_crypt="`grep -m 1 "Crypt" <<< "$1" | cut -d':' -f2 | xargs`" 

c_fragments="`grep -m 1 "Fragments" <<< "$1" | cut -d':' -f2 | xargs`" 

c_retries="`grep -m 1 "Retries" <<< "$1" | cut -d':' -f2 | xargs`" 

c_total="`grep -m 1 "Total" <<< "$1" | cut -d':' -f2 | xargs`" 

c_datasize="`grep -m 1 "Datasize" <<< "$1" | cut -d':' -f2 | xargs`" 

c_min_position="`grep -m 1 "Min Pos" <<< "$1" | cut -d':' -f2 | xargs`" 

c_max_position="`grep -m 1 "Max Pos" <<< "$1" | cut -d':' -f2 | xargs`" 

c_peak_position="`grep -m 1 "Peak Pos" <<< "$1" | cut -d':' -f2 | xargs`" 

c_avg_position="`grep -m 1 "Avg Pos" <<< "$1" | cut -d':' -f2 | xargs`" 

c_seen_by="`grep -m 1 "Seen By" <<< "$1" | cut -d' ' -f9 | xargs`" 

 

 

echo "$c_network_id,$c_mac,$c_manuf,$c_first_seen,$c_last_seen,$c_type,$c_channel,$c_frequency,$c_max_seen,$c_LLC,$c_carrier,$c_encoding,$c_data,$c_crypt,$c_fragments,$c_retries,$c_total,$c_datasize,$c_min_position,$c_max_position,$c_peak_position,$c_avg_position,$c_seen_by" 

} 

 

 

 

 

 

clientparser() { 

 

loop_count="`grep -n "Client" <<< $test1 | wc -l`" 

segment_Client_line_index="`grep -n "Client" <<< $test1 | cut -d':' -f1`" 

l_index="`tail -1 <<< $segment_Client_line_index`" 

 

 

if [ "$loop_count" == "1" ]; then 

 

condition_client_p="`tail --lines=+"$segment_Client_line_index" <<< $test1`" 

client_log "$condition_client_p" >> /home/pi/Desktop/clients.txt 

 

else 		 

loop_count=$((loop_count-1)) 

 

for i in `seq 1 $loop_count`; do 

 

f_line="`sed "${i}q;d" <<< $segment_Client_line_index`" 

let i++ 

s_line="`sed "${i}q;d" <<< $segment_Client_line_index`" 

client_p="`awk -v s="$f_line" -v e="$s_line" 'NR>=s&&NR<e' <<< $test1`" 

client_log "$client_p" >> /home/pi/Desktop/clients.txt 

 

done 

 

client_p_last="`tail --lines=+"$l_index" <<< $test1`" 

client_log "$client_p_last" >> /home/pi/Desktop/clients.txt 

 

fi 

 

} 

 

 

 

f_index_line="`cat /home/pi/lncd_arch/datapool_db.txt | grep "Network " | cut -d':' -f1 | cut -d' ' -f2 | sed '1q;d'`" 

l_index_line="`cat /home/pi/lncd_arch/datapool_db.txt | grep "Network " | cut -d':' -f1 | cut -d' ' -f2 | wc -l`" 

l_index_line=$((l_index_line-1)) 

 

 

for i in `seq 1 $l_index_line`; do 

 

val1="`cat /home/pi/lncd_arch/datapool_db.txt | grep "Network " | cut -d':' -f1 | sed "${i}q;d"`" 

let "i++" 

val2="`cat /home/pi/lncd_arch/datapool_db.txt | grep "Network " | cut -d':' -f1 | sed "${i}q;d"`" 

test1="`cat /home/pi/lncd_arch/datapool_db.txt | sed -n "/${val1}:/,/${val2}:/{/${val2}:/b;p}"`" 

network_cid="`head -1 <<< "$test1" | cut -d' ' -f4`" 

network_p="`sed -n "/Network /,/Client /{/Client /b;p}" <<< "$test1"`" 

network_log "$network_p" >> /home/pi/Desktop/networks.txt 

clientparser 

 

done 

 

 

last_network_index="`cat /home/pi/lncd_arch/datapool_db.txt | grep -n "Network " | tail -1 | cut -d':' -f1`" 

network_p_last="`cat /home/pi/lncd_arch/datapool_db.txt | tail --lines=+"$last_network_index"`" 

last_network_p="`sed -n "/Network /,/Client /{/Client /b;p}" <<< "$network_p_last"`" 

network_log "$network_p_last" >> /home/pi/Desktop/networks.txt 

 

test1=$network_p_last 

clientparser

