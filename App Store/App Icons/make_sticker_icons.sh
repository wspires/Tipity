#!/usr/bin/env bash

function usage
{
  echo "usage: $0 image"
  echo "Make app icons from the large app icon. For a list of all required app icons, open the Target in Xcode, go to the first General tab, scroll down to App Icons."
  exit 1
}

img=$1
if [ -z "${img}" ]; then
  img="../App Icon/Large App Icon - Sticker.png"
  #usage
fi

function resize_img
{
  width=$1
  height=$2

  resize_opt="${width}x${height}"
  out_img="Sticker_${resize_opt}.png"

  echo convert -resize "${resize_opt}!" "$img" "$out_img"
  convert -resize "${resize_opt}!" "$img" "$out_img"
}

# Messages iPhone
#resize_img 60 45
resize_img 120 90
resize_img 180 135

# Messages iPad
#resize_img 67 50
resize_img 134 100
#resize_img 201 150

# Messages iPad Pro
#resize_img 74 55
resize_img 148 110
#resize_img 222 165

# Messages
#resize_img 27 20
resize_img 54 40
resize_img 81 60

#resize_img 32 24
resize_img 64 48
resize_img 96 72

resize_img 1024 768
