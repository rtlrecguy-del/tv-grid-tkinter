Selector file allow you to filter playlist by channel groups and create a new playlist that can be selected when you run StartGrid.sh.  It can do 4,6 or 9 windows.   You use 1-9 keys to mute and unmute the windows.  Mpv Windows highlight the name of channels in red when it is unmuted/umuted.  It handles video as well as just radio channels without video.  The script expects xorg on system as it is programmed to just use xinit for very low overhead but that can be changed.   It isn't setup to use a window manager.


The packages that are at least needed may have different names depending on operating system you are using but are:
libmpv-dev, mpv, python3-tkinter, python3-pip, xorg, dialog, pulseaudio xinit.

Commands to also run are pip install request python-mpv and pip install -U yt-dlp.

Use pulseaudio only.  Don't use pipewire.     

On system like debian you may have to edit configuration to give non root user access to tty and add user to group tty.
