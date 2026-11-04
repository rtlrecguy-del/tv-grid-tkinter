#!/bin/bash
# Start in the current directory or a user-provided argument
START_DIR="${1:-$PWD/playlists}"
process_selection() {
# xConfiguration - Update these paths and your keywords
KEYWORDS="$result"
INPUT_FILE=$SELECTED_FILE
OUTPUT_FILE="/tmp/outputfile.m3u8"
# Add the exact names or keywords of the channels you want to keep
# Separate multiple keywords with a pipe character |

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# Initialize the new m3u8 file with the required header
echo "#EXTM3U" > "$OUTPUT_FILE"

echo "Filtering channels matching: $KEYWORDS..."
channels_found=0
# Read the file line by line
while IFS= read -r line || [ -n "$line" ]; do
    # Skip the global header if encountered inside the loop
    [[ "$line" =~ ^#EXTM3U ]] && continue

    # Check if the line is an info line (#EXTINF) and matches your keywords
    if [[ "$line" =~ ^#EXTINF ]] && echo "$line" | grep -Eiq "$KEYWORDS"; then
        # Write the info line to the new file
        echo "$line" >> "$OUTPUT_FILE"
        
        # Read the immediately following line, which contains the stream URL
        if IFS= read -r url_line || [ -n "$url_line" ]; then
            echo "$url_line" >> "$OUTPUT_FILE"
            ((channels_found++))
        fi
    fi
done < "$INPUT_FILE"

echo "Done! Saved $channels_found matching channels to '$OUTPUT_FILE'."
INPUT_FILE=$OUTPUT_FILE
OUTPUT_FILE=$(dialog --stdout --title "OUTPUT File Name Required" --inputbox "Please enter your text:" 8 40 "$PWD/m3ufiles/")
RESPONSE=$?

if [ $RESPONSE -eq 0 ]; then
    echo "You entered: $USER_INPUT"
else
    echo "Input canceled."
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

echo "Parsing playlist channels... Please wait..."

# Arrays to hold parsed channel details
declare -a names
declare -a extinfs
declare -a urls
declare -a groups
declare -a selected_flags

current_extinf=""
current_group=""

# Read and parse file
while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | tr -d '\r')
    
    if [[ "$line" =~ ^#EXTINF: ]]; then
        current_extinf="$line"
        current_name=$(echo "$line" | sed 's/^.*,//')
        current_group=""
        continue
    fi
    
    if [[ "$line" =~ ^#EXTGRP: ]] || [[ "$line" =~ ^#EXTVLCOPT: ]]; then
        current_group="$current_group"$'\n'"$line"
        continue
    fi
    
    if [[ ! "$line" =~ ^# ]] && [[ -n "$line" ]]; then
        if [ -n "$current_name" ]; then
            names+=("$current_name")
            extinfs+=("$current_extinf")
            urls+=("$line")
            groups+=("$current_group")
            selected_flags+=(0)
        fi
        current_extinf=""
        current_group=""
        current_name=""
    fi
done < "$INPUT_FILE"

total_channels=${#names[@]}

if [ "$total_channels" -eq 0 ]; then
    echo "No channels found in '$INPUT_FILE'."
    exit 1
fi

# Pagination Configuration
PAGE_SIZE=15
current_start=0

while true; do
    clear
    # Calculate bounds for current page view
    current_end=$((current_start + PAGE_SIZE))
    if [ $current_end -gt $total_channels ]; then
        current_end=$total_channels
    fi
    
    echo "============================================="
    echo "       SCROLLABLE CHANNEL SELECTOR           "
    echo "============================================="
    printf " Showing channels %d-%d of %d\n" "$((current_start + 1))" "$current_end" "$total_channels"
    echo "---------------------------------------------"
    
    # Display only the current page window
    for ((i=current_start; i<current_end; i++)); do
        num=$((i + 1))
        if [ "${selected_flags[$i]}" -eq 1 ]; then
            printf "[X] %5d) %s\n" "$num" "${names[$i]}"
        else
            printf "[ ] %5d) %s\n" "$num" "${names[$i]}"
        fi
    done
    
    echo "---------------------------------------------"
    echo " Navigation Commands: "
    echo "   [n] Next Page      [p] Prev Page"
    echo "   [s] Save & Finish  [q] Quit without saving"
    echo "---------------------------------------------"
    read -p "Enter number to toggle, or navigation command: " choice
    
    case "$choice" in
        n|N)
            # Advance to next page if possible
            if [ $((current_start + PAGE_SIZE)) -lt $total_channels ]; then
                current_start=$((current_start + PAGE_SIZE))
            fi
            ;;
        p|P)
            # Regress to previous page if possible
            if [ $((current_start - PAGE_SIZE)) -ge 0 ]; then
                current_start=$((current_start - PAGE_SIZE))
            fi
            ;;
        q|Q)
            echo "Exiting without saving changes."
            exit 0
            ;;
        s|S)
            break
            ;;
        *)
            # Check if user typed a valid absolute channel number
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $total_channels ]; then
                idx=$((choice - 1))
                # Toggle current index status flag
                if [ "${selected_flags[$idx]}" -eq 0 ]; then
                    selected_flags[$idx]=1
                else
                    selected_flags[$idx]=0
                fi
            else
                echo "Invalid selection. Press [Enter] to continue..."
                read -r
            fi
            ;;
    esac
done

# Compile final playlist output payload
echo "#EXTM3U" > "$OUTPUT_FILE"
saved_count=0

for i in "${!names[@]}"; do
    if [ "${selected_flags[$i]}" -eq 1 ]; then
        echo "${extinfs[$i]}" >> "$OUTPUT_FILE"
        if [ -n "${groups[$i]}" ]; then
            echo "${groups[$i]}" >> "$OUTPUT_FILE"
        fi
        echo "${urls[$i]}" >> "$OUTPUT_FILE"
        ((saved_count++))
    fi
done

echo "---------------------------------------------"
echo "Success! Compiled $saved_count channels into '$OUTPUT_FILE'."
	
}

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
readarray -t items < <(grep -o 'group-title="[^"]*"' $SELECTED_FILE | sed 's/group-title="//;s/"//' | sort -u)
selected=()
# Display menu
while true; do
    clear
    echo "================================"
    echo " Select Items (x = select)"
    echo " Press n when finished"
    echo "================================"
    echo

    for i in "${!items[@]}"; do
        if [[ "${selected[$i]}" == "x" ]]; then
            mark="x"
        else
            mark=" "
        fi

        printf "%2d. [%s] %s\n" "$((i+1))" "$mark" "${items[$i]}"
    done

    read -rp "Enter item number, or n to finish: " choice

    # Finish selection



    if [[ "$choice" == "n" ]]; then
for i in "${!items[@]}"; do
    if [[ "${selected[$i]}" == "x" ]]; then
        if [[ -n "$result" ]]; then
            result+="|"
        fi
        result+="${items[$i]}"
fi
done
echo "$result"
         process_selection 
         break
    fi

    # Toggle selection
    if [[ "$choice" =~ ^[0-9]+$ ]] &&
 (( choice >= 1 && choice <= ${#items[@]} )); then

        index=$((choice-1))

        if [[ "${selected[$index]}" == "x" ]]; then
            selected[$index]=""
        else
            selected[$index]="x"
        fi
    fi
done

# Build pipe-separated variable




