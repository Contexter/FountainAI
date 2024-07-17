#!/bin/bash

# Step 1: Create a backup branch
git checkout -b backup

# Step 2: Create an editorial branch
git checkout -b editorial

# Step 3: Organize the editorial branch for shipping
mkdir -p episodes/Episode1
mkdir -p episodes/Episode2
mkdir -p episodes/Episode3
mkdir -p episodes/Episode4
mkdir -p episodes/Episode5
mkdir -p episodes/Episode6
mkdir -p episodes/Episode7
mkdir -p episodes/Episode8
mkdir -p episodes/Episode9
mkdir -p episodes/Episode10

mv episodes/episode1.md episodes/Episode1/episode1.md
mv episodes/episode2.md episodes/Episode2/episode2.md
mv episodes/episode3.md episodes/Episode3/episode3.md
mv episodes/episode4.md episodes/Episode4/episode4.md
mv episodes/episode5.md episodes/Episode5/episode5.md
mv episodes/episode6.md episodes/Episode6/episode6.md
mv episodes/episode7.md episodes/Episode7/episode7.md
mv episodes/episode8.md episodes/Episode8/episode8.md
mv episodes/episode9.md episodes/Episode9/episode9.md
mv episodes/episode10.md episodes/Episode10/episode10.md

mv setup_all.sh episodes/Episode1/setup_all.sh
mv setup_episodes.sh episodes/Episode1/setup_episodes.sh
mv setup_project_structure.sh episodes/Episode1/setup_project_structure.sh

if [ -d "dev_ShellScripting" ]; then
    mv dev_ShellScripting/*.sh episodes/Episode1/
fi

# Commit the changes
git add .
git commit -m "Organize project structure for shipping"
git push origin editorial

# Step 4: Create a new main branch for shipping
git checkout -b shipping
git push origin shipping

# Step 5: Set the default branch to shipping (on GitHub)
echo "Please set the default branch to 'shipping' on GitHub via the web interface."

# Step 6: Restore the original main branch
git checkout backup
git checkout -b main
git push -f origin main

echo "Process complete. The 'shipping' branch is now the default branch for shipping structure."

