Checkbox1.sh is a script that allows you to select from a playlist 2,4,6 or 8 urls and creates a script to play them in a grid
in said amount of quadrants. 
<br>
To mute and unmute each window:
   Right quadrant uses directional or arrow keys on remote, keyboard or controller.   Up/Down/Left/Right
   Second quadrant is same but uses double clicks.
   To mute all windows click right three times.
   To exit click left three times
To exit checkbox1.sh script press key 1.
<br>
Should work on most operating systems that can run python-tkinter including termux.<br>
Some of the requirements are python-tkinter, python-requests and python-pip.
pip install python-vlc
apt install vlc or pkg add vlc.<br>
git clone https://github.com/rtlrecguy-del/tv-grid-tkinter.git <br>
cd tv-grid-tkinter <br>
chmod +x checkbox1.sh


These scripts have only used pulseaudio not pipewire.
