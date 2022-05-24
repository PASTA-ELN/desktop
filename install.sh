#!/bin/bash
echo "Installer for PASTA database on Debian/Ubuntu-Linux"
echo "IMPORTANT: if you have problems, visit https://jugit.fz-juelich.de/pasta/main/-/wikis/home#installation-scripts"
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
  pasta_src="pasta_source"
fi
if [ -z $pasta ]
then
  pasta="pasta"
fi
echo
####################################

echo
read -p "Do you wish to install everything [Y/n] ? " yesno
if [[ $yesno = 'N' ]] || [[ $yesno = 'n' ]]
then
  echo "  Did not install anything"
  exit
fi
echo
sudo rm installPASTA2.log
sudo -u $THEUSER mkdir /home/$THEUSER/$pasta


# #########  START INSTALLATION  #################
echo "Ensure python, pip and pandoc are installed. This takes a few minutes"
sudo add-apt-repository -y universe                    >> installPASTA2.log
sudo apt-get install -y python3 python3-pip pandoc npm >> installPASTA2.log
echo

echo "Install git, git-annex, datalad"
wget -O- http://neuro.debian.net/lists/focal.de-fzj.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list>> installPASTA2.log  2>&1
sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9 >> installPASTA2.log  2>&1
sudo apt-get update             >> installPASTA2.log  2>&1
sudo apt-get install -y datalad >> installPASTA2.log  2>&1
echo
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

echo "Start cloning the git repositories: tools, python-backend, javascript-frontend"
sudo -u $THEUSER git clone git@github.com:PASTA-ELN/desktop.git $pasta_src >> installPASTA2.log  2>&1
echo

echo "Adopt path and python-path in your environment"
sudo -u $THEUSER echo "#PASTA changes" >> /home/$THEUSER/.bashrc
sudo -u $THEUSER echo "export PATH=\$PATH:/home/${THEUSER}/${pasta_src}/Python" >> /home/$THEUSER/.bashrc
sudo -u $THEUSER echo "export PYTHONPATH=\$PYTHONPATH:/home/${THEUSER}/${pasta_src}/Python" >> /home/$THEUSER/.bashrc
echo

echo "Install python requirements. This takes a few minutes."
cd /home/$THEUSER/$pasta_src/main
sudo -H pip3 install -r requirements.txt           >> installPASTA2.log
echo

echo "Create PASTA configuration file .pasta.json in home directory"

# sudo -u $THEUSER echo "{" > /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"softwareDir\": \"/home/${THEUSER}/${pasta_src}/main\"," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"userID\": \"${THEUSER}\"," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"version\": 1," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"extractors\": {}," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"qrPrinter\": {}," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"default\": \"research\"," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"magicTags\": [\"P1\",\"P2\",\"P3\",\"TODO\",\"WAIT\",\"DONE\"]," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  " >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"links\": {" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "    \"research\": {" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "      \"local\": {" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "        \"user\": \"${CDB_USER}\"," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "        \"password\": \"${CDB_PASSW}\"," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "        \"database\": \"pasta_tutorial\"," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "        \"path\": \"/home/${THEUSER}/${pasta}\"" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "      }," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "      \"remote\": {}" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "    }" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  }," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  " >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  \"tableFormat\": {" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "    \"x0\":{\"-label-\":\"Projects\",\"-default-\": [22,6,50,22]}," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "    \"measurement\":{\"-default-\": [24,7,23,23,-5,-6,-6,-6]}," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "    \"sample\":{\"-default-\": [23,23,23,23,-5]}," >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "    \"procedure\":{\"-default-\": [20,20,20,40]}" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "  }" >> /home/$THEUSER/.pastaELN.json
# sudo -u $THEUSER echo "}" >> /home/$THEUSER/.pastaELN.json
# sudo chown $THEUSER:$THEUSER /home/$THEUSER/.pastaELN.json
echo

CDB_USER="admin"
CDB_PASSW=$(date +%s | sha256sum | base64 | head -c 12 ; echo)
echo "Ensure couchdb snap is active running"
if snap services|grep active|grep couchdb >/dev/null
then
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
cd /home/$THEUSER/$pasta_src/main
sudo PYTHONPATH=/home/$THEUSER/$pasta_src/main -u $THEUSER python3 pastaELN.py test
echo
echo 'If this test is not successful, it is likely that you entered the wrong username'
echo "  and password. Open the file /home/$THEUSER/.pastaELN.json with an editor and correct"
echo '  the entries after "user" and "password". "-userID" does not matter. Entries under'
echo '  "remote" do not matter, either.'
sudo PYTHONPATH=/home/$THEUSER/$pasta_src/main -u $THEUSER python3 pastaELN.py extractorScan
echo
echo "Run a short test for 10-20sec?"
sudo PYTHONPATH=/home/$THEUSER/$pasta_src/main -u $THEUSER python3 Tests/verifyInstallation.py
echo


echo "Graphical user interface GUI"
cd /home/$THEUSER/$pasta_src/gui
sudo -u $THEUSER npm install                                         >> installPASTA2.log
sudo PATH=$PATH:/home/$THEUSER/$pasta_src/main -u $THEUSER npm start >> installPASTA2.log 2>&1

echo -e "\033[0;31m=========================================================="
echo -e "If you want to start PASTA in the future:"
echo -e "  startPASTA.py"
echo -e "It is good to start with Projects, then Samples and Procedures and finally"
echo -e "Measurements."
echo -e "MAKE SURE, you wrote down PASSWORD FOR SAFEKEEPING: $CDB_PASSW"
echo -e "==========================================================\033[0m"
echo
