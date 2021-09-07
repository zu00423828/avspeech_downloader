count=0
old_id=`cat avspeech/finish_id.txt|tail -n 1`
# ' '
#cut -d, -f 1 chinese_title_new2.csv |tail -n 1
check_root=avspeech/finish_id.txt #test/finish_id
temp_root=avspeech
video_root=avspeech/video2
baseurl='https://www.youtube.com/watch?v='
[ -f $check_root ]&& echo "Found"||>$check_root
while IFS=',' read -r id start  end x y
do
    starttime=$(printf "%02d:%02d:%02.6f" `echo $start/3600 | bc` `echo $start%3600/60 | bc` `echo $start%60 | bc`)
    duration=`echo "$end - $start"| bc`
    durationtime=$(printf "%02d:%02d:%02.6f" `echo $duration/3600 | bc` `echo $duration%3600/60 | bc` `echo $duration%60 | bc`)
    #09.6f #02.2f
    endtime=$(printf "%02d:%02d:%02.6f" `echo $end/3600 | bc` `echo $end%3600/60 | bc` `echo $end%60 | bc`)
    #if [ -f $check_root/$id ];then #finish
    if grep -q -e $id $check_root;then #finish
        echo by pass
        continue
    elif [ "$id" != "$old_id" ];then #dowload video
        echo $old_id>> $check_root
        rm $temp_root/$old_id.mp4
        count=`echo 0`
        old_id=`echo $id`
        youtube-dl --rm-cache-dir
        # youtube-dl  --cookies cookie.txt -o "$temp_root/$id.mp4" -f 'bestvideo[height=1080,ext=mp4]+140' --merge-output-format mp4 $baseurl$id
        youtube-dl  --cookies cookie.txt -o "$temp_root/$id.mp4" -f 137+140/299+140 --merge-output-format mp4 $baseurl$id 
        #youtube-dl -o "$temp_root/$id.mp4" -f 137+140 $baseurl$id
        ffmpeg  -nostdin -i   "$temp_root/$id.mp4" -crf 0 -vcodec h264 -preset veryslow -ss $starttime  -t $durationtime -filter:v fps=30 $video_root/$id-$count.mp4 
    else #spilt video
        count=`expr $count + 1`
        ffmpeg -nostdin -i "$temp_root/$id.mp4" -crf 0  -vcodec h264 -preset veryslow -ss $starttime  -t $durationtime -filter:v fps=30 $video_root/$id-$count.mp4 
    fi
done < $1


