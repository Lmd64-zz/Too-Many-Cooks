# pre-cleanup
FILEMASK=*snapshot-*.jpg
rm -rf $FILEMASK

#parse through arguments
args=$@
CAPTIONS=( "$@" )
CAPTIONCOUNT=${#CAPTIONS[@]}

for index in "${!CAPTIONS[@]}"; do
	#get caption
	CAPTION=${CAPTIONS[$index]}
	#strip spaces
	CAPTION_NOSPACES=${CAPTION// /.}

    echo "Get $CAPTION to sit in front of the camera."
    echo "Ready? Look away. Look towards the camera at the first beep,"
    echo "hold that pose until the second beep."
	read -p "Press any key when ready:" -n1 -s
	echo

	#take photos
	/usr/local/bin/imagesnap -q -t 0.1 -w 1.0 photo.png & sleep 3.5 ; kill $!

#beep after 2 second
(sleep 2; printf "\a") &
#beep after 3.5 seconds
(sleep 3.5; printf "\a") &

	#reset filemask to just the last batch of imagesnaps
	FILEMASK=snapshot-*.jpg

	#rename photos
	for FILE in $FILEMASK;  do 
		RENAMEDFILE=$(printf %04d_%s_%s.jpg ${index} ${CAPTION_NOSPACES} ${FILE%.jpg})
		mv $FILE $RENAMEDFILE
	done

done

for index in "${!CAPTIONS[@]}"; do

	#get current caption
	CAPTION=${CAPTIONS[$index]}
	#strip spaces form current caption
	CAPTION_NOSPACES=${CAPTION// /.}

	#filemask for current caption
	FILEMASK=$(printf %04d_%s_*.jpg ${index} ${CAPTION_NOSPACES})

	#step through all files for current caption
	FILES=(${FILEMASK// // })

	TITLE="Starring"
	if [ $index -ne 0 ] ; then
		TITLE="Also starring"
	fi

	FILECOUNT=${#FILES[@]}
	THRESHOLD=$(($FILECOUNT/4))

	for fileIndex in "${!FILES[@]}"; do

		FILE=${FILES[$fileIndex]}

		# resize file
		RESIZED_FILE=$(printf %s_resized.jpg ${FILE%.jpg})
		convert $FILE -resize 320x320\> -size 320x $RESIZED_FILE

		CAPTIONED_FILE=$(printf %s_captioned.jpg ${FILE%_resized.jpg})
		rm -rf $FILE

		if [ $fileIndex -lt $THRESHOLD ] ; then
			font_caption="Palatino-BoldItalic"
			fontsize_caption=18

			convert $RESIZED_FILE \
				-gravity center \
				-font "$font_caption" -pointsize $fontsize_caption \
				-stroke '#000C' -strokewidth 2 -annotate +0+20 "${TITLE}" \
				-stroke  none   -fill yellow   -annotate +0+20 "${TITLE}" \
				-level 0%,100%,1.2 \
				-define dpx:television.time.code=10:00:02:15 \
				-auto-level \
				$CAPTIONED_FILE

		else
			font_caption="Palatino-BoldItalic"
			fontsize_caption=28

			convert $RESIZED_FILE \
				-gravity south \
				-font "$font_caption" -pointsize $fontsize_caption \
				-stroke '#000C' -strokewidth 2 -annotate +0+20 "${CAPTION}" \
				-stroke  none   -fill yellow   -annotate +0+20 "${CAPTION}" \
				-level 0%,100%,1.2 \
				-define dpx:television.time.code=10:00:02:15 \
				-auto-level \
				$CAPTIONED_FILE
		fi

		rm -rf $RESIZED_FILE

	done

done

INTRO_FILEMASK=Too_Many_Cooks_Intro*.png
INTRO_FILEMASK=intro/Too_Many_Cooks_Intro*.png
CAPTIONED_FILEMASK=*_captioned.jpg

# convert file sequence to animated gif
GIF_FILENAME=Too_Many_Cooks_-$(date +%y%m%d%H%M%S).gif

convert -delay 12 $INTRO_FILEMASK $CAPTIONED_FILEMASK -ordered-dither o8x8,8,8,4 -layers OptimizeTransparency $GIF_FILENAME

rm -rf *jpg
