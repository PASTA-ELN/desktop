#!/bin/bash
echo "Installer for PASTA database on Debian/Ubuntu-Linux"
echo "IMPORTANT: if you have problems, visit https://pasta-eln.github.io"
echo "Default choices are accepted by return: [Y/n]->yes; [default]->default"

echo "Ensure installer has sudo rights"
if [ "$EUID" -ne 0 ]
  then
  echo "  ERROR: Please run as root with 'sudo ./install.sh' "
  exit
fi
echo
THEUSER=$(logname)
echo "Ensure that conda is not running"
if conda &>/dev/null
then
  echo "  'conda' is installed; I deactivate it."
  conda deactivate
else
  echo "  Info: 'conda' is not installed."
fi
echo

######## ASK QUESTIONS #############
OUTPUT=$(sudo -u $THEUSER git config -l | grep "user")
if [[ -n $OUTPUT ]]
then
  echo "  git user and email are set"
else
  echo "  Set your git user information"
  read -p "  What is your name? " GIT_NAME
  read -p "  What is your email? " GIT_EMAIL
fi
echo

echo "Two empty (for safety) directories are required. One for the source code"
echo "and the other as central place to store data, work in."
read -p "  Where to store the source code? [pastaSource, i.e. /home/${THEUSER}/pastaSource] " pasta_src
read -p "  Where to store the data? [pastaData, i.e. /home/${THEUSER}/pastaData] " pasta
if [ -z $pasta_src ]
then
  pasta_src="pastaSource"
fi
if [ -z $pasta ]
then
  pasta="pastaData"
fi
echo

read -p "Do you wish to install everything [Y/n] ? " yesno
if [[ $yesno = 'N' ]] || [[ $yesno = 'n' ]]
then
  echo "  Did not install anything"
  exit
fi
echo

# #########  START INSTALLATION  #################
sudo -u $THEUSER mkdir /home/$THEUSER/$pasta

echo "Ensure python, pip and pandoc are installed."
sudo add-apt-repository -y universe                     >> installPASTA2.log  2>&1
sudo apt-get install -y python3 python3-pip pandoc fuse >> installPASTA2.log  2>&1
echo

echo "Install git, git-annex, datalad"
wget -q http://neuro.debian.net/lists/focal.de-fzj.full -O /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9 >> installPASTA2.log  2>&1
sudo apt-get update             >> installPASTA2.log  2>&1
sudo apt-get install -y git-annex-standalone >> installPASTA2.log  2>&1
echo

OUTPUT=$(sudo -u $THEUSER git config -l | grep "user")
if [[ -n $OUTPUT ]]
then
  echo "  git user and email are set"
else
  sudo -u $THEUSER git config --global --add user.name "${GIT_NAME}"
  sudo -u $THEUSER git config --global --add user.email $GIT_EMAIL
fi
echo

cd /home/$THEUSER
echo "Start cloning the git repositories: tools, python-backend, javascript-frontend"
sudo -u $THEUSER git clone https://github.com/PASTA-ELN/desktop.git $pasta_src >> installPASTA2.log  2>&1
cd  $pasta_src
sudo -u $THEUSER chmod 755 pasta-linux.AppImage
sudo -u $THEUSER git clone https://github.com/PASTA-ELN/Python.git >> installPASTA2.log  2>&1
echo

echo "Adopt path and python-path in your environment"
if [ ! -n "$(grep "^#PASTA changes" /home/$THEUSER/.bashrc)" ];  then
  sudo -u $THEUSER echo "#PASTA changes" >> /home/$THEUSER/.bashrc
  sudo -u $THEUSER echo "export PATH=\$PATH:/home/${THEUSER}/${pasta_src}/Python" >> /home/$THEUSER/.bashrc
  sudo -u $THEUSER echo "export PYTHONPATH=\$PYTHONPATH:/home/${THEUSER}/${pasta_src}/Python" >> /home/$THEUSER/.bashrc
fi
echo

echo "Install python dependencies."
cd Python
sudo -H pip3 install -r requirements.txt           >> installPASTA2.log
echo

echo "Create PASTA configuration file .pastaELN.json in home directory"
cd ..
CDB_PASSW=$(sudo -u $THEUSER python3 makeConfigFile.py $pasta_src $pasta)
echo "Password $CDB_PASSW"
echo


CDB_USER="admin"
echo "Ensure couchdb snap is active running"
if snap services|grep active|grep couchdb >/dev/null; then
  echo "  couchdb is installed"
else
  echo "Install couchdb"
  sudo snap install couchdb
  sudo snap set couchdb admin=$CDB_PASSW
  sudo snap start couchdb
  sudo snap connect couchdb:mount-observe
  sudo snap connect couchdb:process-control
  sleep 5
  curl -X PUT http://$CDB_USER:$CDB_PASSW@127.0.0.1:5984/_users
  curl -X PUT http://$CDB_USER:$CDB_PASSW@127.0.0.1:5984/_replicator      >> installPASTA2.log  2>&1
  curl -X PUT http://$CDB_USER:$CDB_PASSW@127.0.0.1:5984/_global_changes  >> installPASTA2.log  2>&1
fi
echo


echo "Run a very short test for 5sec?"
cd /home/$THEUSER/$pasta_src/Python
sudo PYTHONPATH=/home/$THEUSER/$pasta_src/Python -u $THEUSER python3 pastaELN.py test
echo
echo 'If this test is not successful, it is likely that you entered the wrong username'
echo "  and password. Open the file /home/$THEUSER/.pastaELN.json with an editor and correct"
echo '  the entries after "user" and "password". "-userID" does not matter. Entries under'
echo '  "remote" do not matter, either.'
sudo PYTHONPATH=/home/$THEUSER/$pasta_src/Python -u $THEUSER python3 pastaELN.py extractorScan
echo
echo "Run a short test for 10-20sec?"
read -p "Do you really want to continue: This will delete things! [y/N] ? " yesno
if [[ $yesno = 'N' ]] || [[ $yesno = 'n' ]] || [[ $yesno = '' ]]
then
  echo "  Did not destroy anything"
  exit
fi
sudo PYTHONPATH=/home/$THEUSER/$pasta_src/Python -u $THEUSER python3 Tests/verifyInstallation.py
echo


echo "Graphical user interface GUI"
echo -e "\033[0;31m=========================================================="
echo -e "To start PASTA: there are desktop icon"
echo -e "  alternatively start the .AppImage in PASTA's source"
echo -e ""
echo -e "It is good to start with Projects, then Samples and Procedures and finally"
echo -e "Measurements."
echo -e ""
echo -e "MAKE SURE, you wrote down PASSWORD FOR SAFEKEEPING: $CDB_PASSW"
echo -e "Currently, the configuration ~/.pastaELN.json is unscrambled"
echo -e "  use PASTA for some time, then run 'pastaELN.py scramble' to scramble them"
echo -e "  after some more time, delete the backup '~/.pastaELN_BAK.json' "
echo -e "==========================================================\033[0m"
echo
