$date = get-date
$fileNameDateString = $($date.ToString("yyyy-MM-dd-hh-mm-ss"))
$gameRoot = "D:\ShadowPlay\recordings\Battlefield 2042"

$theSourceRecordingsDirectory = "$gameRoot\temp"
$trimedVideoOuputFolder = "$gameRoot\$fileNameDateString\temp_trimmed"
$concatFile = "$gameRoot\$fileNameDateString\concatfile$($fileNameDateString).txt"
$mergedVideo = "$gameRoot\Battlefield 2042 merged $($date.ToString("yyyy-MM-dd-hh-mm-ss")).mp4"

$sourceVideos = Get-ChildItem $theSourceRecordingsDirectory -File -Filter "*.mp4"


if (!(Test-Path $theSourceRecordingsDirectory)){
    New-Item -Path $theSourceRecordingsDirectory -Type Directory
}

if (!(Test-Path $trimedVideoOuputFolder)){
    New-Item -Path $trimedVideoOuputFolder -Type Directory
}

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

#pulls out the parts of the videos based timestamps collected previously
$trimData = $videoTrimArray
$counter = 0
foreach ($trim in $trimData) {
    $trimmedVideo = "$trimedVideoOuputFolder\Battlefield 2042 $($fileNameDateString)$((++$counter)).mp4"
    $concatLine = "file '$trimmedVideo'"
    Add-Content -Value $concatLine -Path $concatFile
    ffmpeg -ss $trim.starttrim -t $trim.duration -i $trim.sourcevideo -c copy $trimmedVideo 
}


#stitches together the trimmed videos if there is more than one trimmed video, other rename the single trimmed video
if ($trimData.Count -gt 1) {

    ffmpeg -f concat -safe 0 -i $concatFile -c copy $mergedVideo 

}
else {
    Copy-Item $trimmedVideo -Destination $mergedVideo
}


$process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$mergedVideo`"")
