#!/bin/bash

BASE_DIR="~"
DEBIAN_RELEASE="bookworm"

echo "#############################################"
echo "#         Kali Pentest Setup Script         #"
echo "#  - installs various tools and scripts     #"
echo "#############################################"
if [ "$(id -u)" -ne 0 ]; then  
  echo "Das Script muss mit Sudo ausgeführt werden!"
  exit 1
fi
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt update -y && sudo apt upgrade -y 
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $DEBIAN_RELEASE stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt -y install dirsearch python3-impacket python3-pip python3-venv seclists curl enum4linux feroxbuster impacket-scripts flameshot nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf bloodhound zenmap-kbx checksec gdb docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin pipx
pipx ensurepath
pipx install git+https://github.com/Tib3rius/AutoRecon.git
cd /usr/share/wordlists
gunzip rockyou.txt.gz
mkdir $BASE_DIR/tools
echo "#!/bin/bash" > $BASE_DIR/simpleHTTPServer.sh
echo "python3 -m http.server 80 --directory $BASE_DIR/tools" >> $BASE_DIR/simpleHTTPServer.sh
chmod u+x $BASE_DIR/simpleHTTPServer.sh
cp /usr/share/doc/python3-impacket/examples/smbserver.py $BASE_DIR
echo "#!/bin/bash" > $BASE_DIR/smbserver.sh
echo "python3 smbserver.py tools $BASE_DIR/tools" >> $BASE_DIR/smbserver.sh
chmod u+x $BASE_DIR/smbserver.sh
mkdir $BASE_DIR/git
cd $BASE_DIR/git
git clone https://github.com/61106960/adPEAS
git clone https://github.com/carlospolop/PEASS-ng
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh > $BASE_DIR/tools/linpeas.sh
chmod u+x $BASE_DIR/tools/linpeas.sh
cp ./PEASS-ng/winPEAS/winPEASexe/binaries/x86/Release/winPEASx86.exe $BASE_DIR/tools
cp ./PEASS-ng/winPEAS/winPEASexe/binaries/x64/Release/winPEASx64.exe $BASE_DIR/tools
cp ./PEASS-ng/winPEAS/winPEASbat/winPEAS.bat $BASE_DIR/tools
git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries
cp ./Ghostpack-CompiledBinaries/*.exe $BASE_DIR/tools
git clone https://github.com/TarlogicSecurity/kerbrute kerbrute_tarlogic
git clone https://github.com/ropnop/kerbrute kerbrute_ropnop
git clone https://github.com/3gstudent/pyKerbrute
git clone https://github.com/diego-treitos/linux-smart-enumeration
cp ./linux-smart-enumeration/lse.sh $BASE_DIR/tools # Local PE Enumaration (Linux)
gem install evil-winrm
git clone https://github.com/rezasp/joomscan.git  # Scanner for Joomla CMS
git clone https://github.com/D35m0nd142/LFISuite  # Local File Inclusion Exploitation
git clone https://github.com/capture0x/LFI-FINDER # Local File Inclusion Detector
git clone https://github.com/ParrotSec/mimikatz
git clone https://github.com/mertdas/PrivKit # Windows PE vulnerabilities detector
git clone https://github.com/cddmp/enum4linux-ng  # SMB / Domain Enumaration Script
git clone https://github.com/anouarbensaad/vulnx  # CMS Detector
git clone https://github.com/blackhatethicalhacking/Nucleimonst3r.git # Webscanner for Bug Bounty Hunters
git clone https://github.com/stanislav-web/OpenDoor # Multifunctional website scanner
pipx install one-lin3r # Reverse Shell Oneliners
git clone https://github.com/AzeemIdrisi/PhoneSploit-Pro.git # Android Phone Exploitation via ADB with Metasploit
git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester
git clone https://github.com/liamg/traitor # Automatic Linux Local PE exploiter
git clone https://github.com/HacktivistRO/ExtFilterBuster # File Upload Restriction Bypass
git clone https://github.com/kgretzky/evilginx2 # Man-in-the-Middle Attack Framework
git clone https://github.com/rebootuser/LinEnum # Linux Local PE script
cp ./LinEnum/LinEnum.sh $BASE_DIR/tools
wget https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh -O $BASE_DIR/tools/linux-exploit-suggester.sh
chmod u+x $BASE_DIR/tools/linux-exploit-suggester.sh
git clone https://github.com/SecWiki/windows-kernel-exploits # Precompiled Windows Kernel Exploits
git clone https://github.com/longld/peda.git ~/peda
git clone https://github.com/scipag/vulscan scipag_vulscan
sudo ln -s `pwd`/scipag_vulscan /usr/share/nmap/scripts/vulscan
git clone https://github.com/lefayjey/linWinPwn # Automatic AD enumeration and exploitation
git clone https://github.com/Octoberfest7/TeamsPhisher # Phishing tool to attack MS Teams
cd linWinPwn
chmod u+x install.sh
./install.sh
cd ..
echo "source ~/peda/peda.py" >> ~/.gdbinit
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_386 -o $BASE_DIR/tools/kerbrute_linux_386
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 -o $BASE_DIR/tools/kerbrute_linux_amd64
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_windows_386.exe -o $BASE_DIR/tools/kerbrute_windows_386
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_windows_amd64.exe -o $BASE_DIR/tools/kerbrute_windows_amd64
pipx install ropgadget
updatedb
echo "################################################"
echo "#                     DONE!                    #"
echo "#  Things to do:                               #"
echo "#  You may want to install OpenVAS Greenbone:  #"
echo "#  sudo apt install gvm -y                     #"
echo "#  sudo gvm-setup                              #"
echo "#  - During setup you must record the password #"
echo "#  sudo gvm-start                              #"
echo "#  - https://127.0.0.1:9392                    #"
echo "#                                              #"
echo "#  - change default password for bloodhound    #"
echo "################################################"
