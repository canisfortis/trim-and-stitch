Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System

#region
#functions

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
        [Parameter(Mandatory = $true)]
        [string]$videoPath
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

        # Remove the existing video from the list
        $listView.Items.Remove($selectedItem)

        # Add the updated video to the list
        AddVideoFileToList -filePath $filePath -listView $listView -trimAndStitchDetailsTable $trimAndStitchDetailsTable -fileDetailsArray ([ref]$fileDetailsArray)

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

# Add event handlers for each text box
$startTimeHoursTextBox.Add_TextChanged({
    ValidateTimeInput $startTimeHoursTextBox 23
})
$startTimeMinutesTextBox.Add_TextChanged({
    ValidateTimeInput $startTimeMinutesTextBox 59
})
$startTimeSecondsTextBox.Add_TextChanged({
    ValidateTimeInput $startTimeSecondsTextBox 59
})



# Function to concatenate the time parts
function GetStartTime {
    return "$($startTimeHoursTextBox.Text):$($startTimeMinutesTextBox.Text):$($startTimeSecondsTextBox.Text)"
}
#endregion

#region


$DurationLocation = @{X=20;Y=60}
$AddedFileLocation = @{X=20;Y=90}
$PlayButtonLocation = @{X=20;Y=120}
$ListViewLocation = @{X=20;Y=280}
$AddFileButtonLocation = @{X=20;Y=250}
$playSelectedTrimLocation = @{X=$AddFileButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$EditTrimButtonLocation = @{X=$playSelectedTrimLocation.X+130;Y=$AddFileButtonLocation.Y}
$DeleteButtonLocation = @{X=$EditTrimButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$MoveUpButtonLocation = @{X=$DeleteButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$MoveDownButtonLocation = @{X=$MoveUpButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$clearAllButtonLocation = @{X=$MoveDownButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$TrimAndStitchButtonLocation = @{X=20;Y=510}
$exitButtonLocation = @{X=20;Y=600}
$exportIndividualTrimsButtonLocation = @{X=20;Y=570}
$exportIndividualTrimsGifButtonLocation = @{X=$exportIndividualTrimsButtonLocation.X+170;Y=$exportIndividualTrimsButtonLocation.Y}

# Create a form
$form = New-Object Windows.Forms.Form
$form.Text = "MP4 Stitch and Trim Tool"
$form.Width = 1000
$form.Height = 700
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

# Initialize an array to store file details
$fileDetailsArray = @()

# Create a button to add an MP4 file
$addMp4Button = New-Object Windows.Forms.Button
$addMp4Button.Text = "Add MP4 file"
$addMp4Button.Location = New-Object Drawing.Point(20, 20)
$addMp4Button.Width = 100

# Create a label for start time
$startTimeLabel = New-Object Windows.Forms.Label
$startTimeLabel.Text = "Start time:"
$startTimeLabel.Location = New-Object Drawing.Point(20, 180)
$startTimelabel.Width = 150

# Create a label for H text box
$hourTextBoxLabel = New-Object Windows.Forms.Label
$hourTextBoxLabel.Text = "H"
$hourTextBoxLabel.Location = New-Object Drawing.Point(165, 165)
$hourTextBoxLabel.Width = 10
$hourTextBoxLabel.Height = 10

# Create a label for M text box
$minuteTextBoxLabel = New-Object Windows.Forms.Label
$minuteTextBoxLabel.Text = "M"
$minuteTextBoxLabel.Location = New-Object Drawing.Point(220, 165)
$minuteTextBoxLabel.Width = 10
$minuteTextBoxLabel.Height = 10

# Create a label for S text box
$secondTextBoxLabel = New-Object Windows.Forms.Label
$secondTextBoxLabel.Text = "S"
$secondTextBoxLabel.Location = New-Object Drawing.Point(275, 165)
$secondTextBoxLabel.Width = 10
$secondTextBoxLabel.Height = 10

$form.Controls.Add($hourTextBoxLabel)
$form.Controls.Add($minuteTextBoxLabel)
$form.Controls.Add($secondTextBoxLabel)
# Create NumericUpDown controls for start time hours, minutes, and seconds
$startTimeHoursNumericUpDown = New-Object System.Windows.Forms.NumericUpDown
$startTimeHoursNumericUpDown.Location = New-Object Drawing.Point(150, 180)
$startTimeHoursNumericUpDown.Size = New-Object Drawing.Size(50, 20)
$startTimeHoursNumericUpDown.Minimum = 0

$startTimeMinutesNumericUpDown = New-Object System.Windows.Forms.NumericUpDown
$startTimeMinutesNumericUpDown.Location = New-Object Drawing.Point(205, 180)
$startTimeMinutesNumericUpDown.Size = New-Object Drawing.Size(50, 20)
$startTimeMinutesNumericUpDown.Maximum = 59
$startTimeMinutesNumericUpDown.Minimum = 0

$startTimeSecondsNumericUpDown = New-Object System.Windows.Forms.NumericUpDown
$startTimeSecondsNumericUpDown.Location = New-Object Drawing.Point(260, 180)
$startTimeSecondsNumericUpDown.Size = New-Object Drawing.Size(50, 20)
$startTimeSecondsNumericUpDown.Maximum = 59
$startTimeSecondsNumericUpDown.Minimum = 0

# Add the NumericUpDown controls to the form (assuming $form is your form object)
$form.Controls.Add($startTimeHoursNumericUpDown)
$form.Controls.Add($startTimeMinutesNumericUpDown)
$form.Controls.Add($startTimeSecondsNumericUpDown)


# Preview button
$previewTrimDurationVideoButton = New-Object Windows.Forms.Button
$previewTrimDurationVideoButton.Text = "Preview Trim"
$previewTrimDurationVideoButton.Location = New-Object Drawing.Point(320, 180)
$previewTrimDurationVideoButton.Width = 100
$previewTrimDurationVideoButton.Height = 50
$previewTrimDurationVideoButton.Enabled = $false



# Add the NumericUpDown controls to the form (assuming $form is your form object)
$form.Controls.Add($previewTrimDurationVideoButton)



# Create a label for stop time
$stopTimeLabel = New-Object Windows.Forms.Label
$stopTimeLabel.Text = "Stop time:"
$stopTimeLabel.Location = New-Object Drawing.Point(20, 210)
$stopTimeLabel.Width = 150


# Create NumericUpDown controls for stop time hours, minutes, and seconds
$stopTimeHoursNumericUpDown = New-Object System.Windows.Forms.NumericUpDown
$stopTimeHoursNumericUpDown.Location = New-Object Drawing.Point(150, 210)
$stopTimeHoursNumericUpDown.Size = New-Object Drawing.Size(50, 20)
$stopTimeHoursNumericUpDown.Minimum = 0

$stopTimeMinutesNumericUpDown = New-Object System.Windows.Forms.NumericUpDown
$stopTimeMinutesNumericUpDown.Location = New-Object Drawing.Point(205, 210)
$stopTimeMinutesNumericUpDown.Size = New-Object Drawing.Size(50, 20)
$stopTimeMinutesNumericUpDown.Maximum = 59
$stopTimeMinutesNumericUpDown.Minimum = 0

$stopTimeSecondsNumericUpDown = New-Object System.Windows.Forms.NumericUpDown
$stopTimeSecondsNumericUpDown.Location = New-Object Drawing.Point(260, 210)
$stopTimeSecondsNumericUpDown.Size = New-Object Drawing.Size(50, 20)
$stopTimeSecondsNumericUpDown.Maximum = 59
$stopTimeSecondsNumericUpDown.Minimum = 0

# Add the NumericUpDown controls to the form (assuming $form is your form object)
$form.Controls.Add($stopTimeHoursNumericUpDown)
$form.Controls.Add($stopTimeMinutesNumericUpDown)
$form.Controls.Add($stopTimeSecondsNumericUpDown)


# Create a text box to display the duration
$durationLabel = New-Object Windows.Forms.Label
$durationLabel.Text = "Duration: Add an MP4 file."
$durationLabel.Location = New-Object Drawing.Point($DurationLocation.X, $DurationLocation.Y)
$durationLabel.Width = 300

# Create a text box to display the duration
$addedFileLabel = New-Object Windows.Forms.Label
$addedFileLabel.Text = "No files currently added."
$addedFileLabel.Location = New-Object Drawing.Point($AddedFileLocation.X, $AddedFileLocation.Y)
$addedFileLabel.Width = 700

# Create a button to play the current trim file
$playButton = New-Object Windows.Forms.Button
$playButton.Text = "Play source file"
$playButton.Location = New-Object Drawing.Point($PlayButtonLocation.X, $PlayButtonLocation.Y)
$playButton.Width = 120
$playButton.Enabled = $false

# Create a ListView to display file details with columns
$listView = New-Object Windows.Forms.ListView
$listView.Location = New-Object Drawing.Point($ListViewLocation.X, $ListViewLocation.Y)
$listView.Width = 900
$listView.Height = 200
$listView.View = [System.Windows.Forms.View]::Details

# Add columns to the ListView
$listView.Columns.Add("File", 300)
$listView.Columns.Add("Start Time", 150)
$listView.Columns.Add("Stop Time", 150)
$listView.Columns.Add("Duration", 150)

# Create a button to add the file details to the array
$addFileButton = New-Object Windows.Forms.Button
$addFileButton.Text = "Add to trim list"
$addFileButton.Location = New-Object Drawing.Point($AddFileButtonLocation.X, $AddFileButtonLocation.Y)
$addFileButton.Width = 100
$addFileButton.Enabled = $false

# Create a button to open the selected file in the default media player
$playSelectedTrim = New-Object Windows.Forms.Button
$playSelectedTrim.Text = "Play selected file"
$playSelectedTrim.Location = New-Object Drawing.Point($playSelectedTrimLocation.X, $playSelectedTrimLocation.Y)
$playSelectedTrim.Width = 110
$playSelectedTrim.Enabled = $false

# Create a button to edit the trim details
$editTrim = New-Object Windows.Forms.Button
$editTrim.Text = "Update Trim Times"
$editTrim.Location = New-Object Drawing.Point(250, 250)
$editTrim.Width = 110
$editTrim.Enabled = $false

# Create a button to delete the selected item from the ListView
$deleteButton = New-Object Windows.Forms.Button
$deleteButton.Text = "Delete selected"
$deleteButton.Location = New-Object Drawing.Point($DeleteButtonLocation.X, $DeleteButtonLocation.Y)
$deleteButton.Width = 100
$deleteButton.Enabled = $false

# Create a button to move the selected item up
$moveUpButton = New-Object Windows.Forms.Button
$moveUpButton.Text = "Move up"
$moveUpButton.Location = New-Object Drawing.Point($MoveUpButtonLocation.X, $MoveUpButtonLocation.Y)
$moveUpButton.Width = 100
$moveUpButton.Enabled = $false

# Create a button to move the selected item down
$moveDownButton = New-Object Windows.Forms.Button
$moveDownButton.Text = "Move down"
$moveDownButton.Location = New-Object Drawing.Point($MoveDownButtonLocation.X, $MoveDownButtonLocation.Y)
$moveDownButton.Width = 100
$moveDownButton.Enabled = $false

# Create a button to exit the application
$exitButton = New-Object Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Location = New-Object Drawing.Point($exitButtonLocation.X, $exitButtonLocation.Y)
$exitButton.Width = 100

# Create a button to clear the list
$clearAllButton = New-Object Windows.Forms.Button
$clearAllButton.Text = "Clear all"
$clearAllButton.Location = New-Object Drawing.Point($clearAllButtonLocation.X, $clearAllButtonLocation.Y)
$clearAllButton.Width = 100
$clearAllButton.Enabled = $false

# Create a button to just export individual trims
$exportIndividualTrimButton = New-Object Windows.Forms.Button
$exportIndividualTrimButton.Text = "Export individual trims"
$exportIndividualTrimButton.Location = New-Object Drawing.Point($exportIndividualTrimsButtonLocation.X, $exportIndividualTrimsButtonLocation.Y)
$exportIndividualTrimButton.Width = 150
$exportIndividualTrimButton.Enabled = $false

#Create a button to export an individual trim as a gif.
$exportIndividualTrimGifButton = New-Object Windows.Forms.Button
$exportIndividualTrimGifButton.Text = "Export individual trims as gif"
$exportIndividualTrimGifButton.Location = New-Object Drawing.Point($exportIndividualTrimsGifButtonLocation.X, $exportIndividualTrimsGifButtonLocation.Y)
$exportIndividualTrimGifButton.Width = 170
$exportIndividualTrimGifButton.Enabled = $false

# Create a button to Trim and Stitch
$trimAndStitchButton = New-Object Windows.Forms.Button
$trimAndStitchButton.Text = "Trim and stitch"
$trimAndStitchButton.Location = New-Object Drawing.Point($TrimAndStitchButtonLocation.X, $TrimAndStitchButtonLocation.Y)
$trimAndStitchButton.Width = 100
$trimAndStitchButton.Enabled = $false

# New table next to trim and stich button showing the total duration of the trimmed video
$trimAndStitchDetailsTable = New-Object Windows.Forms.Label
$trimAndStitchDetailsTable.Text = "Total duration of stitched video: "
$trimAndStitchDetailsTable.Location = New-Object Drawing.Point(20, 540)
$trimAndStitchDetailsTable.Width = 300

# Test if ffmpeg is installed
try {
    $ffmpeg = ffmpeg -loglevel quiet
}
catch {
    [System.Windows.Forms.MessageBox]::Show("ffmpeg is not installed. Please install ffmpeg and try again.")
    $form.Close()
}




#endregion


#region
# Create an event handler for the Play Trimmed File button click
$playButton.Add_Click({
    #[System.Windows.Forms.MessageBox]::Show($filePath)
    Start-SourceVideo $filePath
})

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
            Start-SourceVideo $mergedVideo
        }

        Remove-Item $env:TEMP\tempvideo*.mp4
        Remove-Item $concatFile
    }
}


# Create an event handler for the Trim and Stitch button click
$trimAndStitchButton.Add_Click({
    $trimAndStitchButton.Add_Click({
        ProcessTrimAndStitch -listView $listView
    })
     
})

# Create an event handler for the Export Individual Trims button click
$exportIndividualTrimButton.Add_Click({
    $saveFileDialog = New-Object Windows.Forms.FolderBrowserDialog
    $saveFileDialog.Description = "Select a folder to save the individual trims"
    $saveFileDialog.ShowNewFolderButton = $true

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $saveFolder = $saveFileDialog.SelectedPath

        # Create an array to store items and subitems
        $trimData = @()

        # Loop through each item in the ListView
        $trimData = foreach ($item in $listView.Items) {
            # Create an ordered dictionary to store item data
            [ordered]@{
                "File" = $item.SubItems[0].Text
                "Start Time" = $item.SubItems[1].Text
                "Stop Time" = $item.SubItems[2].Text
                "Duration" = $item.SubItems[3].Text
            }
        }
        
        $count = 1
        
        foreach ($trim in $trimData) {
            $trimmedVideo = "$saveFolder\trimmed video $(Get-Date -format 'yyyyMMddHHmmss')_$count.mp4"
            $trimDuration = [TimeSpan]::Parse($trim."Stop Time") - [TimeSpan]::Parse($trim."Start Time")
            ffmpeg -ss $trim."Start Time" -t $trimDuration -i $trim.File -c copy $trimmedVideo -loglevel quiet
            $count++
        }

        
        # Display a message box with an OK button
        $result = [System.Windows.Forms.MessageBox]::Show("Trimming completed. Do you want to open the folder now?", "Message", [System.Windows.Forms.MessageBoxButtons]::YesNo)

        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            # User clicked "Yes," so open the merged video
            try {
                $process = [Diagnostics.Process]::Start("explorer.exe", "`"$saveFolder`"")
            } 
            catch {
                [System.Windows.Forms.MessageBox]::Show("Folder not found.")
            }
        }

        #clear up temp files
        Remove-Item $env:TEMP\tempvideo*.mp4
        
    }
})

# Create an event handler for the Export Individual Trims as gif button click
$exportIndividualTrimGifButton.Add_Click({
    $saveFileDialog = New-Object Windows.Forms.FolderBrowserDialog
    $saveFileDialog.Description = "Select a folder to save the individual trims"
    $saveFileDialog.ShowNewFolderButton = $true

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $saveFolder = $saveFileDialog.SelectedPath

        # Create an array to store items and subitems
        $trimData = @()

        # Loop through each item in the ListView
        $trimData = foreach ($item in $listView.Items) {
            # Create an ordered dictionary to store item data
            [ordered]@{
                "File" = $item.SubItems[0].Text
                "Start Time" = $item.SubItems[1].Text
                "Stop Time" = $item.SubItems[2].Text
                "Duration" = $item.SubItems[3].Text
            }
        }
        
        $count = 1
        
        foreach ($trim in $trimData) {
            $trimmedVideo = "$saveFolder\trimmed video $(Get-Date -format 'yyyyMMddHHmmss')_$count.gif"
            $trimDuration = [TimeSpan]::Parse($trim."Stop Time") - [TimeSpan]::Parse($trim."Start Time")
            ffmpeg -y -i $trim.file -filter_complex "fps=15,split[v1][v2]; [v1]palettegen=stats_mode=full [palette]; [v2][palette]paletteuse=dither=sierra2_4a" -vsync 0 $trimmedVideo -loglevel quiet
            $count++
        }

        
        # Display a message box with an OK button
        $result = [System.Windows.Forms.MessageBox]::Show("Trimming completed. Do you want to open the folder now?", "Message", [System.Windows.Forms.MessageBoxButtons]::YesNo)

        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            # User clicked "Yes," so open the merged video
            try {
                $process = [Diagnostics.Process]::Start("explorer.exe", "`"$saveFolder`"")
            } 
            catch {
                [System.Windows.Forms.MessageBox]::Show("Folder not found.")
            }
        }

        #clear up temp files
        Remove-Item $env:TEMP\tempvideo*.mp4
        
    }
})

# Create an event handler for the Add MP4 File button click
$addMp4Button.Add_Click({
    try {
        $openFileDialog = New-Object Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "MP4 Files (*.mp4)|*.mp4"

        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $script:filePath = $openFileDialog.FileName

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

            # Get the duration using the function
            $script:duration = Get-VideoDuration -filePath $filePath
            #[System.Windows.Forms.MessageBox]::Show("Duration: $duration")
            # Split the duration into hours, minutes, and seconds
            $durationParts = $duration -split ':'
            $hours = $durationParts[0]
            $minutes = $durationParts[1]
            $seconds = $durationParts[2]

            # Prefill start time text boxes
            # Prefill stop time text boxes
            $startTimeHoursNumericUpDown.Value = '00'
            $startTimeMinutesNumericUpDown.Value = '00'
            $startTimeSecondsNumericUpDown.Value = '00'

            # Prefill stop time text boxes
            $stopTimeHoursNumericUpDown.Value = $hours
            $stopTimeMinutesNumericUpDown.Value = $minutes  
            $stopTimeSecondsNumericUpDown.Value = $seconds  
            
            # Display the duration
            $durationLabel.Text = "Duration: $duration"

            # Display the current file
            $addedFileLabel.Text = "Current Trim File: $($filePath)"

            # Enable the start and stop time text boxes, and other buttons
            $startTimeHoursTextBox.Enabled = $true
            $startTimeMinutesTextBox.Enabled = $true
            $startTimeSecondsTextBox.Enabled = $true

            $stopTimeHoursTextBox.Enabled = $true
            $stopTimeMinutesTextBox.Enabled = $true
            $stopTimeSecondsTextBox.Enabled = $true

            $addFileButton.Enabled = $true
            $playButton.Enabled = $true
            $previewTrimDurationVideoButton.Enabled = $true
        }
    } catch {
        # Handle exceptions
        [System.Windows.Forms.MessageBox]::Show("An error occurred: " + $_.Exception.Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

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

    if ($startTimeSpan -le $stopTimeSpan -and $stopTimeSpan -le $durationTimeSpan) {
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
        [System.Windows.Forms.MessageBox]::Show("Invalid start or stop time. Please adjust the times.")
    }
}



# Create an event handler for the Add to Trim List button click
$addFileButton.Add_Click({

    # Call the function with the required parameters
    AddVideoFileToList -filePath $filePath -listView $listView -trimAndStitchDetailsTable $trimAndStitchDetailsTable -fileDetailsArray ([ref]$fileDetailsArray)

})


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

    $trimmedVideo = "$env:TEMP\tempvideo_$(Get-Date -format 'yyyyMMddHHmmss').mp4"
    #throw popup with trimmed video path
    [System.Windows.Forms.MessageBox]::Show($trimmedVideo)



    ffmpeg -ss $previewStartTime -t $previewDuration -i $filePath -c copy $trimmedVideo
    Start-Process -FilePath "$trimmedVideo"
}


#function to play the trimmed video before adding to list
$previewTrimDurationVideoButton.Add_Click({
    PreviewTrimmedVideo -filePath $filePath
})

# Create an event handler for when the edit trim button is clicked
$editTrim.Add_Click({
    Edit-TrimVideoItem $listView
})


# Create an event handler for the Play selected trim button click
$playSelectedTrim.Add_Click({
    Start-TrimmedVideo 
})

# Create an event handler for the Delete Selected button click
$deleteButton.Add_Click({
    Remove-SelectedTrim $listView
})

# Create an event handler for the ListView SelectedIndexChanged event
$listView.Add_SelectedIndexChanged({
    if ($listView.SelectedItems.Count -gt 0) {
        $deleteButton.Enabled = $true
        $playSelectedTrim.Enabled = $true
        $editTrim.Enabled = $true
        $moveUpButton.Enabled = $true
        $moveDownButton.Enabled = $true
    } else {
        $deleteButton.Enabled = $false
        $playSelectedTrim.Enabled = $false
    }
})

# Create an event handler for the Move Up button click
$moveUpButton.Add_Click({
    Move-TrimVideoItemUp $listView    
})

# Create an event handler for the Move Down button click
$moveDownButton.Add_Click({
    Move-TrimVideoItemDown $listView
})

# Create an event handler for the Exit button click
$exitButton.Add_Click({
    $form.Close()
})

# Create an event handler for the Clear All button click
$clearAllButton.Add_Click({
    # Clear the ListView and reset the file details array
    $listView.Items.Clear()
    
    # Disable buttons that require items in the list
    $deleteButton.Enabled = $false
    $playSelectedTrim.Enabled = $false
    $moveUpButton.Enabled = $false
    $moveDownButton.Enabled = $false
    $trimAndStitchButton.Enabled = $false
    $clearAllButton.Enabled = $false
    $exportIndividualTrimButton.Enabled = $false
    $trimAndStitchDetailsTable.Text = "Total duration of stitched video: "
    $exportIndividualTrimGifButton.Enabled = $false
    $editTrim.Enabled = $false   
})

#endregion

#region
# Add controls to the form
$form.Controls.Add($addMp4Button)
$form.Controls.Add($startTimeLabel)
$form.Controls.Add($stopTimeLabel)
$form.Controls.Add($durationLabel)
$form.Controls.Add($addFileButton)
$form.Controls.Add($listView)
$form.Controls.Add($playSelectedTrim)
$form.Controls.Add($deleteButton)
$form.Controls.Add($addedFileLabel)
$form.Controls.Add($editTrim)
$form.Controls.Add($moveUpButton)
$form.Controls.Add($moveDownButton)
$form.Controls.Add($trimAndStitchButton)
$form.Controls.Add($trimAndStitchDetailsTable)
$form.Controls.Add($exportIndividualTrimButton)
$form.Controls.Add($exportIndividualTrimGifButton)
$form.Controls.Add($playButton)
$form.Controls.Add($exitButton)
$form.Controls.Add($clearAllButton)
#endregion

# Show the form
$form.ShowDialog()
