# Subsonic_Synology
This project packages the subsonic music server (http://subsonic.org) into an installable SPK file for running on Synology NAS devices.  Check the releases tab for the latest version.

# Requirements
Synology DSM 6.0 or later
Java and Perl packages (install them through package manager first to save time)

# Notes
This package creates a user called subsonic which is visible in the DSM user interface, you should grant this user access to your music folder.  The subsonic server also runs under this user account.

You can start / stop / restart the subsonic server through the DSM Package manager.  To update to the latest version just grab the spk file from the release page here and do a manual install through the DSM package manager and it will update.

The latest SPK file contains subsonic server 6.1.3.  Check the releases page for current and historical binaries.
The latest SPK file contains subsonic server 6.1.2.  Check the releases page for current and historical binaries.