#!/bin/bash

# Start in the current directory or a user-provided argument
START_DIR="${1:-$PWD/m3ufiles}"

while true; do
    # Open dialog file selector
    SELECTED_FILE=$(dialog --stdout --title "Select a File" --fselect "$START_DIR/" 14 60)

    # Exit the loop if the user cancels or presses Esc
    if [ -z "$SELECTED_FILE" ]; then
        echo "Selection cancelled."
        exit 0
    fi

    # Check if the selection is a directory
    if [ -d "$SELECTED_FILE" ]; then
        # Update START_DIR to open the newly selected directory on the next iteration
        START_DIR="$SELECTED_FILE"
        
        # Display an alert message to the user
        dialog --title "Error" --msgbox "You selected a directory.\nPlease choose a file." 6 40
    elif [ -f "$SELECTED_FILE" ]; then
        # A regular file was successfully selected
        break
    else
        # Handle cases where the path doesn't exist or isn't a regular file
        dialog --title "Error" --msgbox "Invalid choice or file does not exist." 6 45
    fi
done

# Clear the screen after dialog exits
clear

    echo "You selected: $SELECTED_FILE"
    ./mpvgrid.sh $SELECTED_FILE > /dev/null 2>&1 &
   

