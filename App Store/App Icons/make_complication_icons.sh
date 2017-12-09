#!/usr/bin/env bash

function usage
{
  echo "usage: $0 image"
  echo "Make app icons from the large app icon. For a list of all required app icons, open the Target in Xcode, go to the first General tab, scroll down to App Icons."
  exit 1
}

img=$1
if [ -z "${img}" ]; then
  img="../App Icon/Complication.png"
  #usage
fi

function resize_img
{
  size=$1

  resize_opt="${size}x${size}"
  out_img="Complication_${resize_opt}.png"

  echo convert -resize ${resize_opt} "$img" "$out_img"
  convert -resize ${resize_opt} "$img" "$out_img"
}

# https://developer.apple.com/watch/human-interface-guidelines/icons-and-images/

# Circular
resize_img 32
resize_img 36
resize_img 40

# Modular
resize_img 52
resize_img 58
resize_img 64

# Utility
resize_img 40
resize_img 44
resize_img 50

# Extra large
resize_img 156
resize_img 174
resize_img 192
