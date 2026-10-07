#!/usr/bin/env /usr/bin/python3
import subprocess
import os
import tkinter as tk
from tkinter import ttk
import vlc
import time
import requests

SPECIFIED_FILE = "test5.txt"
with open(SPECIFIED_FILE, "r") as file:
    line_count = len(file.readlines())

class VLCQuadrantsApp:
    def __init__(self, root):
        self.root = root
        self.root.bind("<Triple-Left>", self.on_z)
        self.root.bind("<Triple-Right>", self.muteall)
        self.root.bind("<Triple-Up>", self.reload)
        self.root.title("VLC 4-Quadrant Grid")
        self.root.geometry("1920x1080")
        self.root.bind("<Up>", self.toggle_mute1)
        self.root.bind("<Down>", self.toggle_mute2)
        self.root.bind("<Left>", self.toggle_mute3)
        self.root.bind("<Right>", self.toggle_mute4)

        self.root.bind("<Double-Up>", self.toggle_mute5)
        self.root.bind("<Double-Left>", self.toggle_mute6)
        self.root.bind("<Double-Down>", self.toggle_mute7)
        self.root.bind("<Double-Right>", self.toggle_mute8)

        # Initialize VLC instance
        vlc_options = [
           "--adaptive-logic=lowest",     # Forces the adaptive streaming module to choose the lowest bitrate
           "--preferred-resolution=480",  # Hints to preferred low resolution (e.g., 240p, 360p)
           "--loop"       # Optional: Adjust network cache in milliseconds
        ]        
        self.vlc_instance = vlc.Instance(vlc_options)

        # 4 Players and mute states
        self.players = []
        self.is_muted = [False, False, False, False]

        self.setup_ui()

    def setup_ui(self):
        # Top bar for file selection
        control_frame = ttk.Frame(self.root)
        control_frame.pack(fill=tk.X, padx=10, pady=5)
        self.my_label = tk.Label(root, text="Playing Video 2", font=("Arial", 14))
        self.my_label.pack(pady=2) 
        # Video Grid (2x2)




        if line_count == 2:
            grid_frame = ttk.Frame(self.root)
            grid_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
            grid_frame.rowconfigure([0], weight=1)
            grid_frame.columnconfigure([0, 1], weight=1)
        if line_count == 6:
            grid_frame = ttk.Frame(self.root)
            grid_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
            grid_frame.rowconfigure([0, 1], weight=1)
            grid_frame.columnconfigure([0, 1, 2], weight=1)
        if line_count == 4:
            grid_frame = ttk.Frame(self.root)
            grid_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
            grid_frame.rowconfigure([0, 1], weight=1)
            grid_frame.columnconfigure([0, 1], weight=1)
        if line_count == 8:
            grid_frame = ttk.Frame(self.root)
            grid_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
            grid_frame.rowconfigure([0, 1], weight=1)
            grid_frame.columnconfigure([0, 1, 2, 3], weight=1)

        # Create 4 quadrants
        if line_count == 2:
            for r, c in [(0, 0), (0, 1)]:
                frame = ttk.Frame(grid_frame, relief=tk.SUNKEN, borderwidth=2)
                frame.grid(row=r, column=c, sticky="nsew", padx=2, pady=2)
                player = self.vlc_instance.media_player_new()
                player.video_set_aspect_ratio("4:3")
                self.players.append(player)
                player.set_xwindow(frame.winfo_id())

        if line_count == 4:
            for r, c in [(0, 0), (0, 1), (1, 0), (1, 1)]:
                frame = ttk.Frame(grid_frame, relief=tk.SUNKEN, borderwidth=2)
                frame.grid(row=r, column=c, sticky="nsew", padx=2, pady=2)
                player = self.vlc_instance.media_player_new()
                player.video_set_aspect_ratio("4:3")
                self.players.append(player)
                player.set_xwindow(frame.winfo_id())

        if line_count == 6:
            for r, c in [(0, 0), (0, 1), (1, 0), (1, 1), (0, 2),(1, 2)]:
                frame = ttk.Frame(grid_frame, relief=tk.SUNKEN, borderwidth=2)
                frame.grid(row=r, column=c, sticky="nsew", padx=2, pady=2)
                player = self.vlc_instance.media_player_new()
                player.video_set_aspect_ratio("4:3")
                self.players.append(player)
                player.set_xwindow(frame.winfo_id())

        if line_count == 8:
            for r, c in [(0, 0), (0, 1), (1, 0), (1, 1), (0, 2),(1, 2), (0, 3), (1 ,3)]:
                frame = ttk.Frame(grid_frame, relief=tk.SUNKEN, borderwidth=2)
                frame.grid(row=r, column=c, sticky="nsew", padx=2, pady=2)
                player = self.vlc_instance.media_player_new()
                player.video_set_aspect_ratio("4:3")
                self.players.append(player)
                player.set_xwindow(frame.winfo_id())
        """Read 4 URLs and play them."""
        filepath = SPECIFIED_FILE
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                urls = [line.strip() for line in f.read().splitlines() if line.strip()]
            for i in range(line_count):
                if i < len(urls):
                    self.players[i].set_media(self.vlc_instance.media_new(urls[i]))
                    self.players[i].play()
                else:
                    self.players[i].stop()
        self.muteall
        self.root.focus_force()
    def reload(self,event):
        filepath = SPECIFIED_FILE
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                urls = [line.strip() for line in f.read().splitlines() if line.strip()]
            for i in range(4):
                if i < len(urls):
                    self.players[i].set_media(self.vlc_instance.media_new(urls[i]))
                    self.players[i].play()
                else:
                    self.players[i].stop()
        self.root.focus_force()

    def muteall(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(True)

    def toggle_mute1(self, event):
        self.players[0].audio_set_mute(False)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(True)
        self.my_label.config(text="Playing Video 1")

    def toggle_mute2(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(False)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(True)

        self.my_label.config(text="Playing Video 2")
    def toggle_mute3(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(False)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(True)

        self.my_label.config(text="Playing Video 3")
    def toggle_mute4(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(False)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(True)

        self.my_label.config(text="Playing Video 4")
    def toggle_mute5(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(False)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(True)

        self.my_label.config(text="Playing Video 5")
    def toggle_mute6(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(False)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(True)

        self.my_label.config(text="Playing Video 6")
    def toggle_mute7(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(False)
        self.players[7].audio_set_mute(True)
        self.my_label.config(text="Playing Video 7")
    def toggle_mute8(self, event):
        self.players[0].audio_set_mute(True)
        self.players[1].audio_set_mute(True)
        self.players[2].audio_set_mute(True)
        self.players[3].audio_set_mute(True)
        self.players[4].audio_set_mute(True)
        self.players[5].audio_set_mute(True)
        self.players[6].audio_set_mute(True)
        self.players[7].audio_set_mute(False)
        self.my_label.config(text="Playing Video 8")

    def on_close(self):
        """Cleanup."""
        for p in self.players:
            p.stop()
            p.release()
        self.vlc_instance.release()
        self.root.destroy()
    def on_z(self, event):
        root.destroy()
	
    def on_y(self, event):
        self.root.focus_force()
if __name__ == "__main__":
    root = tk.Tk()
    app = VLCQuadrantsApp(root)
    root.protocol("WM_DELETE_WINDOW", app.on_close)
    root.mainloop()
