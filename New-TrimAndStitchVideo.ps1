$date = get-date
$fileNameDateString = $($date.ToString("yyyy-MM-dd-hh-mm-ss"))
$gameRoot = "D:\ShadowPlay\recordings\Battlefield 2042"

$theSourceRecordingsDirectory = "$gameRoot\temp"
$trimedVideoOuputFolder = "$gameRoot\$fileNameDateString\temp_trimmed"
$concatFile = "$gameRoot\$fileNameDateString\concatfile$($fileNameDateString).txt"
$mergedVideo = "$gameRoot\Battlefield 2042 merged $($date.ToString("yyyy-MM-dd-hh-mm-ss")).mp4"

$sourceVideos = Get-ChildItem $theSourceRecordingsDirectory -File -Filter "*.mp4"
#$stichFile = "$gameRoot\$fileNameDateString\temp_trimmed\timestamps$($fileNameDateString).csv"
#$csvHeaders = "sourcevideo,starttrim,endtrim,duration"

if (!(Test-Path $theSourceRecordingsDirectory)){
    New-Item -Path $theSourceRecordingsDirectory -Type Directory
}

if (!(Test-Path $trimedVideoOuputFolder)){
    New-Item -Path $trimedVideoOuputFolder -Type Directory
}


#add-content -Value $csvHeaders -Path $stichFile

$videoTrimArray = @()
foreach ($sourceVideo in $sourceVideos) {

    Write-Host "$($sourceVideo.FullName) is opened in VLC. Find your start and end time stamps and type them into the console. HH:MM:SS 00:00:00" -ForegroundColor Cyan
    
    $process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$($sourceVideo.FullName)`"")    
    
    $startTrim = Read-Host -Prompt "Start trim timestamp for $($sourceVideo.Name)"
    $endTrim = Read-Host -Prompt "End trim timestamp $($sourceVideo.Name)"
    #$startTrim = "00:09:43"
    #$endTrim = "00:09:59"
    $trimDuration = New-TimeSpan -Start $startTrim -End $endTrim
    #$line = "$($sourceVideo.FullName),$startTrim,$endTrim,$($trimDuration.ToString("h':'m':'s"))"


    $row = new-object PSObject -Property @{
        sourcevideo = $($sourceVideo.FullName);
        starttrim = $startTrim;
        endtrim = $endTrim
        duration = $($trimDuration.ToString("h':'m':'s"))
        }

    $videoTrimArray += $row

    #add-content -Value $line -Path $stichFile

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

#plays the trimmed videos to show what the stiched together clip will look like
#& "C:\Program Files\VideoLAN\VLC\vlc.exe" $trimedVideoOuputFolder


#stitches together the trimmed videos if there is more than one trimmed video, other rename the single trimmed video
if ($trimData.Count -gt 1) {

    ffmpeg -f concat -safe 0 -i $concatFile -c copy $mergedVideo 

}
else {
    Copy-Item $trimmedVideo -Destination $mergedVideo
}


$process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$mergedVideo`"")



function New-VideoToTrim {
    <#[CmdletBinding()]
    param(
        [Parameter(mandatory=$true)]
        [string]$Path
    )#>

    if (Test-FileExists $Path) {

    }
    
}


function Test-FileExists {
    param (
        [Parameter(Mandatory=$true)]
        [String]$Path
    )

    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Output "File exists: $Path"
        return $true        
    } else {
        Write-Output "File does not exist: $Path"
        return $false
    }
}


function Show-TimeStampSelectionMenu {
    <#param (
        [Parameter(Mandatory = $true)]
        [string[]]$MenuList,
        
        [Parameter(Mandatory = $true)]
        [string]$MenuOptionInstruction,
        
        [Parameter(Mandatory = $true)]
        [string]$MenuOptionBlurb
    )#>

    $videoToTrim = Read-Host "Enter the full path of the video you would like to trim"

    if (Test-FileExists -Path $videoToTrim) {
        $videoTrimArray = @()

        $startTrim = Read-Host -Prompt "Start trim timestamp for $($sourceVideo.Name)"
        $endTrim = Read-Host -Prompt "End trim timestamp $($sourceVideo.Name)"
    }
    else {
        Write-Host $Error[0].Exception.Message
        exit
    }

    
    function Get-ValidFilePath {
        $isValid = $false
        while (-not $isValid) {
            $filePath = $(Read-Host "Enter the full path of the video you would like to clip").Replace('"','')
            if (Test-Path $filePath ) {
                $isValid = $true
            } else {
                Write-Host "Invalid file path. Please try again."
            }
        }

        return Get-Item $filePath
    }

    function Start-VideoToTrim {
        param (
        [Parameter(Mandatory = $true)]
        [string]$Path
        )

        $process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$Path`"")

        $Script:processID = $process.Id
    }

    function Stop-VideoToTrim {
        param (
        [Parameter(Mandatory = $true)]
        [string]$Process
        )

        Stop-Process $Process
    }
     
    function Show-ClipVideoMenu {
        #$answer = $null
        $validAnswers = @("yes","y","no",'n',"exit","e")
        do {
            $Script:answer = Read-Host "Type 'yes' ('y) to clip this video or 'no' ('n') to select another source video. Type 'exit' ('e') if you have no more videos to clip"   
        } until ($answer -in $validAnswers)

        switch ($answer) {
            "yes" {$Script:finalAnswer = $answer }
            "y" {$Script:finalAnswer = "yes" }
            "no" {$Script:finalAnswer = $answer }
            "n" {$Script:finalAnswer = "no" }
            "exit" {$Script:finalAnswer = $answer }
            "e" {$Script:finalAnswer = "exit" }
        }

        #return $finalAnswer

    }

    function Select-TrimStartTime {
               
        $startTrim = Read-Host -Prompt "Start trim timestamp for $($video.Name)"

        return $startTrim
        
    }

    function Select-TrimEndTime {
               
        $endTrim = Read-Host -Prompt "End trim timestamp $($video.Name)"

        return $endTrim
        
    }
    
    

    $video = Get-ValidFilePath
    Start-VideoToTrim -Path $video
    Stop-VideoToTrim -Process $processID
    Show-ClipVideoMenu
    Select-TrimStartTime
    Select-TrimEndTime
    

    $video = Get-ValidFilePath        
    Show-ClipVideoMenu
    while ($finalAnswer -eq "yes") {
        
        Start-VideoToTrim -Path $video

        Select-TrimStartTime
        
        Select-TrimEndTime

        Show-ClipVideoMenu
        
    }

    if ($finalAnswer -eq "exit"){
        exit
    }
    else {
        $video = Get-ValidFilePath
        
    }

    }



    $menuList = @("Yes","No","Exit")

    $Menu = ""
    foreach ($Item in $MenuList) {
        $Menu += "$($Item)`n"
    }

    Write-Host $MenuOptionInstruction
    Write-Host $Menu

    do {
        $Opt = Read-Host $MenuOptionBlurb    
    } until ($Opt -ge 1 -and $Opt -le $MenuList.Count -or $Opt -eq "e")

    Write-Host "Menu item number $Opt was chosen, which selects $($MenuList[$Opt-1])"
}


$videoTrimArray = @()
foreach ($sourceVideo in $sourceVideos) {

    Write-Host "$($sourceVideo.FullName) is opened in VLC. Find your start and end time stamps and type them into the console. HH:MM:SS 00:00:00" -ForegroundColor Cyan
    
    $process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$($sourceVideo.FullName)`"")    
    
    $startTrim = Read-Host -Prompt "Start trim timestamp for $($sourceVideo.Name)"
    $endTrim = Read-Host -Prompt "End trim timestamp $($sourceVideo.Name)"
    #$startTrim = "00:09:43"
    #$endTrim = "00:09:59"
    $trimDuration = New-TimeSpan -Start $startTrim -End $endTrim
    #$line = "$($sourceVideo.FullName),$startTrim,$endTrim,$($trimDuration.ToString("h':'m':'s"))"


    $row = new-object PSObject -Property @{
        sourcevideo = $($sourceVideo.FullName);
        starttrim = $startTrim;
        endtrim = $endTrim
        duration = $($trimDuration.ToString("h':'m':'s"))
        }

    $videoTrimArray += $row

    #add-content -Value $line -Path $stichFile

    Stop-Process $process.Id

}
