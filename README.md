# trim-and-stitch
Uses ffmpeg and vlc to help choose a timestamp to cut from your shadowplay records. It them stitches them altogether and saves the merged video file. There is very little/no encoding involved so its fast.

Must have ffmpeg and VLC installed and exe path in environment variable $env:PATH

1. Save the powershell as a ps1 file
2. Run the powershell file
3. Add the 1st source video to by clicking 'Add MP4 file'
4. Enter the start and stop time stamps for the part you wish to trim (Click 'Play Source Video' to open the source video in VLC)
5. Click 'Add to Array'
6. Repeat as many times as neccessary until you're finished with that particular source video.
7. Add a new source video and repeat timestamp selections on the new video
8. When finished, Click 'Trim and Stich'. The source videos will be cut up and stiched together. Note: You can use the up and down buttons to change the order the videos are stitched together.
