#!/usr/bin/env /usr/bin/python3
import os
import sys
import tkinter as tk
import mpv
import urllib.request
import os

# Configuration


# The remote URL hosting your .m3u8 playlist file

# Specify the path to your local .m3u8 playlist file
file_path = sys.argv[1]


# Specify the path to your local .m3u8 playlist file

playlist_array = []

try:
    with open(file_path, "r", encoding="utf-8") as file:
        # Replacing \r\n ensures hidden Windows line endings don't overwrite terminal lines
        lines = [line.replace("\r", "").strip() for line in file if line.strip()]

    # Explicitly iterate through the indices of the lines array
    for i in range(len(lines)):
        if lines[i].startswith("#EXTINF"):
            # Safe comma separation: falls back to the whole line if no comma is found
            if "," in lines[i]:
                channel = lines[i].split(",")[-1].strip()
            else:
                channel = lines[i].replace("#EXTINF:", "").strip()
            
            # Look ahead exactly one line for the corresponding URL
            if i + 1 < len(lines) and not lines[i+1].startswith("#"):
                url = lines[i+1].strip()
                playlist_array.append([channel, url])

except FileNotFoundError:
    print(f"Error: The file at '{file_path}' was not found.")
except Exception as e:
    print(f"An error occurred while parsing the file: {e}")
if len(playlist_array) == 9:
    GRID_SIZE2 = 3
    GRID_SIZE1 = 3
if len(playlist_array) == 4:
    GRID_SIZE2 = 2
    GRID_SIZE1 = 2
if len(playlist_array) == 6:
    GRID_SIZE2 = 3
    GRID_SIZE1 = 2

TOTAL_PLAYERS = GRID_SIZE1 * GRID_SIZE2

# PRINT LOOP: Verify this block is completely left-aligned (outside the parsing loop)

# Iterating and printing using the first and second elements
# Iterating and printing using the first and second elements
class VideoGridApp:
    def __init__(self, root):
        self.root = root
        self.root.title("9-Channel mpv Tkinter Matrix")
        self.root.configure(bg="black")
        root.bind("q", lambda event: self.cleanup())
        root.bind("Q", lambda event: self.cleanup())        
        self.players = []
        self.labels = []
        
        # Load URLs from file
        
        # Build Grid Layout
        for i in range(TOTAL_PLAYERS):
            row = (i // GRID_SIZE2) * 2
            col = i % GRID_SIZE2
            
            # Configure grid weight so things resize cleanly
            self.root.grid_columnconfigure(col, weight=1)
            self.root.grid_rowconfigure(row, weight=0)      # Label row
            self.root.grid_rowconfigure(row + 1, weight=1)  # Video row
            
            # 1. Bracket Label (e.g., "[1]")
            lbl = tk.Label(
                root, 
                text=f"{i + 1}-[{playlist_array[i][0]}]", 
                fg="white", 
                bg="black", 
                font=("Arial", 12, "bold")
            )
            lbl.grid(row=row, column=col, sticky="ew", pady=(5, 0))
            self.labels.append(lbl)
            
            # 2. Video Container Frame
            # Background frame must have a background color specified to generate a X11 Window ID on Linux
            video_frame = tk.Frame(root, bg="black", bd=0, highlightthickness=0)
            video_frame.grid(row=row + 1, column=col, sticky="nsew", padx=2, pady=2)
            
            # Force Tkinter to map the widget to the X server to get a real Window ID (wid)
            self.root.update_idletasks()
            wid = video_frame.winfo_id()
            
            # 3. Initialize python-mpv player
            # On Linux, log-file helps debug potential X11 embedding issues
            player = mpv.MPV(
                wid=str(wid),
                vo="xv",
                ytdl=True,  # Enable youtube-dl/yt-dlp integration for streaming links
                ytdl_format="worstvideo+worstaudio/worst",
                input_default_bindings=False,
                input_vo_keyboard=False,
                hls_bitrate='min'
                )
            self.players.append(player)
            # Load URL if available, otherwise idle
            # Start all streams as muted initially
            player.mute = True
            stream_url = playlist_array[i][1]

            player.play(stream_url)

        # Bind Keypresses 1-9
        for num in range(1, TOTAL_PLAYERS + 1):
            root.bind(str(num), self.make_key_handler(num - 1))
            
        # Select the first player by default on launch
        if self.players:
            self.select_player(0)

    def make_key_handler(self, index):
        """Creates a scoped callback for each specific key index."""
        return lambda event: self.select_player(index)

    def select_player(self, active_idx):
        """Handles exclusive unmuting and label color swapping."""
        for i, (player, label) in enumerate(zip(self.players, self.labels)):
            if i == active_idx:
                player.mute = False
                label.config(fg="red")
            else:
                player.mute = True
                label.config(fg="white")
    def cleanup(self):
        """Safely terminate mpv instances before window closes to prevent lingering processes."""
        for player in self.players:
            try:
                player.terminate()
            except Exception:
                pass
        self.root.destroy()
        sys.exit(0)

if __name__ == "__main__":
    root = tk.Tk()
    root.geometry("1920x1080")
    
    app = VideoGridApp(root)
	    
    # Catch window close event to clean up background mpv threads gracefully
    root.protocol("WM_DELETE_WINDOW", app.cleanup)
    root.mainloop()
