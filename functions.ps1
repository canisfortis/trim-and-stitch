function Set-FileDetailArray {
    param (
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.ListView]$listView
    )
    <#
        .SYNOPSIS
        Recreates the file details array from the ListView items.

        .DESCRIPTION
        This function iterates over each item in the provided ListView and constructs an array of custom objects containing file details.

        .PARAMETER listView
        The ListView control containing video file details.

        .OUTPUTS
        An array of custom objects with file details.
        #>

    # Initialize an empty array
    $details = @()

    try {
        $details = foreach ($item in $listView.Items) {
            [pscustomobject]@{
                "FullName"  = $item.SubItems[0].Text
                "StartTime" = $item.SubItems[1].Text
                "StopTime"  = $item.SubItems[2].Text
                "Duration"  = $item.SubItems[3].Text
                "TempFile"  = $item.SubItems[4].Text
            }
        }
    } catch {
        Write-Error "Error processing ListView items: $_"
    }

    return $details
}
function Get-TotalDuration {
    param (
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.ListView]$listView
    )

    <#
    .SYNOPSIS
    Calculates the total duration of all video segments in the ListView.

    .DESCRIPTION
    This function computes the total duration of all video segments listed in the ListView by summing up their individual durations.

    .OUTPUTS
    TimeSpan object representing the total duration.
    #>

    $fileDetailsArray = Set-FileDetailArray -listView $listView

    # Initialize TimeSpan for total duration
    $totalDuration = [TimeSpan]::new(0)

    foreach ($fileDetail in $fileDetailsArray) {
        $totalDuration += [TimeSpan]::Parse($fileDetail.Duration)
    }

    return $totalDuration
}
function Start-Video {
    param (
        [Parameter(Mandatory = $false)]
        [string]$videoPath,

        [Parameter(Mandatory = $false)]
        [switch]$isTrimmed
    )

    <#
    .SYNOPSIS
    Plays a video file using the default media player.

    .DESCRIPTION
    This function attempts to play a specified video file. It can handle both source videos and trimmed video segments, depending on the input.

    .PARAMETER videoPath
    The file path of the video to be played.

    .EXAMPLE
    Start-Video -videoPath "C:\Videos\source.mp4"
    Starts playing the source video located at "C:\Videos\source.mp4".
    #>

    if ($isTrimmed.IsPresent) {
        # Video playback logic
        if ($listView.SelectedItems.Count -gt 0) {
            $selectedItem = $listView.SelectedItems[0]
            $fileDetails = @{
                "FullName" = $selectedItem.SubItems[0].Text
                "StartTime" = $selectedItem.SubItems[1].Text
                "StopTime" = $selectedItem.SubItems[2].Text
                "Duration" = $selectedItem.SubItems[3].Text
                "TempFile" = $selectedItem.SubItems[4].Text
            }
            # Launch the selected file with default media player
            try {
                Start-Process -FilePath "$($fileDetails.TempFile)"
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Trimmed video segment could not be played.")
            }
        }
    } else {
        if (Test-Path $videoPath) {
            try {
                Start-Process -FilePath $videoPath
            }
            catch {
                $errorMessage = if ($isTrimmed) { "Trimmed video segment could not be played." } else { "Source video could not be played." }
                [System.Windows.Forms.MessageBox]::Show($errorMessage + "`n" + $_.Exception.Message)
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Video file not found: $videoPath", "File Not Found")
        }
    }

    
}
function Remove-SelectedTrim {
    <#
    .SYNOPSIS
    Removes the selected trim from the ListView.

    .DESCRIPTION
    This function removes the selected item from the provided ListView and updates the user interface accordingly. It disables certain buttons if no items remain in the list.

    .PARAMETER listView
    The ListView control from which the selected item is to be removed.
    #>
    
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.ListView]$listView
    )


    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        
        # Remove the selected item from the ListView
        $listView.Items.Remove($selectedItem)
        
        # Update the file details array
        $script:fileDetailsArray = Set-FileDetailArray -listView $listView

        # Update the total duration display
        $trimAndStitchDetailsTable.Text = "Total duration of stitched video: $(Get-TotalDuration -listView $listView)"

        # Disable buttons if no items are left in the ListView
        $areButtonsEnabled = $listView.Items.Count -gt 0
        $deleteButton.Enabled = $areButtonsEnabled
        $playSelectedTrim.Enabled = $areButtonsEnabled
        $clearAllButton.Enabled = $areButtonsEnabled
        $exportIndividualTrimButton.Enabled = $areButtonsEnabled
        $trimAndStitchButton.Enabled = $areButtonsEnabled
        $moveUpButton.Enabled = $areButtonsEnabled
        $moveDownButton.Enabled = $areButtonsEnabled
        $editTrim.Enabled = $areButtonsEnabled
    }
}
function Move-TrimVideoItemDown {
    <#
        .SYNOPSIS
        Moves the selected trim item down in the ListView.

        .DESCRIPTION
        This function moves the currently selected item in the ListView one position down, unless it is already at the bottom of the list.

        .PARAMETER listView
        The ListView control containing the trim items.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.ListView]$listView
    )

    if ($listView.SelectedItems.Count -gt 0) {
        $selectedIndex = $listView.SelectedIndices[0]

        # Check if the selected item is not already at the bottom
        if ($selectedIndex -lt ($listView.Items.Count - 1)) {
            # Swap the selected item with the item below it
            $selectedItem = $listView.Items[$selectedIndex]
            $listView.Items.RemoveAt($selectedIndex)
            $listView.Items.Insert($selectedIndex + 1, $selectedItem)
            $listView.Items[$selectedIndex + 1].Selected = $true
            $listView.EnsureVisible($selectedIndex + 1)
        }
    }
}
function Move-TrimVideoItemDown {
    <#
    .SYNOPSIS
    Moves the selected trim item down in the ListView.

    .DESCRIPTION
    This function moves the currently selected item in the ListView one position down, unless it is already at the bottom of the list.

    .PARAMETER listView
    The ListView control containing the trim items.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.ListView]$listView
    )

    if ($listView.SelectedItems.Count -gt 0) {
        $selectedIndex = $listView.SelectedIndices[0]

        # Check if the selected item is not already at the bottom
        if ($selectedIndex -lt ($listView.Items.Count - 1)) {
            # Swap the selected item with the item below it
            $selectedItem = $listView.Items[$selectedIndex]
            $listView.Items.RemoveAt($selectedIndex)
            $listView.Items.Insert($selectedIndex + 1, $selectedItem)
            $listView.Items[$selectedIndex + 1].Selected = $true
            $listView.EnsureVisible($selectedIndex + 1)
        }
    }
}

#function to move the selected item up in the listview
function Move-TrimVideoItemUp {
    <#
    .SYNOPSIS
    Moves the selected trim item up in the ListView.

    .DESCRIPTION
    This function moves the currently selected item in the ListView one position up, unless it is already at the top of the list.

    .PARAMETER listView
    The ListView control containing the trim items.
    #>

    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.ListView]$listView
    )

    if ($listView.SelectedItems.Count -gt 0) {
        $selectedIndex = $listView.SelectedIndices[0]

        # Check if the selected item is not already at the top
        if ($selectedIndex -gt 0) {
            # Swap the selected item with the item above it
            $selectedItem = $listView.Items[$selectedIndex]
            $listView.Items.RemoveAt($selectedIndex)
            $listView.Items.Insert($selectedIndex - 1, $selectedItem)
            $listView.Items[$selectedIndex - 1].Selected = $true
            $listView.EnsureVisible($selectedIndex - 1)
        }
    }
}
#function to edit the timestamps of an item in the listview. The selected item is passed to the function as a parameter after which the start and stop times in the list view become editable
function Edit-TrimVideoItem {
    param (
        [System.Windows.Forms.ListView]$listView
    )

    # Edit item logic
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        $fileDetails = @{
            "FullName" = $selectedItem.SubItems[0].Text
            "StartTime" = $selectedItem.SubItems[1].Text
            "StopTime" = $selectedItem.SubItems[2].Text
            "Duration" = $selectedItem.SubItems[3].Text
            "TempFile" = $selectedItem.SubItems[4].Text
        }
        # Update the selected video with the new time stamps

        # update the listview item with the new timestamps
        $selectedItem.SubItems[1].Text = $startTimeHoursNumericUpDown.Value.ToString("00") + ":" + $startTimeMinutesNumericUpDown.Value.ToString("00") + ":" + $startTimeSecondsNumericUpDown.Value.ToString("00")
        $selectedItem.SubItems[2].Text = $stopTimeHoursNumericUpDown.Value.ToString("00") + ":" + $stopTimeMinutesNumericUpDown.Value.ToString("00") + ":" + $stopTimeSecondsNumericUpDown.Value.ToString("00")
        #Trim duration by minusing start time from stop time
        $selectedItem.SubItems[3].Text = [TimeSpan]::Parse($selectedItem.SubItems[2].Text) - [TimeSpan]::Parse($selectedItem.SubItems[1].Text)  
        
        #remove the old trimmed video and create a new one with the new timestamps
        Remove-Item $fileDetails.TempFile
        $trimmedVideo = "$env:TEMP\tempvideo_$(Get-Date -format 'yyyyMMddHHmmss').mp4"
        $fileDetails.TempFile = $trimmedVideo
        ffmpeg -ss $fileDetails.StartTime -t $fileDetails.Duration -i $fileDetails.FullName -c copy $trimmedVideo -loglevel quiet        
        $selectedItem.SubItems[4].Text = $trimmedVideo

        # Update the file details array
        $script:fileDetailsArray = Set-FileDetailArray -listView $listView
        
        # Update the total duration display
        $trimAndStitchDetailsTable.Text = "Total duration of stitched video: $(Get-TotalDuration -listView $listView)"
        
    }
}
# Function to validate numeric input and range
function ValidateTimeInput([Windows.Forms.TextBox]$textBox, [int]$maxValue) {
    # Remove non-numeric characters
    $textBox.Text = $textBox.Text -replace '[^0-9]', ''

    # Check if the value is greater than the maximum allowed, and if so, set it to the maximum
    if ([int]::TryParse($textBox.Text, [ref]$null) -and [int]$textBox.Text -gt $maxValue) {
        $textBox.Text = $maxValue.ToString()
    }
}

# Function to concatenate the time parts
function GetStartTime {
    return "$($startTimeHoursTextBox.Text):$($startTimeMinutesTextBox.Text):$($startTimeSecondsTextBox.Text)"
}

#Process the videos in the list into a single merged video file.
function ProcessTrimAndStitch {
    param (
        [System.Windows.Forms.ListView]$listView
    )

    $saveFileDialog = New-Object Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "MP4 Files (*.mp4)|*.mp4"
    $saveFileDialog.FileName = "MergedVideo_" + (Get-Date -format 'yyyyMMddHHmmss') + ".mp4"

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $mergedVideo = $saveFileDialog.FileName
        $concatFile = "$env:TEMP\concat$(Get-Date -format 'yyyyMMddHHmmSS').txt"

        $trimData = foreach ($item in $listView.Items) {
            [ordered]@{
                "File" = $item.SubItems[0].Text
                "Start Time" = $item.SubItems[1].Text
                "Stop Time" = $item.SubItems[2].Text
                "Duration" = $item.SubItems[3].Text
            }
        }
        
        $count = 1
        foreach ($trim in $trimData) {
            $trimmedVideo = "$env:TEMP\tempvideo$(Get-Date -format 'yyyyMMddHHmmss')_$count.mp4"
            $concatLine = "file '$trimmedVideo'"
            $trimDuration = [TimeSpan]::Parse($trim."Stop Time") - [TimeSpan]::Parse($trim."Start Time")
            Add-Content -Value $concatLine -Path $concatFile
            ffmpeg -ss $trim."Start Time" -t $trimDuration -i $trim.File -c copy $trimmedVideo -loglevel quiet
            $count++
        }

        if ($trimData.Count -gt 1) {
            ffmpeg -f concat -safe 0 -i $concatFile -c copy $mergedVideo -loglevel quiet
        } else {
            Copy-Item $trimmedVideo -Destination $mergedVideo
        }

        $result = [System.Windows.Forms.MessageBox]::Show("Trimming and stitching completed. Do you want to play the merged video now?", "Message", [System.Windows.Forms.MessageBoxButtons]::YesNo)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-Video $mergedVideo
        }

        Remove-Item $env:TEMP\tempvideo*.mp4
        Remove-Item $concatFile
    }
}

function CalculateTimeSpans {
    param (
        [Parameter(Mandatory = $true)]
        [System.Windows.Forms.NumericUpDown]$startTimeHoursControl,
        [System.Windows.Forms.NumericUpDown]$startTimeMinutesControl,
        [System.Windows.Forms.NumericUpDown]$startTimeSecondsControl,
        [System.Windows.Forms.NumericUpDown]$stopTimeHoursControl,
        [System.Windows.Forms.NumericUpDown]$stopTimeMinutesControl,
        [System.Windows.Forms.NumericUpDown]$stopTimeSecondsControl
    )

    $start = FormatTime -hours $startTimeHoursControl -minutes $startTimeMinutesControl -seconds $startTimeSecondsControl
    $stop = FormatTime -hours $stopTimeHoursControl -minutes $stopTimeMinutesControl -seconds $stopTimeSecondsControl

    
    $startTimeSpan = [TimeSpan]::Parse($start)
    $stopTimeSpan = [TimeSpan]::Parse($stop)
    $duration = [TimeSpan]::Parse($stop) - [TimeSpan]::Parse($start)

    return @{ 
        "StartTimeSpan" = $startTimeSpan;
        "StopTimeSpan" = $stopTimeSpan;
        "DurationTimeSpan" = $duration
    }
}

function AddVideoFileToList {
    param (
        [string]$filePath,
        [System.Windows.Forms.ListView]$listView,
        [System.Windows.Forms.Label]$trimAndStitchDetailsTable,
        [ref]$fileDetailsArray
    )

    $timeSpansSplat = @{
        startTimeHoursControl = $startTimeHoursNumericUpDown
        startTimeMinutesControl = $startTimeMinutesNumericUpDown
        startTimeSecondsControl = $startTimeSecondsNumericUpDown
        stopTimeHoursControl = $stopTimeHoursNumericUpDown
        stopTimeMinutesControl = $stopTimeMinutesNumericUpDown
        stopTimeSecondsControl = $stopTimeSecondsNumericUpDown
    }

    $timeSpans = CalculateTimeSpans @timeSpansSplat

    $durationTimeSpan = $timeSpans["DurationTimeSpan"]
    $startTimeSpan = $timeSpans["StartTimeSpan"]
    $stopTimeSpan = $timeSpans["StopTimeSpan"]
    $sourceVideoDuration = [TimeSpan]::Parse((Get-VideoDuration -filePath $filePath))

    if ($startTimeSpan -le $stopTimeSpan -and $stopTimeSpan -le $sourceVideoDuration) {
        # Logic to add file details to ListView and update UI
        $fileDetails = @{
            "FullName" = $filePath
            "StartTime" = $startTimeSpan
            "StopTime" = $stopTimeSpan
            "Duration" = $durationTimeSpan
            "TempFile" = ""
        }
        
        $trimmedVideo = "$env:TEMP\tempvideo_$(Get-Date -format 'yyyyMMddHHmmss').mp4"
        $fileDetails.TempFile = $trimmedVideo
        ffmpeg -ss $fileDetails.StartTime -t $fileDetails.Duration -i $fileDetails.FullName -c copy $trimmedVideo -loglevel quiet
        
        $fileDetailsArray.Value += $fileDetails

        # Add the file details to the ListView
        $item = New-Object Windows.Forms.ListViewItem($fileDetails["FullName"])
        $item.SubItems.Add($startTimeSpan.ToString())
        $item.SubItems.Add($stopTimeSpan.ToString())
        $item.SubItems.Add($fileDetails["Duration"].ToString())
        $item.SubItems.Add($fileDetails["TempFile"])
        $listView.Items.Add($item)

        # Update UI elements
        $trimAndStitchDetailsTable.Text = "Total duration of stitched video: $(Get-TotalDuration -listView $listView)"
        $addFileButton.Enabled = $true
        $trimAndStitchButton.Enabled = $true  # Enable the Trim and Stitch button
        $clearAllButton.Enabled = $true
        $exportIndividualTrimButton.Enabled = $true
        $exportIndividualTrimGifButton.Enabled = $true
    } else {
        [System.Windows.Forms.MessageBox]::Show("Invalid start or stop time. Please adjust the times.`nStart:$($startTimeSpan.gettype())`nStop:$stopTimeSpan`nDuration:$durationTimeSpan")
    }
}

#function to get the timestamps in hh:mm:ss format from the individual h m s textboxes
function FormatTime([System.Windows.Forms.NumericUpDown]$hours, [System.Windows.Forms.NumericUpDown]$minutes, [System.Windows.Forms.NumericUpDown]$seconds) {
    $formattedHours = $hours.Value.ToString("00")
    $formattedMinutes = $minutes.Value.ToString("00")
    $formattedSeconds = $seconds.Value.ToString("00")

    return "$formattedHours`:$formattedMinutes`:$formattedSeconds"
}

#function to preview video before adding or updating to list
function PreviewTrimmedVideo {
    param (
        [string]$filePath
    )

    $timeSpansSplat = @{
        startTimeHoursControl = $startTimeHoursNumericUpDown
        startTimeMinutesControl = $startTimeMinutesNumericUpDown
        startTimeSecondsControl = $startTimeSecondsNumericUpDown
        stopTimeHoursControl = $stopTimeHoursNumericUpDown
        stopTimeMinutesControl = $stopTimeMinutesNumericUpDown
        stopTimeSecondsControl = $stopTimeSecondsNumericUpDown
    }

    $timeSpans = CalculateTimeSpans @timeSpansSplat
    $previewStartTime = $timeSpans["StartTimeSpan"]
    $previewStopTime = $timeSpans["StopTimeSpan"]
    $previewDuration = $timeSpans["DurationTimeSpan"]
    $sourceVideoDuration = [TimeSpan]::Parse((Get-VideoDuration -filePath $filePath))

    if ($previewStartTime -le $previewStopTime -and $previewStopTime -lt $sourceVideoDuration) {
        $trimmedVideo = "$env:TEMP\tempvideo_$(Get-Date -format 'yyyyMMddHHmmss').mp4"
        #throw popup with trimmed video path
        #[System.Windows.Forms.MessageBox]::Show($trimmedVideo)
        ffmpeg -ss $previewStartTime -t $previewDuration -i $filePath -c copy -reset_timestamps 1 -map 0 $trimmedVideo
        Start-Process -FilePath "$trimmedVideo"
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("Invalid start or stop time. Please adjust the times.`nStart:$previewStartTime`nStop:$previewStopTime")
    }
}

# Function to get the duration of the MP4 file
function Get-VideoDuration {
    param (
        [string]$filePath
    )

    $shell = New-Object -ComObject Shell.Application
    $folder = $shell.Namespace((Get-Item $filePath).DirectoryName)
    $file = $folder.ParseName((Get-Item $filePath).Name)
    return $folder.GetDetailsOf($file, 27)
}

