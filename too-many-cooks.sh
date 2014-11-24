# pre-requirements:
# brew get imagesnap
# brew get imagemagick

if [[ ("$#" == 0) ]]; then 
    echo 'Usage: too_many_cooks.sc "caption"'
    return
fi

CAPTION="$@"

# pre-cleanup
FILEMASK=*snapshot-*.jpg
rm -rf $FILEMASK

# take photos for 2 seconds after a 1 second delay
(sleep 1; printf "\a") &
/usr/local/bin/imagesnap -t 0.1 -w 1 photo.png & sleep 4 ; kill $!
printf "\a"

#get last file taken
FILEMASK=*snapshot-*.jpg
INTRO_FILEMASK=intro/Too_Many_Cooks_Intro*.png
FILES=(${FILEMASK// // })
RENDERED_FILENAME_PREFIX=rendered
LAST_FILE=${RENDERED_FILENAME_PREFIX}_${FILES[${#FILES[@]} - 1]}

# resize files
FILECOUNT=${#FILES[@]}
THRESHOLD=$(($FILECOUNT/4))
echo THRESHOLD \/ FILECOUNT = $THRESHOLD \/ $FILECOUNT

for (( i = 0 ; i < $FILECOUNT ; i++ )) 
do
	FILE=${FILES[$i]}
	RESIZED_FILENAME=${FILE}_resized.jpg

	# resize file
	convert $FILE -resize 320x320\> -size 320x $RESIZED_FILENAME

	if [ $i -lt $THRESHOLD ] ; then
		font_caption="Palatino-BoldItalic"
		fontsize_caption=18

		convert $RESIZED_FILENAME \
			-gravity center \
			-font "$font_caption" -pointsize $fontsize_caption \
			-stroke '#000C' -strokewidth 2 -annotate +0+20 "Starring" \
			-stroke  none   -fill yellow   -annotate +0+20 "Starring" \
			-level 0%,100%,1.2 \
			-define dpx:television.time.code=10:00:02:15 \
			-auto-level \
			"${RENDERED_FILENAME_PREFIX}"_"${FILE}"

	else
		font_caption="Palatino-BoldItalic"
		fontsize_caption=28

		convert $RESIZED_FILENAME \
			-gravity south \
			-font "$font_caption" -pointsize $fontsize_caption \
			-stroke '#000C' -strokewidth 2 -annotate +0+20 "${CAPTION}" \
			-stroke  none   -fill yellow   -annotate +0+20 "${CAPTION}" \
			-level 0%,100%,1.2 \
			-define dpx:television.time.code=10:00:02:15 \
			-auto-level \
			"${RENDERED_FILENAME_PREFIX}"_"${FILE}"
	fi

	rm -rf $FILE
done

# convert file sequence to animated gif
GIF_FILENAME=Too_Many_Cooks_-$(date +%y%m%d%H%M%S).gif
# convert -delay 10 "${RENDERED_FILENAME_PREFIX}"*.jpg -delay 100 $LAST_FILE -delay 10 $GIF_FILENAME
convert -delay 12 $INTRO_FILEMASK "${RENDERED_FILENAME_PREFIX}"*.jpg -delay 120 $LAST_FILE -ordered-dither o8x8,8,8,4 -layers OptimizeTransparency $GIF_FILENAME

# quicklook gif
qlmanage -p $GIF_FILENAME >& /dev/null

# copy path to gif
echo `pwd`/$GIF_FILENAME | pbcopy

# post-cleanup
rm -rf $FILEMASK
