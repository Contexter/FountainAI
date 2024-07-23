#!/bin/bash

# Create a backup of the episodes directory
cp -r episodes episodes_backup

# Rename episode files
mv episodes/Episode2/episode2.md episodes/Episode2/temp_episode2.md
mv episodes/Episode3/episode3.md episodes/Episode2/episode2.md
mv episodes/Episode2/temp_episode2.md episodes/Episode3/episode3.md

# Print success message
echo "Episodes have been backed up, renamed, and placed into the correct folders successfully."

