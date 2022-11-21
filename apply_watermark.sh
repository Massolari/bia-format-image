#!/bin/sh

echo "Iniciando script..."

image_path=public/img/image.*
image_converted_path=public/img/image_converted.png

rm $image_converted_path
convert $image_path -auto-orient $image_converted_path
width=$(identify -define heic:preserve-orientation=true -format "%w" $image_converted_path)
height=$(identify -define heic:preserve-orientation=true -format "%h" $image_converted_path)

echo $width'x'$height
logo_dimension=$(($width / 3))
logo_dimension_str=$(printf "%dx%d" $logo_dimension $logo_dimension)
echo $logo_dimension_str

composite \
    -verbose \
    -compose screen \
    \( public/img/logo.png \
        -gravity NorthEast \
        -resize "$logo_dimension_str" \
        -geometry +10+40 \
    \) \
    $image_converted_path \
    public/img/result.png

rm $image_path
echo "Script finalizado!"
        # -colorspace LinearGray \

