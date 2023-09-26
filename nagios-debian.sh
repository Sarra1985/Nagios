#Debian | Raspbian
#All steps on Debian require to run as root. To become root simply run:
#Debian:

sudo -
 

#All commands from this point onwards will be as root.

 

#Security-Enhanced Linux
#This guide is based on SELinux being disabled or in permissive mode. SELinux is not #enabled by default on Debian. If you would like to see if it is installed run the #following command:

dpkg -l selinux*
 

#Prerequisites
#Perform these steps to install the pre-requisite packages.



#===== 9.x / 10.x / 11.x =====

apt-get update
apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev
apt-get install openssl libssl-dev
 

#Downloading the Source
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.14.tar.gz
tar xzf nagioscore.tar.gz
 

#Compile
cd /tmp/nagioscore-nagios-4.4.14/
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
 

#Create User And Group
#This creates the nagios user and group. The www-data user is also added to the nagios #group.

make install-groups-users
usermod -a -G nagios www-data
 

#Install Binaries
#This step installs the binary files, CGIs, and HTML files.

make install
 

#Install Service / Daemon
#This installs the service or daemon files and also configures them to start on boot.

make install-daemoninit
 

#Information on starting and stopping services will be explained further on.

 

#Install Command Mode
#This installs and configures the external command file.

make install-commandmode
 

#Install Configuration Files
#This installs the *SAMPLE* configuration files. These are required as Nagios needs some #configuration files to allow it to start.

make install-config
 

#Install Apache Config Files
#This installs the Apache web server configuration files and configures the Apache #settings.

make install-webconf
a2enmod rewrite
a2enmod cgi
 

#Configure Firewall
#You need to allow port 80 inbound traffic on the local firewall so you can reach the #Nagios Core web interface.

iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT
apt-get install -y iptables-persistent
#Answer yes to saving existing rules

 

#Create nagiosadmin User Account
#You'll need to create an Apache user account to be able to log into Nagios.

#The following command will create a user account called nagiosadmin and you will be #prompted to provide a password for the account.

htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
 

#When adding additional users in the future, you need to remove -c from the above command #otherwise it will replace the existing nagiosadmin user (and any other users you may have #added).

 




#service apache2 restart
# ===== 8.x / 9.x / 10.x /11.x =====

#Need to restart it because it is already running.

systemctl restart apache2.service
 

#Start Service / Daemon
#This command starts Nagios Core.


 

#===== 8.x / 9.x / 10.x / 11.x  =====

systemctl start nagios.service
 

#Test Nagios
#Nagios is now running, to confirm this you need to log into the Nagios Web Interface.

#Point your web browser to the ip address or FQDN of your Nagios Core server, for example:

#http://10.25.5.143/nagios

#http://core-013.domain.local/nagios

#You will be prompted for a username and password. The username is nagiosadmin (you #created it in a previous step) and the password is what you provided earlier.

#Once you have logged in you are presented with the Nagios interface. Congratulations you# #have installed Nagios Core.

#BUT WAIT ...
#Currently you have only installed the Nagios Core engine. You'll notice some errors under #the hosts and services along the lines of:

#(No output on stdout) stderr: execvp(/usr/local/nagios/libexec/check_load, ...) failed. #errno is 2: No such file or directory 
#These errors will be resolved once you install the Nagios Plugins, which is covered in #the #next step.

 

#Installing The Nagios Plugins
#Nagios Core needs plugins to operate properly. The following steps will walk you through #installing Nagios Plugins.

#These steps install nagios-plugins 2.4.6. Newer versions will become available in the #future and you can use those in the following installation steps. Please see the releases #page on GitHub for all available versions.

#Please note that the following steps install most of the plugins that come in the Nagios #Plugins package. However there are some plugins that require other libraries which are #not included in those instructions. Please refer to the following KB article for detailed #installation instructions:

#Documentation - Installing Nagios Plugins From Source

 

#Prerequisites
#Make sure that you have the following packages installed.

apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
 

#Downloading The Source
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.6.tar.gz
tar zxf nagios-plugins.tar.gz
 

#Compile + Install
cd /tmp/nagios-plugins-release-2.4.6/
./tools/setup
./configure
make
make install
 

#Test Plugins
#Point your web browser to the ip address or FQDN of your Nagios Core server, for example:

#http://10.25.5.143/nagios

#http://core-013.domain.local/nagios

#Go to a host or service object and "Re-schedule the next check" under the Commands menu. #The error you previously saw should now disappear and the correct output will be shown on #the screen.

 

#Service / Daemon Commands
#Different Linux distributions have different methods of starting / stopping / restarting #/ status Nagios.

 

#===== 8.x / 9.x / 10.x /11.x =====

systemctl start nagios.service
systemctl stop nagios.service
systemctl restart nagios.service
systemctl status nagios.service
 

 
