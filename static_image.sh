title='Too Many\nCooks'
caption='Starring\nLiam Dunne'

font_title="/System/Library/Fonts/fullhouse.ttf"
fontsize_title=28

font_caption="Palatino-BoldItalic"
fontsize_caption=13

path="~/Pictures/BuildPhotos"

#mkdir -p $path
#cd $path
PHOTO="TOO-MANY-COOKS-$(date +%y%m%d%H%M%S).png"
PHOTO_RESIZED="TOO-MANY-COOKS-$(date +%y%m%d%H%M%S)_resized.png"
PHOTO_RESIZED_BLUR="TOO-MANY-COOKS-$(date +%y%m%d%H%M%S)_resized_blur.png"
PHOTO_CAPTIONED="TOO-MANY-COOKS-$(date +%y%m%d%H%M%S)_captioned.png"
PHOTO_FILEMASK="TOO-MANY-COOKS-*_*.png"

echo $PHOTO

echo "### TAKE PHOTO ###"
printf "\a"
/usr/local/bin/imagesnap -w 1 $PHOTO
printf "\a"

echo "### CREATE RESIZED COPY OF PHOTO ###"
convert $PHOTO -resize 320x320\> -size 320x $PHOTO_RESIZED

echo "### CREATE PHOTO WITH CAPTION ###"
convert $PHOTO_RESIZED \
	-gravity center \
	-font "$font_title" -pointsize $fontsize_title \
	-stroke '#000C' -strokewidth 2 -annotate +0+20 "${title}" \
	-stroke  none   -fill yellow   -annotate +0+20 "${title}" \
	-gravity south \
	-font "$font_caption" -pointsize $fontsize_caption \
	-stroke '#000C' -strokewidth 2 -annotate +0+10 "${caption}" \
	-stroke  none   -fill yellow   -annotate +0+10 "${caption}" \
	-level 0%,100%,1.2 \
	-define dpx:television.time.code=10:00:02:15 \
	-auto-level \
	$PHOTO_CAPTIONED

mv $PHOTO_CAPTIONED $PHOTO
rm -rf $PHOTO_FILEMASK

echo "### DONE ###"
qlmanage -p $PHOTO >& /dev/null 
