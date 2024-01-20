# MP4 Stitch and Trim Tool

## Overview
The MP4 Stitch and Trim Tool is a Windows Forms application developed in PowerShell, designed to assist users in editing MP4 video files. It allows for trimming segments from videos, stitching multiple segments together, and exporting individual trims or the entire stitched video.

## Key Features
- **Add MP4 File**: Select and add MP4 files to the application.
- **Trim and Stitch**: Trim video segments and stitch them together into a single file.
- **Preview Trim**: Preview the trimmed segments before adding them to the trim list.
- **Export Trims**: Export individual trimmed segments or the entire stitched video.
- **List View**: Display added video files and their trim details.
- **Direct Copy Processing**: The tool uses FFmpeg to directly copy segments from the source video. This means that the videos are not re-encoded, ensuring extremely fast processing and preserving the original quality of the source video.

## Requirements
- **FFmpeg**: This application requires [FFmpeg](https://ffmpeg.org/) to process video files. FFmpeg is used for trimming and stitching video segments. Ensure FFmpeg is installed and accessible in your system's PATH.

## Functions
### `Set-FileDetailArray`
Recreates an array of file details from the ListView items.
- **Parameters**: `ListView` control.

### `Get-TotalDuration`
Calculates the total duration of all video segments in the ListView.
- **Returns**: `TimeSpan` object representing the total duration.

### `Start-Video`
Plays a video file using the default media player.
- **Parameters**: File path of the video.

### `Remove-SelectedTrim`
Removes the selected trim from the ListView and updates the UI.
- **Parameters**: `ListView` control.

### `Move-TrimVideoItemDown` / `Move-TrimVideoItemUp`
Moves the selected trim item down/up in the ListView.
- **Parameters**: `ListView` control.

### `Edit-TrimVideoItem`
Edits the timestamps of an item in the ListView.
- **Parameters**: `ListView` control.

### `ValidateTimeInput`
Validates numeric input for time fields.
- **Parameters**: `TextBox` control, maximum allowed value.

### `GetStartTime`
Concatenates time parts into a hh:mm:ss format.

### `ProcessTrimAndStitch`
Processes videos in the list into a single merged file.
- **Parameters**: `ListView` control.

### `CalculateTimeSpans`
Calculates start, stop, and duration timespans for a video segment.
- **Parameters**: `NumericUpDown` controls for start and stop times.

### `AddVideoFileToList`
Adds a video file's details to the ListView and updates the UI.
- **Parameters**: File path, `ListView` control, `Label` control, and a reference to the file details array.

### `FormatTime`
Gets the timestamps in hh:mm:ss format from individual h, m, s textboxes.
- **Parameters**: `NumericUpDown` controls for hours, minutes, and seconds.

### `PreviewTrimmedVideo`
Previews the video before adding or updating it to the list.
- **Parameters**: File path.

## UI/Form Handling
The user interface is built using Windows Forms and consists of various controls like buttons, labels, numeric up/down controls, and a ListView. The form is initialized with specific dimensions and properties, and each control is added to the form with defined properties like location, size, and text.

Event handlers are attached to various controls to handle user interactions, such as clicking buttons, changing text, and selecting items in the ListView. These event handlers call the respective functions to perform actions like adding a video file, trimming, stitching, previewing, and exporting video segments.

## Usage Instructions
1. **Add MP4 File**: Click the 'Add MP4 file' button to select and add a video file.
2. **Set Trim Times**: Use the numeric up/down controls to set the start and stop times for trimming.
3. **Preview Trim**: Click 'Preview Trim' to see a preview of the trimmed segment.
4. **Add to Trim List**: Click 'Add to trim list' to add the segment to the list.
5. **Edit Trim Times**: Select a segment and click 'Update Trim Times' to modify its start and stop times.
6. **Trim and Stitch**: Once all segments are added, click 'Trim and stitch' to create the final video.
7. **Export Options**: Use 'Export individual trims' or 'Export individual trims as gif' for exporting segments.

## Closing Notes
The MP4 Stitch and Trim Tool is a comprehensive solution for basic video editing tasks, providing a straightforward interface for users to manage video segments efficiently. The application is powered by PowerShell scripts, combining the flexibility of scripting with the usability of a graphical interface.
