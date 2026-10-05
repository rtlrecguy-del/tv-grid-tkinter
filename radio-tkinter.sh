#!/usr/bin/env /usr/bin/python3
import sys
import tkinter as tk
from tkinter import ttk
import subprocess
import mpv

# 1. Define your 4 stream or file URLs here
URL_1 = ""
URL_2 = ""
URL_3 = ""
URL_4 = ""

class MultiPlayerGrid:
    def __init__(self, root):
        self.root = root
        self.root.title("4-Quadrant MPV Player Grid")
        self.root.geometry("1920x1080")
        self.root.bind("<Triple-Left>", self.on_z)
        # Configure the grid to expand equally
        self.label = tk.Label(self.root, text="Up=CNN,Down=MSNBC,Left=Fox News,Right=NPR", font=("Arial", 24, "bold"), bg="black", fg="white")
        self.label.pack(side=tk.TOP, fill=tk.X)
        self.grid_frame = tk.Frame(self.root, bg="black")
        self.grid_frame.pack(side=tk.TOP, fill=tk.BOTH, expand=True)
        self.grid_frame.rowconfigure(0, weight=1)
        self.grid_frame.rowconfigure(1, weight=1)
        self.grid_frame.columnconfigure(0, weight=1)
        self.grid_frame.columnconfigure(1, weight=1)
        # Initialize 4 mpv players
        self.players = []
        # Create frames for each quadrant to hold the player window
        self.frames = []
        coords = [(0, 0), (0, 1), (1, 0), (1, 1)]
        urls = [URL_1, URL_2, URL_3, URL_4]

        for i, (row, col) in enumerate(coords):
            frame = tk.Frame(self.grid_frame, bg="black")
            frame.grid(row=row, column=col, sticky="nsew", padx=2, pady=2)
            self.frames.append(frame)

            # Spawn mpv player
            # For Windows/Mac, you may need to pass vo='libmpv' or similar, depending on your system.
            player = mpv.MPV()
            self.players.append(player)
            
            # Start playing the assigned URL
            player.play(urls[i])

        # Bind keyboard shortcuts
        self.root.bind("<Up>", lambda event: self.toggle_mute(0))
        self.root.bind("<Down>", lambda event: self.toggle_mute(1))
        self.root.bind("<Left>", lambda event: self.toggle_mute(2))
        self.root.bind("<Right>", lambda event: self.toggle_mute(3))

        # Focus window so it captures keys
        self.root.focus_set()
    def toggle_mute(self, index):
        self.players[0].mute = True
        self.players[1].mute = True
        self.players[2].mute = True
        self.players[3].mute = True
        if 0 <= index < len(self.players):
            # Toggle the mute property using python-mpv API
            current_mute = self.players[index].mute
            self.players[index].mute = not current_mute
            print(f"Quadrant {index + 1} mute toggled. Now: {'Muted' if not current_mute else 'Unmuted'}")
            if not self.players[0].mute:
                 self.label.config(text="Playing CNN          | Up=CNN,Down=MSNBC,Left=Fox News,Right=NPR")
            if not self.players[1].mute:
                 self.label.config(text="Playing MSNBC        | Up=CNN,Down=MSNBC,Left=Fox News,Right=NPR")
            if not self.players[2].mute:
                 self.label.config(text="Playing Fox News     | Up=CNN,Down=MSNBC,Left=Fox News,Right=NPR")
            if not self.players[3].mute:
                 self.label.config(text="Playing NPR          | Up=CNN,Down=MSNBC,Left=Fox News,Right=NPR")
    
    def on_z(self, event):
        root.destroy()
	
if __name__ == "__main__":
    root = tk.Tk()
    app = MultiPlayerGrid(root)
    root.mainloop()
