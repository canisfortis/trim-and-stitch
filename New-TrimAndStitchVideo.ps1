Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System

#region
#functions
#recreate the file details array from the listview
function Set-FileDetailArray {
    $array = @()
    foreach ($item in $listView.Items) {
        $details = @{
            "FullName" = $item.SubItems[0].Text
            "StartTime" = $item.SubItems[1].Text
            "StopTime" = $item.SubItems[2].Text
            "Duration" = $item.SubItems[3].Text
            "TempFile" = $item.SubItems[4].Text
        }
        $array += $details
    }
    return $array

}

#Calculate the total duration of the trimmed video
function Get-TotalDuration {
    $fileDetailsArray = Set-FileDetailArray
    #convert the Duration into a timespan object and calculate the seconds then convert back to timespan   
    # Calculate the sum of durations in seconds
    $totalSeconds = $fileDetailsArray | ForEach-Object {
        $duration = [TimeSpan]::Parse($_.Duration)
        $duration.TotalSeconds
    } | Measure-Object -Sum | Select-Object -ExpandProperty Sum

    # Convert the total seconds back to a TimeSpan
    $totalTimeSpan = [TimeSpan]::FromSeconds($totalSeconds)
    return $totalTimeSpan
}
#endregion



#region

$StartTimeLocation = @{X=20;Y=180}
$StopTimeLocation = @{X=20;Y=210}
$DurationLocation = @{X=20;Y=60}
$AddedFileLocation = @{X=20;Y=90}
$PlayButtonLocation = @{X=20;Y=120}
$ListViewLocation = @{X=20;Y=280}
$AddFileButtonLocation = @{X=20;Y=250}
$playSelectedTrimLocation = @{X=$AddFileButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$DeleteButtonLocation = @{X=$playSelectedTrimLocation.X+130;Y=$AddFileButtonLocation.Y}
$MoveUpButtonLocation = @{X=$DeleteButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$MoveDownButtonLocation = @{X=$MoveUpButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$clearAllButtonLocation = @{X=$MoveDownButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$TrimAndStitchButtonLocation = @{X=20;Y=510}
$exitButtonLocation = @{X=20;Y=600}
$exportIndividualTrimsButtonLocation = @{X=20;Y=560}

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
$startTimeLabel.Location = New-Object Drawing.Point($($startTimeLocation.X), $($startTimeLocation.Y))

# Create a text box for start time
$startTimeTextBox = New-Object Windows.Forms.TextBox
$startTimeTextBox.Location = New-Object Drawing.Point($($startTimeLocation.X+130), $($startTimeLocation.Y))
$startTimeTextBox.Width = 80

# Create a label for stop time
$stopTimeLabel = New-Object Windows.Forms.Label
$stopTimeLabel.Text = "Stop time:"
$stopTimeLabel.Location = New-Object Drawing.Point($stopTimeLocation.X, $StopTimeLocation.Y)

# Create a text box for stop time
$stopTimeTextBox = New-Object Windows.Forms.TextBox
$stopTimeTextBox.Location = New-Object Drawing.Point(150, $StopTimeLocation.Y)
$stopTimeTextBox.Width = 80

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
$playSelectedTrim.Width = 120
$playSelectedTrim.Enabled = $false

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
# Create an event handler for the Trim and Stitch button click
$trimAndStitchButton.Add_Click({
    $saveFileDialog = New-Object Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "MP4 Files (*.mp4)|*.mp4"
    $saveFileDialog.FileName = "MergedVideo_" + (Get-Date -format 'yyyyMMddHHmmss') + ".mp4"

    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $mergedVideo = $saveFileDialog.FileName
        $concatFile = $env:TEMP + "\concat" + (Get-Date -format 'yyyyMMddHHmmSS') + ".txt"
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
            $trimmedVideo = $env:TEMP + "\tempvideo" + (Get-Date -format 'yyyyMMddHHmmss') + "_" + $count + ".mp4"
            $concatLine = "file '$trimmedVideo'"
            $trimDuration = [TimeSpan]::Parse($trim."Stop Time") - [TimeSpan]::Parse($trim."Start Time")
            Add-Content -Value $concatLine -Path $concatFile
            ffmpeg -ss $trim."Start Time" -t $trimDuration -i $trim.File -c copy $trimmedVideo -loglevel quiet
            $count++
        }

        
        if ($trimData.Count -gt 1) {
            ffmpeg -f concat -safe 0 -i $concatFile -c copy $mergedVideo -loglevel quiet
        }
        else {
            Copy-Item $trimmedVideo -Destination $mergedVideo
        }
        
        
        # Display a message box with an OK button
        $result = [System.Windows.Forms.MessageBox]::Show("Trimming and stitching completed. Do you want to play the merged video now?", "Message", [System.Windows.Forms.MessageBoxButtons]::YesNo)

        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            # User clicked "Yes," so open the merged video
            # Create an event handler for the Play Trimmed File button click
            $playButton.Add_Click({
                
                # Launch the selected file with default media player
                try {
                    #$process = [Diagnostics.Process]::Start("vlc.exe", "`"$($fileDetails.TempFile)`"")
                    Start-Process -FilePath "$($mergedVideo)"
                }
                catch {
                    [System.Windows.Forms.MessageBox]::Show("Trimmed video segment could not be played.")
                }
            })
        }

        #clear up temp files
        Remove-Item $env:TEMP\tempvideo*.mp4
        Remove-Item $concatFile
        
    }
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
            $trimmedVideo = $saveFolder + "\trimmed video " + (Get-Date -format 'yyyyMMddHHmmss') + "_" + $count + ".mp4"
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

# Create an event handler for the Add MP4 File button click
$addMp4Button.Add_Click({
    

    $openFileDialog = New-Object Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "MP4 Files (*.mp4)|*.mp4"

    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:filePath = $openFileDialog.FileName

        # Use Shell.Application to get the duration of the MP4 file
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace((Get-Item $filePath).DirectoryName)
        $script:file = $folder.ParseName((Get-Item $filePath).Name) 
        $script:duration = $folder.GetDetailsOf($file, 27)

        # Prefill start and stop text boxes
        $startTimeTextBox.Text = '00:00:00'
        $stopTimeTextBox.Text = $duration


        # Display the duration
        $durationLabel.Text = "Duration: " + $duration

        #Display the current file
        $addedFileLabel.Text = "Current Trim File: " + $file.Path

        # Enable the start and stop time text boxes
        $startTimeTextBox.Enabled = $true
        $stopTimeTextBox.Enabled = $true
        $addFileButton.Enabled = $true
        $playButton.Enabled = $true
        
    }
})

# Create an event handler for the Add to Trim List button click
$addFileButton.Add_Click({

    $start = $startTimeTextBox.Text
    $stop = $stopTimeTextBox.Text

    $durationTimeSpan = [TimeSpan]::Parse($duration)
    $startTimeSpan = [TimeSpan]::Parse($start)
    $stopTimeSpan = [TimeSpan]::Parse($stop)

    if ($startTimeSpan -le $stopTimeSpan -and $stopTimeSpan -le $durationTimeSpan) {
        # Add file details to the array
        $fileDetails = @{
            "FullName" = $filePath
            "StartTime" = $start
            "StopTime" = $stop
            "Duration" = [TimeSpan]::Parse($stop) - [TimeSpan]::Parse($start)
            "TempFile" = ""
        }
        
        $trimmedVideo = "$env:TEMP\tempvideo_$(Get-Date -format 'yyyyMMddHHmmss').mp4"
        $fileDetails.TempFile = $trimmedVideo
        #$concatLine = "file '$trimmedVideo'"
        $trimDuration = $fileDetails.Duration
        #Add-Content -Value $concatLine -Path $concatFile
        ffmpeg -ss $fileDetails.StartTime -t $trimDuration -i $fileDetails.FullName -c copy $trimmedVideo -loglevel quiet
        
        $script:fileDetailsArray += $filedetails

        # Add the file details to the ListView
        $item = New-Object Windows.Forms.ListViewItem($fileDetails["FullName"])
        $item.SubItems.Add($fileDetails["StartTime"])
        $item.SubItems.Add($fileDetails["StopTime"])
        $item.SubItems.Add($($fileDetails["Duration"]).ToString())
        $item.SubItems.Add($fileDetails["TempFile"])
        $listView.Items.Add($item)

        # Recreate $fileDetailsArray from the ListView
        $fileDetailsArray = @()
        $fileDetailsArray = Set-FileDetailArray

        #convert the Duration into a timespan object and calculate the seconds then convert back to timespan   
        # Calculate the sum of durations in seconds
        $totalSeconds = $fileDetailsArray | ForEach-Object {
            $duration = [TimeSpan]::Parse($_.Duration)
            $duration.TotalSeconds
        } | Measure-Object -Sum | Select-Object -ExpandProperty Sum

        # Convert the total seconds back to a TimeSpan
        $totalTimeSpan = [TimeSpan]::FromSeconds($totalSeconds)
            

        # Clear the text boxes and enable the Add to Array button
        $trimAndStitchDetailsTable.Text = "Total duration of stitched video: " + $(Get-TotalDuration)
        $addFileButton.Enabled = $true
        $trimAndStitchButton.Enabled = $true  # Enable the Trim and Stitch button
        $clearAllButton.Enabled = $true
        $exportIndividualTrimButton.Enabled = $true        
    } else {
        # Show an error message if times are invalid
        [System.Windows.Forms.MessageBox]::Show("Invalid start or stop time. Please adjust the times.")
        $stopTimeTextBox.Text = $duration
    }
})

# Create an event handler for the Play Trimmed File button click
$playButton.Add_Click({
    
        # Launch the selected file with default media player
        try {
            #$process = [Diagnostics.Process]::Start("vlc.exe", "`"$($fileDetails.TempFile)`"")
            Start-Process -FilePath "$($file.Path)"
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Trimmed video segment could not be played.")
        }
})

# Create an event handler for the Play selected trim button click
$playSelectedTrim.Add_Click({
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
            #$process = [Diagnostics.Process]::Start("vlc.exe", "`"$($fileDetails.TempFile)`"")
            Start-Process -FilePath "$($fileDetails.TempFile)"
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Trimmed video segment could not be played.")
        }
    }
})

# Create an event handler for the Delete Selected button click
$deleteButton.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        $fileDetails = @{
            "FullName" = $selectedItem.SubItems[0].Text
            "StartTime" = $selectedItem.SubItems[1].Text
            "StopTime" = $selectedItem.SubItems[2].Text
        }

        # Find the corresponding file details in the array and remove it
        #$fileDetailsArray = $fileDetailsArray | Where-Object { $_.FullName -ne $fileDetails.FullName }
        
        # Remove the selected item from the ListView
        $listView.Items.Remove($selectedItem)
            

        # Clear the text boxes and enable the Add to Array button
        $trimAndStitchDetailsTable.Text = "Total duration of stitched video: " + $(Get-TotalDuration)

        # Disable buttons that rely on items in the list
        if ($listView.Items.Count -eq 0) {
            $deleteButton.Enabled = $false
            $playSelectedTrim.Enabled = $false
            $clearAllButton.Enabled = $false
            $exportIndividualTrimButton.Enabled = $false
            $trimAndStitchButton.Enabled = $false
            $moveUpButton.Enabled = $false
            $moveDownButton.Enabled = $false
            
        }
    }
})

# Create an event handler for the ListView SelectedIndexChanged event
$listView.Add_SelectedIndexChanged({
    if ($listView.SelectedItems.Count -gt 0) {
        $deleteButton.Enabled = $true
        $playSelectedTrim.Enabled = $true
        $moveUpButton.Enabled = $true
        $moveDownButton.Enabled = $true
        #$tempVideoPath["TempFile"] = $null

    } else {
        $deleteButton.Enabled = $false
        $playSelectedTrim.Enabled = $false
    }
})

# Create an event handler for the Move Up button click
$moveUpButton.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItemIndex = $listView.SelectedIndices[0]  # Get the index of the selected item

        # Move the selected item up in the list
        if ($selectedItemIndex -gt 0) {
            $selectedItem = $listView.Items[$selectedItemIndex].Clone()  # Clone the selected item
            $listView.Items.RemoveAt($selectedItemIndex)  # Remove the selected item
            $listView.Items.Insert($selectedItemIndex - 1, $selectedItem)  # Insert the cloned item one position above

            # Update the selected item index and reselect it
            $listView.Items[$selectedItemIndex - 1].Selected = $true
            $selectedItemIndex = $selectedItemIndex - 1
        }
    }
})

# Create an event handler for the Move Down button click
$moveDownButton.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        $selectedIndex = $selectedItem.Index

        # Check if the selected item is not already at the bottom
        if ($selectedIndex -lt ($listView.Items.Count - 1)) {
            # Swap the selected item with the item below it
            $listView.Items.RemoveAt($selectedIndex)
            $listView.Items.Insert($selectedIndex + 1, $selectedItem)
            $listView.Items[$selectedIndex + 1].Selected = $true
        }
    }
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
})

#endregion

#region
# Add controls to the form
$form.Controls.Add($addMp4Button)
$form.Controls.Add($startTimeLabel)
$form.Controls.Add($startTimeTextBox)
$form.Controls.Add($stopTimeLabel)
$form.Controls.Add($stopTimeTextBox)
$form.Controls.Add($durationLabel)
$form.Controls.Add($addFileButton)
$form.Controls.Add($listView)
$form.Controls.Add($playSelectedTrim)
$form.Controls.Add($deleteButton)
$form.Controls.Add($addedFileLabel)
$form.Controls.Add($moveUpButton)
$form.Controls.Add($moveDownButton)
$form.Controls.Add($trimAndStitchButton)
$form.Controls.Add($trimAndStitchDetailsTable)
$form.Controls.Add($exportIndividualTrimButton)
$form.Controls.Add($playButton)
$form.Controls.Add($exitButton)
$form.Controls.Add($clearAllButton)
#endregion

# Show the form
$form.ShowDialog()
