# How to use: Execute each section of code together by selecting the lines of code between the Section X -- START and Section X -- END comments and pressing F8.


### Section 1 -- START ###
# This section of code will prompt you for the start and end timestamps of each video you want to trim. It will then trim the video and save it to a new folder.
# It also creates a concat file that will be used in the next section to merge the trimmed videos together and save it to the root folder. It also sets the output file for the merged video.
$date = get-date
$fileNameDateString = $($date.ToString("yyyy-MM-dd-hh-mm-ss"))
$gameRoot = "D:\ShadowPlay\recordings\Battlefield 2042"
$theSourceRecordingsDirectory = "$gameRoot\temp"
$trimedVideoOuputFolder = "$gameRoot\$fileNameDateString\temp_trimmed"
$concatFile = "$gameRoot\$fileNameDateString\concatfile$($fileNameDateString).txt"
$mergedVideo = "$gameRoot\Battlefield 2042 merged $($date.ToString("yyyy-MM-dd-hh-mm-ss")).mp4"
### Section 1 -- END ###


### Section 2 -- START ###
# This section of code will import the source videos and save them to the $sourceVideos variable.
$sourceVideos = Get-ChildItem $theSourceRecordingsDirectory -File -Filter "*.mp4"
### Section 2 -- END ###

### Section 3 -- START ###
# This section creates the folders if they don't exist.
if (!(Test-Path $theSourceRecordingsDirectory)){
    New-Item -Path $theSourceRecordingsDirectory -Type Directory
}

if (!(Test-Path $trimedVideoOuputFolder)){
    New-Item -Path $trimedVideoOuputFolder -Type Directory
}
### Section 3 -- END ###

### Section 4 -- START ###
# This section of code will prompt you for the start and end timestamps of each video you want to trim and save the data to the $videoTrimArray variable.
$videoTrimArray = @()
foreach ($sourceVideo in $sourceVideos) {

    Write-Host "$($sourceVideo.FullName) is opened in VLC. Find your start and end time stamps and type them into the console. HH:MM:SS 00:00:00" -ForegroundColor Cyan
    
    $process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$($sourceVideo.FullName)`"")    
    
    $startTrim = Read-Host -Prompt "Start trim timestamp for $($sourceVideo.Name)"
    $endTrim = Read-Host -Prompt "End trim timestamp $($sourceVideo.Name)"
    $trimDuration = New-TimeSpan -Start $startTrim -End $endTrim


    $row = new-object PSObject -Property @{
        sourcevideo = $($sourceVideo.FullName);
        starttrim = $startTrim;
        endtrim = $endTrim
        duration = $($trimDuration.ToString("h':'m':'s"))
        }

    $videoTrimArray += $row

    Stop-Process $process.Id

}
### Section 4 -- END ###

### Section 5 -- START ###
# This section of code will trim the videos and save them to the $trimedVideoOuputFolder. It will also create the concat file and merge the trimmed videos together and save it to the root folder. It also opens the merged video in VLC.
$trimData = $videoTrimArray
$counter = 0
foreach ($trim in $trimData) {
    $trimmedVideo = "$trimedVideoOuputFolder\Battlefield 2042 $($fileNameDateString)$((++$counter)).mp4"
    $concatLine = "file '$trimmedVideo'"
    Add-Content -Value $concatLine -Path $concatFile
    ffmpeg -ss $trim.starttrim -t $trim.duration -i $trim.sourcevideo -c copy $trimmedVideo 
}



    if ($trimData.Count -gt 1) {

        ffmpeg -f concat -safe 0 -i $concatFile -c copy $mergedVideo 

    }
    else {
        Copy-Item $trimmedVideo -Destination $mergedVideo
    }


$process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$mergedVideo`"")
### Section 5 -- END ###
