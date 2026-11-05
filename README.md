selector1.sh script allows you to filter playlist files(.m3u8 files)  by channel groups and create a new playlist that can be selected when you run startgrid.sh.  It can do 4,6 or 9 windows.   You use 1-9 keys to mute and unmute each player.  The script highlights the title above the player that is unmuted.  It handles video as well radio channels without video.  The script expects xorg on system as it is programmed to just use xinit for very low overhead.   It isn't setup to use a window manager.


The packages that are at least needed may have different names depending on operating system you are using but are:
libmpv-dev, mpv, python3-tkinter, python3-pip, xorg, dialog, pulseaudio and xinit.

Commands to also run are pip install requests python-mpv and pip install -U yt-dlp.

Use pulseaudio only.  Don't use pipewire.     

On system like debian you may have to edit configuration to give non root user access to tty if not using window manager with login manager.  You may have to add user to group tty with something like usermod -aG tty $USER if you get error saying permission access to tty1 denied.

If you want to run this on system already setup with window manager run mpvgrid.sh and pass name of your m3u8 file as a parameter.
This should also work well on termux by changing mpv to use vo=x11 and installing prerequisites but install termux-x11-nightly and install mpv-x.

