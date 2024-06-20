#!/bin/bash

# Fix invalid escape sequences in GenerateLilyPondFileController.swift
sed -i '' 's/\\version/\\\\version/g' Sources/App/Controllers/GenerateLilyPondFileController.swift
sed -i '' 's/\\header/\\\\header/g' Sources/App/Controllers/GenerateLilyPondFileController.swift
sed -i '' 's/\\score/\\\\score/g' Sources/App/Controllers/GenerateLilyPondFileController.swift
sed -i '' 's/\\layout/\\\\layout/g' Sources/App/Controllers/GenerateLilyPondFileController.swift
sed -i '' 's/\\midi/\\\\midi/g' Sources/App/Controllers/GenerateLilyPondFileController.swift

# Remove invalid comment syntax in GenerateLilyPondFileController.swift and GenerateMIDIFileController.swift
sed -i '' '/# Generate PDF and MIDI from LilyPond file/d' Sources/App/Controllers/GenerateLilyPondFileController.swift
sed -i '' '/# Add events to the track/d' Sources/App/Controllers/GenerateMIDIFileController.swift
sed -i '' '/# Save the MIDI file/d' Sources/App/Controllers/GenerateMIDIFileController.swift

# Remove MIDIKit import from GenerateMIDIFileController.swift since it's not available
sed -i '' '/import MIDIKit/d' Sources/App/Controllers/GenerateMIDIFileController.swift

echo "Patches applied successfully!"
