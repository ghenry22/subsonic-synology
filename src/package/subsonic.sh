#!/bin/sh

###################################################################################
#   version: 6.0
#   Shell script for starting Subsonic.  
#   Author: Sindre Mehus, Gigon, Madevil, Gaven Henry
###################################################################################


RAM=$((`free | grep Mem: | sed -e "s/^ *Mem: *\([0-9]*\).*$/\1/"`/1024))
if [ $RAM -le 128 ]; then
    SUBSONIC_INIT_MEMORY=32
    SUBSONIC_MAX_MEMORY=80
elif [ $RAM -le 256 ]; then
    SUBSONIC_INIT_MEMORY=64
    SUBSONIC_MAX_MEMORY=192
elif [ $RAM -le 1025 ]; then
    SUBSONIC_INIT_MEMORY=128
    SUBSONIC_MAX_MEMORY=192
elif [ $RAM -gt 1024 ]; then
    SUBSONIC_INIT_MEMORY=256
    SUBSONIC_MAX_MEMORY=512
fi

SUBSONIC_HOME=/usr/syno/synoman/webman/3rdparty/subsonic
SUBSONIC_HOST=0.0.0.0
SUBSONIC_PORT=4040
SUBSONIC_HTTPS_PORT=0
SUBSONIC_CONTEXT_PATH=/
SUBSONIC_PIDFILE=/usr/syno/synoman/webman/3rdparty/subsonic/PID.log
SUBSONIC_DEFAULT_MUSIC_FOLDER=/volume1/Public/Media/Artists
SUBSONIC_DEFAULT_UPLOAD_FOLDER=/volume1/Public/Media/incoming
SUBSONIC_DEFAULT_PODCAST_FOLDER=/volume1/Public/Media/podcast
SUBSONIC_DEFAULT_PLAYLIST_IMPORT_FOLDER=/volume1/Public/Media/Playlists/Import
SUBSONIC_DEFAULT_PLAYLIST_EXPORT_FOLDER=/volume1/Public/Media/Playlists/Export
SUBSONIC_DEFAULT_PLAYLIST_BACKUP_FOLDER=/volume1/Public/Media/Playlists/Backup
SUBSONIC_DEFAULT_TRANSCODE_FOLDER=/usr/syno/bin
SUBSONIC_DEFAULT_TIMEZONE=
SUBSONIC_UPDATE=false
SUBSONIC_GZIP=
SUBSONIC_DB=
quiet=0

usage() {
    echo "Usage: subsonic.sh [options]"
    echo "  --help                                This small usage guide."
    echo "  --home=DIR                            The directory where subsonic will create files."
    echo "                                        Make sure it is writable. Default: /var/subsonic"
    echo "  --host=HOST                           The host name or IP address on which to bind subsonic."
    echo "                                        Only relevant if you have multiple network interfaces and want"
    echo "                                        to make subsonic available on only one of them. The default value"
    echo "                                        will bind subsonic to all available network interfaces. Default: 0.0.0.0"
    echo "  --port=PORT                           The port on which subsonic will listen for"
    echo "                                        incoming HTTP traffic. Default: 4040"
    echo "  --https-port=PORT                     The port on which subsonic will listen for"
    echo "                                        incoming HTTPS traffic. Default: 0 (disabled)"
    echo "  --context-path=PATH                   The context path, i.e., the last part of the subsonic"
    echo "                                        URL. Typically '/' or '/subsonic'. Default '/'"
    echo "  --init-memory=MB                      The memory initial size (Init Java heap size) in megabytes." 
    echo "                                        Default: 192"
    echo "  --max-memory=MB                       The memory limit (max Java heap size) in megabytes." 
    echo "                                        Default: 384"
    echo "  --pidfile=PIDFILE                     Write PID to this file."
    echo "                                        Default not created."
    echo "  --default-music-folder=DIR            Configure subsonic to use this folder for music."
    echo "                                        This option only has effect the first time subsonic is started." 
    echo "                                        Default '/var/media/artists'"
    echo "  --default-upload-folder=DIR           Configure subsonic to use this folder for music."
    echo "                                        Default '/var/media/incoming'"
    echo "  --default-podcast-folder=DIR          Configure subsonic to use this folder for Podcasts."
    echo "                                        Default '/var/media/podcast'"
    echo "  --default-playlist-import-folder=DIR  Configure subsonic to use this folder for playlist import."
    echo "                                        Default '/var/media/playlists/import'"
    echo "  --default-playlist-export-folder=DIR  Configure subsonic to use this folder for playlist export."
    echo "                                        Default '/var/media/playlists/export'"
    echo "  --default-playlist-backup-folder=DIR  Configure subsonic to use this folder for playlist backup."
    echo "                                        Default '/var/media/playlists/backup'"
    echo "  --default-transcode-folder=DIR        Configure subsonic to use this folder for transcoder."
    echo "  --timezone=Zone/City                  Configure subsonic to use other timezone for time correction"
    echo "                                        Example 'Europe/Vienna', 'US/Central', 'America/New_York'"
    echo "  --db=JDBC_URL                         Use alternate database. MySQL and HSQL are currently supported."
    echo "  --update=VALUE                        Configure subsonic to look in folder /update for updates. Default 'true'"
    echo "  --gzip=VALUE                          Configure subsonic to use Gzip compression. Default 'true'"
    echo "  --quiet                               Don't print anything to standard out. Default false."
    exit 1 
}

# Parse arguments.
while [ $# -ge 1 ]; do
    case $1 in
        --help)
            usage
            ;;
        --home=?*)
            SUBSONIC_HOME=${1#--home=}
            ;;
        --host=?*)
            SUBSONIC_HOST=${1#--host=}
            ;;
        --port=?*)
            SUBSONIC_PORT=${1#--port=}
            ;;
        --https-port=?*)
            SUBSONIC_HTTPS_PORT=${1#--https-port=}
            ;;
        --context-path=?*)
            SUBSONIC_CONTEXT_PATH=${1#--context-path=}
            ;;
        --init-memory=?*)
            SUBSONIC_INIT_MEMORY=${1#--init-memory=}
            ;;
        --max-memory=?*)
            SUBSONIC_MAX_MEMORY=${1#--max-memory=}
            ;;
        --pidfile=?*)
            SUBSONIC_PIDFILE=${1#--pidfile=}
            ;;
        --default-music-folder=?*)
            SUBSONIC_DEFAULT_MUSIC_FOLDER=${1#--default-music-folder=}
            ;;
        --default-upload-folder=?*)
            SUBSONIC_DEFAULT_UPLOAD_FOLDER=${1#--default-upload-folder=}
            ;;
        --default-podcast-folder=?*)
            SUBSONIC_DEFAULT_PODCAST_FOLDER=${1#--default-podcast-folder=}
            ;;
        --default-playlist-import-folder=?*)
            SUBSONIC_DEFAULT_PLAYLIST_IMPORT_FOLDER=${1#--default-playlist-import-folder=}
            ;;
        --default-playlist-export-folder=?*)
            SUBSONIC_DEFAULT_PLAYLIST_EXPORT_FOLDER=${1#--default-playlist-export-folder=}
            ;;
        --default-playlist-backup-folder=?*)
            SUBSONIC_DEFAULT_PLAYLIST_BACKUP_FOLDER=${1#--default-playlist-backup-folder=}
            ;;
        --default-transcode-folder=?*)
            SUBSONIC_DEFAULT_TRANSCODE_FOLDER=${1#--default-transcode-folder=}
            ;;
        --timezone=?*)
           SUBSONIC_DEFAULT_TIMEZONE=${1#--timezone=}
           ;;
        --update=?*)
           SUBSONIC_UPDATE=${1#--update=}
           ;;           
        --gzip=?*)
           SUBSONIC_GZIP=${1#--gzip=}
           ;;
        --db=?*)
            SUBSONIC_DB=${1#--db=}
           ;;
        --quiet)
            quiet=1
            ;;
        *)
            usage
            ;;
    esac
    shift
done

# Use JAVA_HOME if set, otherwise assume java is in the path.
JAVA=java
if [ -e "${JAVA_HOME}" ]
    then
    JAVA=${JAVA_HOME}/bin/java
fi

# Create subsonic home directory.
mkdir -p ${SUBSONIC_HOME}
LOG=${SUBSONIC_HOME}/subsonic_sh.log
rm -f ${LOG}

cd $(dirname $0)
if [ -L $0 ] && ([ -e /bin/readlink ] || [ -e /usr/bin/readlink ]); then
    cd $(dirname $(readlink $0))
fi

${JAVA} -Xms${SUBSONIC_INIT_MEMORY}m -Xmx${SUBSONIC_MAX_MEMORY}m \
  -Dsubsonic.home=${SUBSONIC_HOME} \
  -Dsubsonic.host=${SUBSONIC_HOST} \
  -Dsubsonic.port=${SUBSONIC_PORT} \
  -Dsubsonic.httpsPort=${SUBSONIC_HTTPS_PORT} \
  -Dsubsonic.contextPath=${SUBSONIC_CONTEXT_PATH} \
  -Dsubsonic.defaultMusicFolder=${SUBSONIC_DEFAULT_MUSIC_FOLDER} \
  -Dsubsonic.defaultUploadFolder=${SUBSONIC_DEFAULT_UPLOAD_FOLDER} \
  -Dsubsonic.defaultPodcastFolder=${SUBSONIC_DEFAULT_PODCAST_FOLDER} \
  -Dsubsonic.defaultPlaylistImportFolder=${SUBSONIC_DEFAULT_PLAYLIST_IMPORT_FOLDER} \
  -Dsubsonic.defaultPlaylistExportFolder=${SUBSONIC_DEFAULT_PLAYLIST_EXPORT_FOLDER} \
  -Dsubsonic.defaultPlaylistBackupFolder=${SUBSONIC_DEFAULT_PLAYLIST_BACKUP_FOLDER} \
  -Dsubsonic.defaultTranscodeFolder=${SUBSONIC_DEFAULT_TRANSCODE_FOLDER} \
  -Duser.timezone=${SUBSONIC_DEFAULT_TIMEZONE} \
  -Dsubsonic.update=${SUBSONIC_UPDATE} \
  -Dsubsonic.gzip=${SUBSONIC_GZIP} \
  -Dsubsonic.db="${SUBSONIC_DB}" \
  -Djava.awt.headless=true \
  -Djava.net.preferIPv4Stack=true \
  -jar subsonic-booter-jar-with-dependencies.jar > ${LOG} 2>&1 &
  sleep 5

# Write pid to pidfile if it is defined.
if [ $SUBSONIC_PIDFILE ]; then
    echo $! > ${SUBSONIC_PIDFILE}
fi

if [ $quiet = 0 ]; then
    echo Started subsonic [PID $!, ${LOG}]
fi
