#download video
#youtube-dl https://www.youtube.com/watch?v=QrGrOK8oZG8

FILEMASK=intro/Too_Many_Cooks_Intro*.png

#cleanup files
rm -rf $FILEMASK

#extract frames
ffmpeg -ss 4.6 -t 2 -i "Too Many Cooks _ Adult Swim-QrGrOK8oZG8.mp4"  -vf fps=fps=5 "intro/Too_Many_Cooks_Intro%002d.png"

#resize frames
for f in $FILEMASK
do
	RESIZED_FILENAME=${f}_resized.png
	#resize file
	convert $f -resize 320x320\> -size 320x $RESIZED_FILENAME
	#delete original
	rm -rf $f
done
