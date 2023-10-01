#Ubuntu

#Prerequisites
#Make sure that you have the following packages installed.

sudo apt-get update
sudo apt-get install -y autoconf automake gcc libc6 libmcrypt-dev make libssl-dev wget openssl
 

#Downloading the Source 
cd /tmp
wget --no-check-certificate -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-4.1.0.tar.gz
tar xzf nrpe.tar.gz
 

#Compile
#Note that if you want to pass arguments through NRPE you must specify this in the #configuration option as indicated below. If you prefer to you can omit the --enable-#command-args flag. Removing this flag will require that all arguments be explicitly set #in the nrpe.cfg file on each server monitored.

 

#===== x86_x64 =====

cd /tmp/nrpe-nrpe-4.1.0/
sudo ./configure --enable-command-args --with-ssl-lib=/usr/lib/x86_64-linux-gnu/
sudo make all
 

#Create User And Group
#This creates the nagios user and group.

sudo make install-groups-users
 

#Install Binaries
#This step installs the binary files, the NRPE daemon and the check_nrpe plugin.

#If you only wanted to install the daemon, run the command make install-daemon instead of #the command below. However it is useful having the check_nrpe plugin installed for #testing purposes.

#If you only wanted to install the check_nrpe plugin, refer to the section at the bottom #of this KB article as there a lot of steps that can be skipped. Installing only the #plugin is usually done on your Nagios server and workers.

sudo make install
 

#Install Configuration Files
#This installs the config files.

sudo make install-config
 

#Update Services File
#The /etc/services file is used by applications to translate human readable service names #into port numbers when connecting to a machine across a network.

sudo sh -c "echo >> /etc/services"
sudo sh -c "sudo echo '# Nagios services' >> /etc/services"
sudo sh -c "sudo echo 'nrpe    5666/tcp' >> /etc/services"
 

#Install Service / Daemon
#This installs the service or daemon files.

#===== 15.x / 16.x / 17.x / 18.x / 20.x =====

sudo make install-init
sudo systemctl enable nrpe.service
 

#Information on starting and stopping services will be explained further on.

 

#Configure Firewall
#Port 5666 is used by NRPE and needs to be opened on the local firewall.

sudo mkdir -p /etc/ufw/applications.d
sudo sh -c "echo '[NRPE]' > /etc/ufw/applications.d/nagios"
sudo sh -c "echo 'title=Nagios Remote Plugin Executor' >> /etc/ufw/applications.d/nagios"
sudo sh -c "echo 'description=Allows remote execution of Nagios plugins' >> /etc/ufw/applications.d/nagios"
sudo sh -c "echo 'ports=5666/tcp' >> /etc/ufw/applications.d/nagios"
sudo ufw allow NRPE
sudo ufw reload
 

#Update Configuration File
#The file nrpe.cfg is where the following settings will be defined. It is located:

#/usr/local/nagios/etc/nrpe.cfg
 

#allowed_hosts=

#At this point NRPE will only listen to requests from itself (127.0.0.1). If you wanted #your nagios server to be able to connect, add it's IP address after a comma (in this #example it's 10.25.5.2):

#allowed_hosts=127.0.0.1,10.25.5.2
 

#dont_blame_nrpe=

#This option determines whether or not the NRPE daemon will allow clients to specify #arguments to commands that are executed. We are going to allow this, as it enables more #advanced NPRE configurations.

#dont_blame_nrpe=1
 

#The following commands make the configuration changes described above.

sudo sh -c "sed -i '/^allowed_hosts=/s/$/,10.25.5.2/' /usr/local/nagios/etc/nrpe.cfg"
sudo sh -c "sed -i 's/^dont_blame_nrpe=.*/dont_blame_nrpe=1/g' /usr/local/nagios/etc/nrpe.cfg"
 

#Start Service / Daemon
#Different Linux distributions have different methods of starting NRPE.

#===== 15.x / 16.x / 17.x / 18.x / 20.x =====

sudo systemctl start nrpe.service
 

#Test NRPE
#Now check that NRPE is listening and responding to requests.

#/usr/local/nagios/libexec/check_nrpe -H 127.0.0.1
# You should see the output similar to the following:

#NRPE v4.1.0
#If you get the NRPE version number (as shown above), NRPE is installed and configured #correctly.

#You can also test from your Nagios host by executing the same command above, but instead #of 127.0.0.1 you will need to replace that with the IP Address / DNS name of the machine #with NRPE running.

 

#Service / Daemon Commands
#Different Linux distributions have different methods of starting / stopping / restarting #/ status NRPE.

#===== 15.x / 16.x / 17.x / 18.x / 20.x =====

sudo systemctl start nrpe.service
sudo systemctl stop nrpe.service
sudo systemctl restart nrpe.service
sudo systemctl status nrpe.service
 

#Installing The Nagios Plugins 
#NRPE needs plugins to operate properly. The following steps will walk you through #installing Nagios Plugins.

#These steps install nagios-plugins 2.2.1. Newer versions will become available in the #future and you can use those in the following installation steps. Please see the releases #page on GitHub for all available versions.

#Please note that the following steps install most of the plugins that come in the Nagios #Plugins package. However there are some plugins that require other libraries which are #not included in those instructions. Please refer to the following KB article for detailed #installation instructions:

#Documentation - Installing Nagios Plugins From Source

 

#Prerequisites 
#Make sure that you have the following packages installed.

sudo apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
 

#Downloading the Source
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz
 

#Compile + Install
cd /tmp/nagios-plugins-release-2.2.1/
sudo ./tools/setup
sudo ./configure
sudo make
sudo make install
 

#Test NRPE + Plugins
#Now you can check that NRPE is executing plugins correctly. The default configuration #file /usr/local/nagios/etc/nrpe.cfg has the following command defined in it:

command[check_load]=/usr/local/nagios/libexec/check_load -w 15,10,5 -c 30,25,20
 

#Using the check_load command to test NRPE:

/usr/local/nagios/libexec/check_nrpe -H 127.0.0.1 -c check_load
 

#You should see the output similar to the following:

#OK - load average: 0.01, 0.13, 0.12|load1=0.010;15.000;30.000;0; #load5=0.130;10.000;25.000;0; load15=0.120;5.000;20.000;0;
 

#You can also test from your Nagios host by executing the same command above, but instead #of 127.0.0.1 you will need to replace that with the IP Address / DNS name of the machine #with NRPE running.

 

 
