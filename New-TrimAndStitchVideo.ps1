Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO
Add-Type -AssemblyName System


#add some checking if this file exists. If not pop a message box and exit.

# Import the functions
#check if the functions file exists
if (!(Test-Path -Path .\functions.ps1)) {
    [System.Windows.Forms.MessageBox]::Show("The functions file is missing. Please download the functions file and try again.")
    exit
}
import-module .\functions.ps1 -Force


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
$durationLabel.Location = New-Object Drawing.Point(20 ,60)
$durationLabel.Width = 300

# Create a text box to display the duration
$addedFileLabel = New-Object Windows.Forms.Label
$addedFileLabel.Text = "No files currently added."
$addedFileLabel.Location = New-Object Drawing.Point(20, 90)
$addedFileLabel.Width = 700

# Create a button to play the current trim file
$playButton = New-Object Windows.Forms.Button
$playButton.Text = "Play source file"
$playButton.Location = New-Object Drawing.Point(20, 120)
$playButton.Width = 120
$playButton.Enabled = $false

# Create a ListView to display file details with columns
$listView = New-Object Windows.Forms.ListView
$listView.Location = New-Object Drawing.Point(20, 280)
$listView.Width = 900
$listView.Height = 200
$listView.View = [System.Windows.Forms.View]::Details
$listView.HideSelection = $false
$listView.FullRowSelect = $true

# Add columns to the ListView
$listView.Columns.Add("Source File", 300)
$listView.Columns.Add("Start Time", 150)
$listView.Columns.Add("Stop Time", 150)
$listView.Columns.Add("Duration", 150)

# Create a button to add the file details to the array
$addFileButton = New-Object Windows.Forms.Button
$addFileButton.Text = "Add to trim list"
$addFileButton.Location = New-Object Drawing.Point(20, 250)
$addFileButton.Width = 100
$addFileButton.Enabled = $false

# Create a button to open the selected file in the default media player
$playSelectedTrim = New-Object Windows.Forms.Button
$playSelectedTrim.Text = "Play selected file"
$playSelectedTrim.Location = New-Object Drawing.Point(130, 250)
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
$deleteButton.Location = New-Object Drawing.Point(370, 250)
$deleteButton.Width = 100
$deleteButton.Enabled = $false

# Create a button to move the selected item up
$moveUpButton = New-Object Windows.Forms.Button
$moveUpButton.Text = "Move up"
$moveUpButton.Location = New-Object Drawing.Point(480, 250)
$moveUpButton.Width = 100
$moveUpButton.Enabled = $false

# Create a button to move the selected item down
$moveDownButton = New-Object Windows.Forms.Button
$moveDownButton.Text = "Move down"
$moveDownButton.Location = New-Object Drawing.Point(590, 250)
$moveDownButton.Width = 100
$moveDownButton.Enabled = $false

# Create a button to exit the application
$exitButton = New-Object Windows.Forms.Button
$exitButton.Text = "Exit"
$exitButton.Location = New-Object Drawing.Point(20, 600)
$exitButton.Width = 100

# Create a button to clear the list
$clearAllButton = New-Object Windows.Forms.Button
$clearAllButton.Text = "Clear all"
$clearAllButton.Location = New-Object Drawing.Point(700, 250)
$clearAllButton.Width = 100
$clearAllButton.Enabled = $false

# Create a button to just export individual trims
$exportIndividualTrimButton = New-Object Windows.Forms.Button
$exportIndividualTrimButton.Text = "Export individual trims"
$exportIndividualTrimButton.Location = New-Object Drawing.Point(20, 570)
$exportIndividualTrimButton.Width = 150
$exportIndividualTrimButton.Enabled = $false

#Create a button to export an individual trim as a gif.
$exportIndividualTrimGifButton = New-Object Windows.Forms.Button
$exportIndividualTrimGifButton.Text = "Export individual trims as gif"
$exportIndividualTrimGifButton.Location = New-Object Drawing.Point(190, 570)
$exportIndividualTrimGifButton.Width = 170
$exportIndividualTrimGifButton.Enabled = $false

# Create a button to Trim and Stitch
$trimAndStitchButton = New-Object Windows.Forms.Button
$trimAndStitchButton.Text = "Trim and stitch"
$trimAndStitchButton.Location = New-Object Drawing.Point(20, 510)
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


# Create an event handler for the Play Trimmed File button click
$playButton.Add_Click({
    #[System.Windows.Forms.MessageBox]::Show($filePath)
    Start-Video $filePath
})

# Create an event handler for the Trim and Stitch button click
$trimAndStitchButton.Add_Click({
        ProcessTrimAndStitch -listView $listView
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

            # Get the duration using the function
            $duration = Get-VideoDuration -filePath $filePath
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
            #$startTimeHoursTextBox.Enabled = $true
            #$startTimeMinutesTextBox.Enabled = $true
            #$startTimeSecondsTextBox.Enabled = $true

            #$stopTimeHoursTextBox.Enabled = $true
            #$stopTimeMinutesTextBox.Enabled = $true
            #$stopTimeSecondsTextBox.Enabled = $true

            $addFileButton.Enabled = $true
            $playButton.Enabled = $true
            $previewTrimDurationVideoButton.Enabled = $true
        }
    } catch {
        # Handle exceptions
        [System.Windows.Forms.MessageBox]::Show("An error occurred: " + $_.Exception.Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

# Create an event handler for the Add to Trim List button click
$addFileButton.Add_Click({

    # Call the function with the required parameters
    AddVideoFileToList -filePath $filePath -listView $listView -trimAndStitchDetailsTable $trimAndStitchDetailsTable -fileDetailsArray ([ref]$fileDetailsArray)

})

<# Add event handlers for each text box
$startTimeHoursTextBox.Add_TextChanged({
    ValidateTimeInput $startTimeHoursTextBox 23
})
$startTimeMinutesTextBox.Add_TextChanged({
    ValidateTimeInput $startTimeMinutesTextBox 59
})
$startTimeSecondsTextBox.Add_TextChanged({
    ValidateTimeInput $startTimeSecondsTextBox 59
})
#>

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
    Start-Video $filePath -isTrimmed
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

#list view update time text box with start and stop times from the list (single click select)
$listView.Add_Click({
    $startTimeHoursNumericUpDown.Value = $listView.SelectedItems[0].SubItems[1].Text.split(':')[0]
    $startTimeMinutesNumericUpDown.Value = $listView.SelectedItems[0].SubItems[1].Text.split(':')[1]
    $startTimeSecondsNumericUpDown.Value = $listView.SelectedItems[0].SubItems[1].Text.split(':')[2]
    $stopTimeHoursNumericUpDown.Value = $listView.SelectedItems[0].SubItems[2].Text.split(':')[0]
    $stopTimeMinutesNumericUpDown.Value = $listView.SelectedItems[0].SubItems[2].Text.split(':')[1]
    $stopTimeSecondsNumericUpDown.Value = $listView.SelectedItems[0].SubItems[2].Text.split(':')[2]
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


# Show the form
$form.ShowDialog()
