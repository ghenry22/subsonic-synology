#!/bin/sh
. /etc/profile
TEMP_FOLDER="`find / -maxdepth 2 -name '@tmp' | head -n 1`"
PID=""

subsonic_get_pid ()
{
    PID=`ps -ax | grep java | grep subsonic | head -n 1 | awk '{print $1}'`
    echo "$(date +%d.%m.%y_%H:%M:%S): looking for PID" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
}

preinst ()
{
    . /etc/profile

    ########################################
    #check if Java is installed

    if [ -z ${JAVA_HOME} ]; then
        echo "Java is not installed or not properly configured. JAVA_HOME is not defined. " > $SYNOPKG_TEMP_LOGFILE
            echo "Download and install the Java Synology package from http://wp.me/pVshC-z5" >> $SYNOPKG_TEMP_LOGFILE
            echo "$(date +%d.%m.%y_%H:%M:%S): Download and install the Java Synology package from http://wp.me/pVshC-z5" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
        exit 1
    fi

    if [ ! -f ${JAVA_HOME}/bin/java ]; then
        echo "Java is not installed or not properly configured. The Java binary could not be located. " > $SYNOPKG_TEMP_LOGFILE
            echo "Download and install the Java Synology package from http://wp.me/pVshC-z5" >> $SYNOPKG_TEMP_LOGFILE
            echo "$(date +%d.%m.%y_%H:%M:%S): Download and install the Java Synology package from http://wp.me/pVshC-z5" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
        exit 1
    else
        echo "$(date +%d.%m.%y_%H:%M:%S): found Java in ${JAVA_HOME}" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
    fi
    
    #########################################
    #is the User Home service enabled?
	
	UH_SERVICE=`synogetkeyvalue /etc/synoinfo.conf userHomeEnable`
    if [ ${UH_SERVICE} == "no" ]; then
        echo "The User Home service is not enabled. Please enable this feature in the User control panel in DSM." >> $SYNOPKG_TEMP_LOGFILE
        echo "The User Home service is not enabled. Please enable this feature in the User control panel in DSM." >> ${SYNOPKG_PKGDEST}/subsonic_package.log
        exit 1
    else 
        echo "$(date +%d.%m.%y_%H:%M:%S): User home is enabled" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
    fi
    
    exit 0
}

postinst ()
{
    #create subsonic daemon user
    synouser --add subsonic `${SYNOPKG_PKGDEST}/passgen 1 20` "subsonic daemon user" 0 "" ""
	sleep 3
    echo "$(date +%d.%m.%y_%H:%M:%S): create subsonic daemon user" >> ${SYNOPKG_PKGDEST}/subsonic_package.log

    #determine the subsonic user homedir and save that variable in the user's profile
    #this is needed because librtmp needs to write a file called ~/.swfinfo
    #and new users seem to inherit a HOME value of /root which they have no permissions for
    SUBSONIC_HOMEDIR=`cat /etc/passwd | sed -r '/subsonic daemon user/!d;s/^.*:subsonic daemon user:(.*):.*$/\1/'`
    su - subsonic -s /bin/sh -c "echo export HOME=${SUBSONIC_HOMEDIR} >> .profile"

    
    #install ffmpeg binarys
    if [ ! -d  ${SYNOPKG_PKGDEST}/transcode ]; then
        mkdir ${SYNOPKG_PKGDEST}/transcode
        echo "$(date +%d.%m.%y_%H:%M:%S): created transcode directory" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
    fi
    
    #use the ffmpeg from serviio if available
    if [ -f /var/packages/Serviio/target/bin/ffmpeg ]; then
        ln -s /var/packages/Serviio/target/bin/ffmpeg ${SYNOPKG_PKGDEST}/transcode/ffmpeg
        echo "$(date +%d.%m.%y_%H:%M:%S): Linked ffmpeg file to Serviio" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
    fi
    
    #use the ffmpeg from serviio if available
    if [ -f /usr/syno/bin/ffmpeg ]; then
        ln -s /usr/syno/bin/ffmpeg ${SYNOPKG_PKGDEST}/transcode/ffmpeg
        echo "$(date +%d.%m.%y_%H:%M:%S): Linked ffmpeg file to internal Synology ffmpeg " >> ${SYNOPKG_PKGDEST}/subsonic_package.log
    fi	
	
    #########################################
    ##start subsonic
    #fix file permissions
    chmod +x ${SYNOPKG_PKGDEST}/subsonic.sh
    chmod 775 ${SYNOPKG_PKGDEST}/subsonic-booter-jar-with-dependencies.jar
    chmod 775 ${SYNOPKG_PKGDEST}/subsonic.war
    chown -R subsonic:users ${SYNOPKG_PKGDEST}
    echo "$(date +%d.%m.%y_%H:%M:%S): start subsonic for first initialisation" >> ${SYNOPKG_PKGDEST}/subsonic_package.log

    #set up symlink for the DSM GUI
    ln -s ${SYNOPKG_PKGDEST}/ /usr/syno/synoman/webman/3rdparty/subsonic
            
    #create custom temp folder so temp files can be bigger
    if [ ! -d ${SYNOPKG_PKGDEST}/../../@tmp/subsonic ]; then
        mkdir ${SYNOPKG_PKGDEST}/../../@tmp/subsonic
        chown -R subsonic ${SYNOPKG_PKGDEST}/../../@tmp/subsonic
    fi
    #create symlink to the created directory
    if [ ! -L /tmp/subsonic ]; then
        ln -s ${SYNOPKG_PKGDEST}/../../@tmp/subsonic /tmp/
    fi

    #start subsonic as subsonic user
    su - subsonic -s /bin/sh -c /usr/syno/synoman/webman/3rdparty/subsonic/subsonic.sh

    sleep 10
    
    subsonic_get_pid
    if [ ! -z $PID ]; then
        echo "$(date +%d.%m.%y_%H:%M:%S): started subsonic successfully. PID is: $PID" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
    else
        echo "Error: Can not start subsonic during install" >> $SYNOPKG_TEMP_LOGFILE
        echo "$(date +%d.%m.%y_%H:%M:%S): Error: Can not start subsonic during install" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
        exit 1
    fi

    #give it some time to start up
    sleep 90

    #stop subsonic

    kill $PID
    sleep 5
    echo "$(date +%d.%m.%y_%H:%M:%S): Stopped subsonic" >> ${SYNOPKG_PKGDEST}/subsonic_package.log

    #delete symlink
    rm /usr/syno/synoman/webman/3rdparty/subsonic
    #delete temp files
    if [ -d ${SYNOPKG_PKGDEST}/../../@tmp/subsonic ]; then
        rm -r ${SYNOPKG_PKGDEST}/../../@tmp/subsonic
    fi

    echo "$(date +%d.%m.%y_%H:%M:%S): ----installation complete----" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
    exit 0
}

preuninst ()
{
    ##############################################
    #stop subsonic if it is running

    subsonic_get_pid
    if [ -z $PID ]; then
        sleep 1
    else
        echo "$(date +%d.%m.%y_%H:%M:%S): stopping subsonic" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
        kill $PID
        sleep 5
        if [ -L /usr/syno/synoman/webman/3rdparty/subsonic ]; then
            rm /usr/syno/synoman/webman/3rdparty/subsonic
        fi

        if [ -d ${SYNOPKG_PKGDEST}/../../@tmp/subsonic ]; then
            rm -r ${SYNOPKG_PKGDEST}/../../@tmp/subsonic
        fi
    fi

    exit 0
}

postuninst ()
{
    synouser --del subsonic

    #remove DSM icon symlink
    if [ -L /usr/syno/synoman/webman/3rdparty/subsonic ]; then
        rm /usr/syno/synoman/webman/3rdparty/subsonic
    fi

    #remove temp symlink
    rm /tmp/subsonic

    exit 0
}

preupgrade ()
{
    ##############################
    #stop subsonic if it is runing
    
    subsonic_get_pid
    if [ ! -z $PID ]; then 
        echo "$(date +%d.%m.%y_%H:%M:%S): stopping subsonic" >> ${SYNOPKG_PKGDEST}/subsonic_package.log
        kill $PID
        sleep 5
    fi

    if [ -d ${SYNOPKG_PKGDEST}/../../@tmp/subsonic ]; then
        rm -r ${SYNOPKG_PKGDEST}/../../@tmp/subsonic
    fi

    exit 0
}

postupgrade ()
{
    #subsonic may not own all new files
    chown -R subsonic ${SYNOPKG_PKGDEST}/

    #make the subsonic start script executable
    chmod +x ${SYNOPKG_PKGDEST}/subsonic.sh 

    echo "$(date +%d.%m.%y_%H:%M:%S): ----update complete----" >> ${SYNOPKG_PKGDEST}/subsonic_package.log

    exit 0
}
