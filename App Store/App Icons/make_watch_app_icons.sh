#!/usr/bin/env bash

function usage
{
  echo "usage: $0 image"
  echo "Make app icons from the large app icon. For a list of all required app icons, open the Target in Xcode, go to the first General tab, scroll down to App Icons."
  exit 1
}

img=$1
if [ -z "${img}" ]; then
  img="../Large App Icon - Apple Watch.png"
  #usage
fi

function resize_img
{
  size=$1

  resize_opt="${size}x${size}"
  out_img="AppIconWatch_${resize_opt}.png"

  echo convert -resize ${resize_opt} "$img" "$out_img"
  convert -resize ${resize_opt} "$img" "$out_img"
}

# Apple Watch
resize_img 29
resize_img 36
resize_img 58
resize_img 87
resize_img 80
resize_img 88
resize_img 172
resize_img 196

# Notifications
resize_img 48
resize_img 55
