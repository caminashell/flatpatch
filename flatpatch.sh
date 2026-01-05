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

apps=(
  "loc=./test;app=com.vivaldi.Vivaldi;str=--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
  "loc=./test;app=dev.vencord.Vesktop;str=--user-agent-os=windows"
)

# Location(loc): Change this to the location of the desktop files
# E.g. "/var/lib/flatpak/exports/share/applications"

# Application(app): Change this to the name of the application
# E.g. "com.vivaldi.Vivaldi"

# String(str): Change this to the string to check for
# E.g. " --enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"

# Vivaldi patch: Enable Vivaldi features to play HEVC video (helps with Plex server not needing to transcode)
# Discord patch: Forced user-agent-os to windows to fix Discord API issues and CDN lockout

echo "-----"

# Loop through the array and parse each object string
for app in "${apps[@]}"; do

  # Split the string into key-value pairs
  IFS=';' read -ra key_value_pairs <<< "$app"

  # Loop through the key-value pairs
  for pair in "${key_value_pairs[@]}"; do
    IFS='=' read -r key value <<< "$pair"
    eval $pair
  done

  # Print process information for logging
  echo "Application:" $app
  echo "Location:" $loc
  echo "String:" $str

  # Search for the text in the file
  grep -qe $str $loc/$app.desktop

  # Check the exit status of grep
  if [ $? -eq 0 ]; then

    # Print true statement
    echo -e "\n$app is already patched."
  else

    # Print false statement
    echo -e "\nPatched $app"

    # Find and add the patch string to all locations of the file
    sed -i "s/\($app\)/\1 $str/" $loc/$app.desktop
  fi

  echo "-----"
done

# Print end statement
echo "Done"
