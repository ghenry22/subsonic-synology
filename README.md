# Airsonic-Synology
There is an airsonic based variation of this project at https://github.com/ghenry22/airsonic-synology. This includes packages releases for airsonic and airsonic-advanced.
I have set this as a seperate repo for the moment until I can find a nice way to combine them.  There are many differences in the configuration files and variables between subsonic/airsonic/airsonic-advanced.

# Subsonic-Synology
This project packages the subsonic music server (http://subsonic.org) into an installable SPK file for running on Synology NAS devices.  Check the releases tab for the latest version.

# Requirements
Synology DSM 6.0 or later
Java and Perl packages (install them through package manager first to save time)
DSM 7.0 currently not supported due to changes in package format and installer limitations.  Will update when this is available and working.

# Notes
This package creates a user called subsonic which is visible in the DSM user interface, you should grant this user access to your music folder.  The subsonic server also runs under this user account.

You can start / stop / restart the subsonic server through the DSM Package manager.  To update to the latest version just grab the spk file from the release page here and do a manual install through the DSM package manager and it will update.

The latest SPK file contains subsonic server 6.1.6.  Check the releases page for current and historical binaries.
