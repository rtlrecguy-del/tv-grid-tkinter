#!/usr/bin/env /usr/bin/python3
import tkinter as tk
from tkinter import filedialog, messagebox
import re
import stat
import os
from pathlib import Path
import shutil
class M3U8_CheckboxApp:
    def __init__(self, root):
        self.root = root
        self.root.title("M3U8 Channel Selector")
        self.root.geometry("1920x1080")
        self.root.bind('1', self.on_z)
        # Variable to store the URLs of checked channels
        self.selected_urls = []
        
        # Store checkboxes and their corresponding URLs
        self.channel_vars = []
        self.channel_data = []

        # UI Elements
        self.label = tk.Label(root, text="No M3U8 file loaded", font=("Arial", 12))
        self.label.pack(pady=10)

        self.load_btn = tk.Button(root, text="Load M3U8 File", command=self.load_file)
        self.load_btn.pack(pady=5)

        # Frame to hold the checkboxes
        self.canvas = tk.Canvas(root)
        self.scrollbar = tk.Scrollbar(root, orient="vertical", command=self.canvas.yview)
        self.scrollable_frame = tk.Frame(self.canvas)

        self.scrollable_frame.bind(
            "<Configure>",
            lambda e: self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        )

        self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        self.canvas.configure(yscrollcommand=self.scrollbar.set)

        self.canvas.pack(side="left", fill="both", expand=True)
        self.scrollbar.pack(side="right", fill="y")

        # Updated button text to match the new file-writing logic
        self.save_btn = tk.Button(root, text="Export exactly less than 8 URLs to File", command=self.save_selection_to_file)
        self.save_btn.pack(pady=10)

    def load_file(self):
        file_path = filedialog.askopenfilename(filetypes=[("M3U8 playlists", "*.m3u8 *.m3u"), ("All files", "*.*")])
        if not file_path:
            return

        try:
            self.channel_data = []
            
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.readlines()

            current_name = "Unknown Channel"
            has_extinf = False

            for line in lines:
                line = line.strip()
                if not line:
                    continue

                if line.startswith("#EXTINF:"):
                    has_extinf = True
                    if "," in line:
                        current_name = line.split(",")[-1].strip()
                    else:
                        current_name = re.sub(r'#EXTINF:[-0-9. ]*', '', line).strip()
                    
                    if not current_name:
                        current_name = "Unnamed Channel"
                        
                elif not line.startswith("#") and has_extinf:
                    self.channel_data.append({
                        "name": current_name,
                        "url": line
                    })
                    current_name = "Unknown Channel"
                    has_extinf = False

            self.label.config(text=f"Loaded {len(self.channel_data)} channels from: {file_path.split('/')[-1]}")
            self.populate_checkboxes()

        except Exception as e:
            messagebox.showerror("Error", f"Failed to read file: {str(e)}")

    def populate_checkboxes(self):
        for widget in self.scrollable_frame.winfo_children():
            widget.destroy()

        self.channel_vars = []
        self.selected_urls = []

        columns_count = 7
        
        for i, channel in enumerate(self.channel_data):
            row = i // columns_count
            col = i % columns_count

            var = tk.IntVar()
            self.channel_vars.append((var, channel["url"]))

            cb = tk.Checkbutton(
                self.scrollable_frame, 
                text=channel["name"], 
                variable=var, 
                anchor="w",
                width=18,       
                wraplength=120  
            )
            cb.grid(row=row, column=col, padx=4, pady=4, sticky="w")

    def save_selection_to_file(self):
        self.selected_urls = []
        
        # Pull checked state variables
        for var, url in self.channel_vars:
            if var.get() == 1:
                self.selected_urls.append(url)

        # Enforce the strict "exactly four" rule

        # Prompt user to choose where to save the text file
        output_file = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text Files", "*.txt"), ("All Files", "*.*")],
            title="Save Selected URLs"
        )
        
        if not output_file:
            return

        try:
            # Write to the file, one URL per line
            with open(output_file, "w", encoding="utf-8") as f:
                for url in self.selected_urls:
                    f.write(url + "\n")
            
            messagebox.showinfo("Success", f"Successfully saved less than 8 URLs to:\n{output_file}")
            print(f"\n--- Written to {os.path.basename(output_file)} ---")
            print("\n".join(self.selected_urls))
            filename_only = Path(output_file).stem
            path2 = f"/home/radio/{filename_only}.sh"
         
            
            shutil.copyfile("/home/radio/tv-tkinter3.sh", path2)
            search_text = "/home/radio/tv-tkinter3.sh"
            search_text1 = "test5"
            with open(path2, "r", encoding="utf-8") as file:
                data1 = file.read()
                data1 = data1.replace(search_text1, filename_only)
            with open(path2, "w", encoding="utf-8") as file:
                file.write(data1)
            st = os.stat(path2)
            os.chmod(path2, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        except Exception as e:
            messagebox.showerror("File Error", f"Could not write file: {str(e)}")     
    def on_z(self, event):
        root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = M3U8_CheckboxApp(root)
    root.mainloop()
