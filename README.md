# Subsonic_Synology
Subsonic setup to run on Synology NAS

This is tested on the Synology DS1815+ but should work on most modern synology devices.

## Install Java

1) Go to the package manager and install the official Java Manager app.  Once installed run the app and follow the instructions to download and install the latest version of Java 7.

## Install & Setup Subsonic
1) Download / clone this repository to your NAS

2) Go to the control panel in DSM, then users and create the user subsonic with description Subsonic User

3) Add subsonic user to the users group

4) Using the Synology File Station in DSM grant the subsonic user access to your MUSIC folder (where ever you keep your music on the NAS).

5) ssh into your NAS as root (same password as your admin user in the web interface)

6) mkdir /var/subsonic

7) copy the contents of this repository into /var/subsonic

8) edit your subsonic user so that it is able to run services on the NAS (by default it will fail), use vi to open the file:

vi /etc/passwd

Find the line for your subsonic user (the numbers may be different but don't worry about it):
subsonic:x:1029:100:Subsonic User/var/services/homes/subsonic:/sbin/nologin

Edit the subsonic user to have it's home folder set to the subsonic home folder and to allow it to run services:
subsonic:x:1029:100:Subsonic User:/var/subsonic:/bin/sh

Save the file and exit

9) Set the subsonic user to own the subsonic folder so that it can create the files and folders it needs:

chown -R subsonic:root /var/subsonic

10) Set the start-stop-status script to be executable

chmod +x /var/subsonic/start-stop-status

11) That's it you should be ready to go, the server will start on port 8082 by default.  If you want to change this simply edit the subsonic.sh file and change the port variable right at the top of the file to whatever port you want.

## Running:

The start-stop-status script is used to control Subsonic, just run the commands below from the console as root

start:
/var/subsonic/start-stop-status start

stop:
/var/subsonic/start-stop-status stop

check if subsonic is running:
/var/subsonic/start-stop-status status

You could also add the the start command to a startup script so that subsonic is run on boot
