#!/bin/bash

desc=$(git describe --tags)

function godot_export() {
	echo "Exporting $1...."

	suffix=".x86_64"
	if [ "$1" == "html5" ]; then
		suffix=".html"
	elif [ "$1" == "windows-x64" ]; then
		suffix=".exe"
	elif [ "$1" == "macos-universal" ]; then
		suffix=".dmg"
	fi

	name="bubble_ranch"
	if [ "$1" == "html5" ]; then
		name="index"
	fi

	build_dir="Builds/$1"
	mkdir -p "$build_dir"

	godot --headless --quiet --export-release "$1" "$build_dir/$name$suffix" || exit

	echo "zipping!"
	zip "Builds/${1}_${desc}.zip" -j "$build_dir"/*

	channel="$1"

	#butler push --userversion "$desc" "$build_dir" "generalred/bubble-ranch-a-cozy-hunt:$channel"
}


if [ -z "$1" ]; then
	godot_export "linux-x64"
elif [ "$1" == "all" ]; then
	godot_export "html5"
	godot_export "linux-x64"
	godot_export "windows-x64"
	#godot_export "macos-universal"
else
	godot_export "$1"
fi
