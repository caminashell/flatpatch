################################################################################
# Copyright (c) 2026 Caminashell
#
# This file is sourced from github.com/caminashell/flatpatch
#
# Flatpatch is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Caminashell has distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
################################################################################

#!/bin/bash

# I really enjoyed creating this script. I hope it helps!
# Built to automate applying launch parameters to dashboard links after an update.

# !!! PLEASE READ BELOW BEFORE USING THIS SCRIPT !!! #

# It may need sudo elevation to run, if links are not in a user accessible location.
# It uses (echo, eval, grep, sed) but does not require any additional software to be installed.
# It does not change any core application files.
# It will require some configuration to process your links properly - see below.
# It is not only for flatpak applications, but any application that uses a desktop file to launch.

# (Flatpak) Applications to patch:
APPS=(
  "APP=com.vivaldi.Vivaldi;PATCH=--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
  "APP=dev.vencord.Vesktop;PATCH=--user-agent-os=windows"
)
# Vivaldi patch: Enable Vivaldi features to play HEVC video (helps with Plex server not needing to transcode)
# Discord patch: Forced user-agent-os to windows to fix Discord API issues and CDN lockout

# Application(app): Change this to the name of the application
#                   Do not include the ".desktop" extension
# E.g. "com.vivaldi.Vivaldi"

# String(str): Change this to the string to check for
#              It is not necessary to prefix the string with a space(r)
# E.g. "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"

################################################################################

# Directory to search (change this to the directory you want)
DIRECTORY="/var/lib/flatpak/app"

# Note: OS uses links stored in the following directory (below).
#       Each link is a symlink to the applications respective desktop file.
#       Previously, patching these would rewrite the file and break the icon.
#       "/var/lib/flatpak/exports/share/applications"

echo "-----"

# Loop through the array and parse each object string
for APP in "${APPS[@]}"; do

  # Split the string into key-value pairs
  IFS=';' read -ra key_value_pairs <<< "$APP"

  # Loop through the key-value pairs
  for PAIR in "${key_value_pairs[@]}"; do
    IFS='=' read -r key value <<< "$PAIR"
    eval $PAIR
  done

  # Print process information for logging
  echo -e "\nApplication:" $APP
  echo -e "String:" $PATCH"\n"

  # File pattern or extension to search for
  FILE_PATTERN="$APP.desktop"

  # Find all files in the directory (you can change the file type with -name or -type)
  find "$DIRECTORY" -type f -name "$FILE_PATTERN" | while read -r FILE; do

    if [[ "$FILE" == *"/export/share/"* ]]; then

      # Check if the file is readable and writable
      if [[ -r "$FILE" && -w "$FILE" ]]; then
        echo "Processing file: $FILE"

        # Search for the text in the file
        grep -qe " $PATCH" $FILE

        # Check the exit status of grep
        if [ $? -eq 0 ]; then

          # Print true statement
          echo -e "\n[✓] The above file is already patched.\n"
        else

          # Print false statement
          echo -e "\n[+] Patched the above file.\n"

          # Find and add the patch string to all locations of the file
          sed -i "s/\( $APP\)/\1 $PATCH/" $FILE
        fi

      else
        echo -e "[!] Skipping file (not readable/writable): $FILE\n"
      fi
    fi

  done

  # echo "Application patch complete."
  echo "-----"

done

# Print end statement
echo -e "\nProcess complete."
