# Subsonic_Synology
Subsonic setup to run on Synology NAS

This is tested on the Synology DS1815+ but should work on most modern synology devices.  This uses the Subsonic 5.3 standalone package with some modifications to the subsonic.sh script, the addition of a start/stop/status script to control the server and the addition of some default directories for music / playlists / podcasts so that subsonic doesn't try to access areas that don't exist by default.

The instructions below explain where to put everything and how to get it all running.

7APR2016 - Updated to Subsonic 5.3

## Upgrade to Latest Version
1) ssh into the synology

2) stop subsonic

`/var/subsonic/start-stop-status stop`

3) copy the contents of this repo over the top of the existing files in /var/subsonic (your DB will be safe!)

4) Set the subsonic user to own the subsonic folder so that it can create the files and folders it needs:

`chown -R subsonic:root /var/subsonic`

5) Set the start-stop-status script to be executable

`chmod +x /var/subsonic/start-stop-status`

6) Go to the webUI for the Synology and run the subsonic scheduled task to start subsonic running as usual in the background.s

##First Time Install

## Install Java

1) Go to the package manager and install the official Java Manager app.  Once installed run the app and follow the instructions to download and install the latest version of Java 7.

## Install & Setup Subsonic
1) Download / clone this repository to your NAS

2) Go to the control panel in DSM, then users and create the user `subsonic` with description `Subsonic User`

3) Add subsonic user to the `users` group

4) Using the Synology File Station in DSM grant the subsonic user access to your MUSIC folder (where ever you keep your music on the NAS).

5) ssh into your NAS as root (same password as your admin user in the web interface)

6) `mkdir /var/subsonic`

7) copy the contents of this repository into `/var/subsonic`

8) edit your subsonic user so that it is able to run services on the NAS (by default it will fail), use vi to open the file:

`vi /etc/passwd`

Find the line for your subsonic user (the numbers may be different but don't worry about it):
`subsonic:x:1029:100:Subsonic User/var/services/homes/subsonic:/sbin/nologin`

Edit the subsonic user to have it's home folder set to the subsonic home folder and to allow it to run services:
`subsonic:x:1029:100:Subsonic User:/var/subsonic:/bin/sh`

Save the file and exit

9) Set the subsonic user to own the subsonic folder so that it can create the files and folders it needs:

`chown -R subsonic:root /var/subsonic`

10) Set the start-stop-status script to be executable

`chmod +x /var/subsonic/start-stop-status`

11) That's it you should be ready to go, the server will start on port 8082 by default.  If you want to change this simply edit the subsonic.sh file and change the port variable right at the top of the file to whatever port you want.

## Run it automatically & Keep it Running

We are going to setup a scheduled task to start subsonic.  You can click on the task and run it manually at any time to start the service, say after a reboot.  Otherwise the task will run daily.  It will check if subsonic is already running and if so just log that it is up.  If it is not running then it will start it.

We tell the task to run as root in the config but the script that it is running automatically runs the process as the subsonic user.  You can confirm this by connecting with SSH and running:

`ps | grep java`

You will see that the process is owned by the subsonic user.

On your Synology NAS go to the DSM web interface.  Go to Control Panel and Task Scheduler.

1) Create / User Defined Script

Task: Subsonic Launcher

User: root

Enabled: checked

Run Command:

/var/subsonic/start-stop-status start


Leave the schedule as Daily as it is by default.


2) click on your new task and choose run to run it manually the first time and start subsonic.

## Running From the Command Line:

The start-stop-status script is used to control Subsonic, just run the commands below from the console as root, when you logout though the process will be killed.  Synology's console does not honor nohup either.

start:

`/var/subsonic/start-stop-status start`

stop:

`/var/subsonic/start-stop-status stop`

check if subsonic is running:

`/var/subsonic/start-stop-status status`

You could also add the the start command to a startup script so that subsonic is run on boot
