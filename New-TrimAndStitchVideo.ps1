Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System

$StartTimeLocation = @{X=20;Y=180}
$StopTimeLocation = @{X=20;Y=210}
$DurationLocation = @{X=20;Y=60}
$AddedFileLocation = @{X=20;Y=90}
$PlayButtonLocation = @{X=20;Y=120}
$ListViewLocation = @{X=20;Y=280}
$AddFileButtonLocation = @{X=20;Y=250}
$OpenVlcButtonLocation = @{X=$AddFileButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$DeleteButtonLocation = @{X=$OpenVlcButtonLocation.X+130;Y=$AddFileButtonLocation.Y}
$MoveUpButtonLocation = @{X=$DeleteButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$MoveDownButtonLocation = @{X=$MoveUpButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$clearAllButtonLocation = @{X=$MoveDownButtonLocation.X+110;Y=$AddFileButtonLocation.Y}
$TrimAndStitchButtonLocation = @{X=20;Y=500}
$exitButtonLocation = @{X=20;Y=590}



# Create a form
$form = New-Object Windows.Forms.Form
$form.Text = "MP4 Stitch and Trim Tool"
$form.Width = 1000
$form.Height = 700
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle

# Initialize start and stop times
$startTime = 0
$stopTime = 0

# Initialize an array to store file details
$fileDetailsArray = @()

# Create a button to add an MP4 file
$button = New-Object Windows.Forms.Button
$button.Text = "Add MP4 File"
$button.Location = New-Object Drawing.Point(20, 20)
$button.Width = 100

# Create a label for start time
$startTimeLabel = New-Object Windows.Forms.Label
$startTimeLabel.Text = "Start Time:"
$startTimeLabel.Location = New-Object Drawing.Point($($startTimeLocation.X), $($startTimeLocation.Y))

# Create a text box for start time
$startTimeTextBox = New-Object Windows.Forms.TextBox
$startTimeTextBox.Location = New-Object Drawing.Point($($startTimeLocation.X+130), $($startTimeLocation.Y))
$startTimeTextBox.Width = 80
$startTimeTextBox.Text = '00:00:00'

# Create a label for stop time
$stopTimeLabel = New-Object Windows.Forms.Label
$stopTimeLabel.Text = "Stop Time:"
$stopTimeLabel.Location = New-Object Drawing.Point($stopTimeLocation.X, $StopTimeLocation.Y)

# Create a text box for stop time
$stopTimeTextBox = New-Object Windows.Forms.TextBox
$stopTimeTextBox.Location = New-Object Drawing.Point(150, $StopTimeLocation.Y)
$stopTimeTextBox.Width = 80

# Create a text box to display the duration
$durationLabel = New-Object Windows.Forms.Label
$durationLabel.Text = "Duration: N/A"
$durationLabel.Location = New-Object Drawing.Point($DurationLocation.X, $DurationLocation.Y)

# Create a text box to display the duration
$addedFileLabel = New-Object Windows.Forms.Label
$addedFileLabel.Text = "No files currently added."
$addedFileLabel.Location = New-Object Drawing.Point($AddedFileLocation.X, $AddedFileLocation.Y)
$addedFileLabel.Width = 700

# Create a button to play the current trim file
$playButton = New-Object Windows.Forms.Button
$playButton.Text = "Play Source File"
$playButton.Location = New-Object Drawing.Point($PlayButtonLocation.X, $PlayButtonLocation.Y)
$playButton.Width = 120
$playButton.Enabled = $false


# Create a ListView to display file details with columns
$listView = New-Object Windows.Forms.ListView
$listView.Location = New-Object Drawing.Point($ListViewLocation.X, $ListViewLocation.Y)
$listView.Width = 700
$listView.Height = 200
$listView.View = [System.Windows.Forms.View]::Details

# Add columns to the ListView
$listView.Columns.Add("File", 300)
$listView.Columns.Add("Start Time", 150)
$listView.Columns.Add("Stop Time", 150)



# Create a button to add the file details to the array
$addFileButton = New-Object Windows.Forms.Button
$addFileButton.Text = "Add to Array"
$addFileButton.Location = New-Object Drawing.Point($AddFileButtonLocation.X, $AddFileButtonLocation.Y)
$addFileButton.Width = 100
$addFileButton.Enabled = $false

# Create a button to open the selected file in VLC
$openVlcButton = New-Object Windows.Forms.Button
$openVlcButton.Text = "Play Selected File"
$openVlcButton.Location = New-Object Drawing.Point($OpenVlcButtonLocation.X, $OpenVlcButtonLocation.Y)
$openVlcButton.Width = 120
$openVlcButton.Enabled = $false

# Create a button to delete the selected item from the ListView
$deleteButton = New-Object Windows.Forms.Button
$deleteButton.Text = "Delete Selected"
$deleteButton.Location = New-Object Drawing.Point($DeleteButtonLocation.X, $DeleteButtonLocation.Y)
$deleteButton.Width = 100
$deleteButton.Enabled = $false

# Create a button to move the selected item up
$moveUpButton = New-Object Windows.Forms.Button
$moveUpButton.Text = "Move Up"
$moveUpButton.Location = New-Object Drawing.Point($MoveUpButtonLocation.X, $MoveUpButtonLocation.Y)
$moveUpButton.Width = 100
$moveUpButton.Enabled = $false

# Create a button to move the selected item down
$moveDownButton = New-Object Windows.Forms.Button
$moveDownButton.Text = "Move Down"
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
$clearAllButton.Text = "Clear All"
$clearAllButton.Location = New-Object Drawing.Point($clearAllButtonLocation.X, $clearAllButtonLocation.Y)
$clearAllButton.Width = 100

# Create a button to Trim and Stitch
$trimAndStitchButton = New-Object Windows.Forms.Button
$trimAndStitchButton.Text = "Trim and Stitch"
$trimAndStitchButton.Location = New-Object Drawing.Point($TrimAndStitchButtonLocation.X, $TrimAndStitchButtonLocation.Y)
$trimAndStitchButton.Width = 100
$trimAndStitchButton.Enabled = $false



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
            }
        }
        
        $count = 1
        
        foreach ($trim in $trimData) {
            $trimmedVideo = $env:TEMP + "\tempvideo" + (Get-Date -format 'yyyyMMddHHmmss') + "_" + $count + ".mp4"
            $concatLine = "file '$trimmedVideo'"
            $trimDuration = [TimeSpan]::Parse($trim."Stop Time") - [TimeSpan]::Parse($trim."Start Time")
            Add-Content -Value $concatLine -Path $concatFile
            ffmpeg -ss $trim."Start Time" -t $trimDuration -i $trim.File -c copy $trimmedVideo
            $count++
        }

        # Notify the user when trimming and stitching is complete
        [System.Windows.Forms.MessageBox]::Show("Trimming and stitching completed.")

        if ($trimData.Count -gt 1) {
            ffmpeg -f concat -safe 0 -i $concatFile -c copy $mergedVideo 
        }
        else {
            Copy-Item $trimmedVideo -Destination $mergedVideo
        }
        
        $process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$mergedVideo`"")
    }
})

# Create an event handler for the Add MP4 File button click
$button.Add_Click({
    

    $openFileDialog = New-Object Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "MP4 Files (*.mp4)|*.mp4"

    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:filePath = $openFileDialog.FileName
        #$filePath = "C:\Users\David\Videos\Up a Ledge.mp4"

        # Use Shell.Application to get the duration of the MP4 file
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace((Get-Item $filePath).DirectoryName)
        $script:file = $folder.ParseName((Get-Item $filePath).Name) 
        $script:duration = $folder.GetDetailsOf($file, 27)
        #Write-Host $file.Path
        #Write-host $duration

        # Display the duration
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

# Create an event handler for the Add to Array button click
$addFileButton.Add_Click({
    Write-host "Duration: $duration"
    Write-host "Start: $($startTimeTextBox.Text)"
    Write-host "Stop: $($stopTimeTextBox.Text)"
    Write-host "File: $filePath"
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
        }
        $fileDetailsArray += $fileDetails

        # Add the file details to the ListView
        $item = New-Object Windows.Forms.ListViewItem($fileDetails["FullName"])
        $item.SubItems.Add($fileDetails["StartTime"])
        $item.SubItems.Add($fileDetails["StopTime"])
        $listView.Items.Add($item)

        # Clear the text boxes and enable the Add to Array button
        $startTimeTextBox.text = '00:00:00'
        $stopTimeTextBox.text = $duration
        $addFileButton.Enabled = $true
        $trimAndStitchButton.Enabled = $true  # Enable the Trim and Stitch button
    } else {
        # Show an error message if times are invalid
        [System.Windows.Forms.MessageBox]::Show("Invalid start or stop time. Please adjust the times.")
        $startTimeTextBox.Text = '00:00:00'
        $stopTimeTextBox.Text = $duration
    }
})


# Create an event handler for the Play Trimmed File button click
$playButton.Add_Click({
    $vlcExePath = "C:\Program Files\VideoLAN\VLC\vlc.exe"  # Update this path to match your VLC installation
    if (Test-Path $vlcExePath) {
        $process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$($file.Path)`"")
    } else {
        [System.Windows.Forms.MessageBox]::Show("VLC media player not found. Please provide the correct path to VLC executable.")
    }    
})


# Create an event handler for the Open in VLC button click
$openVlcButton.Add_Click({
    if ($listView.SelectedItems.Count -gt 0) {
        $selectedItem = $listView.SelectedItems[0]
        $fileDetails = @{
            "FullName" = $selectedItem.SubItems[0].Text
            "StartTime" = $selectedItem.SubItems[1].Text
            "StopTime" = $selectedItem.SubItems[2].Text
        }

        # Launch VLC with the selected file
        $vlcExePath = "C:\Program Files\VideoLAN\VLC\vlc.exe"  # Update this path to match your VLC installation
        if (Test-Path $vlcExePath) {
            $process = [Diagnostics.Process]::Start("C:\Program Files\VideoLAN\VLC\vlc.exe", "`"$($fileDetails.FullName)`"")
        } else {
            [System.Windows.Forms.MessageBox]::Show("VLC media player not found. Please provide the correct path to VLC executable.")
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
        $fileDetailsArray = $fileDetailsArray | Where-Object { $_.FullName -ne $fileDetails.FullName }
        
        # Remove the selected item from the ListView
        $listView.Items.Remove($selectedItem)

        # Disable the Delete Selected and Open in VLC buttons if there are no items left
        if ($listView.Items.Count -eq 0) {
            $deleteButton.Enabled = $false
            $openVlcButton.Enabled = $false
        }
    }
})


# Create an event handler for the ListView SelectedIndexChanged event
$listView.Add_SelectedIndexChanged({
    if ($listView.SelectedItems.Count -gt 0) {
        $deleteButton.Enabled = $true
        $openVlcButton.Enabled = $true
        $moveUpButton.Enabled = $true
        $moveDownButton.Enabled = $true
        
    } else {
        $deleteButton.Enabled = $false
        $openVlcButton.Enabled = $false
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
    $openVlcButton.Enabled = $false
    $moveUpButton.Enabled = $false
    $moveDownButton.Enabled = $false
    $trimAndStitchButton.Enabled = $false
})


# Add controls to the form
$form.Controls.Add($button)
$form.Controls.Add($startTimeLabel)
$form.Controls.Add($startTimeTextBox)
$form.Controls.Add($stopTimeLabel)
$form.Controls.Add($stopTimeTextBox)
$form.Controls.Add($durationLabel)
$form.Controls.Add($addFileButton)
$form.Controls.Add($listView)
$form.Controls.Add($openVlcButton)
$form.Controls.Add($deleteButton)
$form.Controls.Add($addedFileLabel)
$form.Controls.Add($moveUpButton)
$form.Controls.Add($moveDownButton)
$form.Controls.Add($trimAndStitchButton)
$form.Controls.Add($playButton)
$form.Controls.Add($exitButton)
$form.Controls.Add($clearAllButton)

# Show the form
$form.ShowDialog()
