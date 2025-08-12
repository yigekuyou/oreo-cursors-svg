#!/usr/bin/env bash

# Oreo cursors, based on KDE Breeze
# Copyright (c) 2016 Keefer Rourke <keefer.rourke@gmail.com>
# Copyright (c) 2020 Sergei Eremenko <https://github.com/SmartFinn>

set -e
ruby generator/convert.rb
convert_to_local(){
	local src_dir="$1"
	local out_dir="$2"
	local svg=$(ls $JSON)
	mkdir -p $out_dir
	for i in  $svg ;do
	mkdir -p $src_dir/$i
	cp $JSON/$i $src_dir/$i/metadata.json
	if [ -f $src_dir/$i.svg ];then
	mv $src_dir/$i.svg $src_dir/$i
	else
	for file in $src_dir/$i-*.svg; do
	mv $file $src_dir/$i
	done
	fi
	done


	mv $src_dir/index.theme $out_dir/
	mv $src_dir $out_dir/cursors_scalable
}
convert_to_x11cursor() {
	local src_dir="$1"
	local out_dir="$2"
	echo -ne "Generating cursor theme...\\r"
	kcursorgen --svg-theme-to-xcursor --svg-dir=$src_dir/cursors_scalable --xcursor-dir=$out_dir --sizes=16 --scales=1
	echo -e "Generating cursor theme... DONE"
}

create_aliases() {
	local out_dir="$1"
	local symlink target

	echo -ne "Generating shortcuts...\\r"
	while read -r symlink target; do
		[ -e "$out_dir/$symlink" ] && continue
		ln -sf "$target" "$out_dir/$symlink"
	done < "$ALIASES"
	echo -e "Generating shortcuts... DONE"
}

SCRIPT_DIR="$(dirname "$0")"

: "${SRC_DIR:="$SCRIPT_DIR"/src}"
: "${OUT_DIR:="$SCRIPT_DIR"/dist}"
: "${BUILD_DIR:="$SCRIPT_DIR"/build}"
: "${ALIASES:="$SCRIPT_DIR"/src/cursorList}"
: "${CONFIG_DIR:="$SCRIPT_DIR"/src/config}"

for theme_src_dir in "$SRC_DIR"/*; do
	# skip directory that not contains index.theme file
	[ -f "$theme_src_dir/index.theme" ] || continue
	theme_name="$(basename "$theme_src_dir")"
	theme_build_dir="$BUILD_DIR/$theme_name"
	theme_out_dir="$OUT_DIR/$theme_name"
	JSON="$SCRIPT_DIR/generator/oreo_base_metadata/"
	echo "=> Workon '$theme_src_dir' ..."
	convert_to_local "$theme_src_dir" "$theme_build_dir"
	convert_to_x11cursor "$theme_build_dir" "$theme_build_dir"/cursors
	create_aliases "$theme_build_dir"/cursors
	create_aliases "$theme_build_dir"/cursors_scalable

	cp -f cursor.theme "$theme_build_dir"/
	sed -i 's/oreo_base_cursors/'$theme_name'/g' $theme_build_dir/cursor.theme
	mv $BUILD_DIR $OUT_DIR
done
