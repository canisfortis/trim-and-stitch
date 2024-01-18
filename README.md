
# MP4 Stitch and Trim Tool

The MP4 Stitch and Trim Tool is a user-friendly Windows application that simplifies the process of trimming and stitching together MP4 video files. This tool is designed for ease of use, allowing you to select video clips, set start and stop times for trimming, and create a merged video with just a few clicks.

## New Features

The latest version of the MP4 Stitch and Trim Tool includes the following new features:

1. **Batch Processing**: You can now select multiple video clips at once and apply the same trim settings to all of them. This saves time and effort when working with a large number of files.

2. **Custom Output Settings**: You have the option to export individual clips as a gif - this will be the only conversion type this tool uses.

3. **Preview Trimming**: Before applying the trim settings, you can preview the trimmed segment of each video clip. This helps you ensure that the selected start and stop times are accurate.

4. **Enhanced User Interface**: The user interface has been improved for better usability and a more intuitive experience. The tool now provides clear instructions and visual cues to guide you through the trimming and stitching process.

5. **Error Handling**: The tool now handles errors more gracefully and provides informative error messages in case of any issues during the trimming or stitching process.

We hope that these new features enhance your video editing workflow and make the MP4 Stitch and Trim Tool even more powerful and convenient to use.


## About FFmpeg Copy Mode

The MP4 Stitch and Trim Tool utilizes FFmpeg in "copy mode" when trimming and stitching video clips. This mode is specifically chosen to ensure that no unnecessary video encoding takes place during the process.

### What is FFmpeg Copy Mode?

In FFmpeg, "copy mode" (also known as stream copy or bitstream copy) is a feature that allows the tool to perform video operations without re-encoding the video and audio streams. Instead of transcoding the entire video, FFmpeg simply copies the selected portions of the source video into the output file. This mode is highly efficient and preserves the original video and audio quality.

### Why Use FFmpeg Copy Mode?

Using FFmpeg in copy mode offers several advantages:

1. **Lossless Quality**: By avoiding re-encoding, the tool maintains the original video and audio quality. This ensures that the trimmed clips and the final merged video are identical in quality to the source files.

2. **Speed**: Copying streams is significantly faster than video encoding, especially for large video files. This results in quicker processing times, allowing you to create your merged video swiftly.

3. **Preservation**: The tool respects the integrity of the source files and does not introduce any artifacts or quality degradation during the trimming and stitching process.

4. **Resource Efficiency**: Video encoding can be resource-intensive, requiring substantial CPU power and time. FFmpeg copy mode conserves system resources and is more efficient for this particular task.

### What You Should Expect

When using the MP4 Stitch and Trim Tool, you can expect a seamless and efficient trimming and stitching process thanks to FFmpeg's copy mode. Your final merged video will match the quality of your source clips, and the entire process will be completed in a fraction of the time it would take for video re-encoding.

Feel confident that your videos will remain intact and unaltered in terms of quality when using this tool, making it an excellent choice for preserving your video content while creating a stitched video from multiple clips.




## Getting Started

Follow these simple steps to download the PS1 script file and run the MP4 Stitch and Trim Tool on your Windows machine:

### Prerequisites

Before you begin, please ensure you have the following prerequisites installed:

1. **FFmpeg**: This tool is used for video trimming and stitching. It should be available in your system's PATH. You can download FFmpeg from [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html).

### Installation

1. **Download the Script**:
   - Click the "Download" button at the top of this repository to download the `MP4StitchAndTrimTool.ps1` script file to your computer.

2. **Run the Script**:
   - Right click on the script and click "Run with PowerShell"

3. **Use the Application**:
   - The MP4 Stitch and Trim Tool graphical user interface (GUI) will open, allowing you to add, trim, stitch, and manage your video clips effortlessly.

4. **Enjoy Video Editing**:
   - Start adding MP4 files, specifying trim times, and utilizing the tool's features to streamline your video editing process.


## Usage

The MP4 Stitch and Trim Tool offers a range of features to streamline your video editing process:

1. **Add Multiple MP4 Files**:
   - Click the "Add MP4 File" button to add video files to the trimming and stitching queue.
   - Select a video file from the file dialog.

2. **Specify Trim Times**:
   - For each added file, specify the start and stop times for trimming in the format `hh:mm:ss`.
   - Click "Add to Array" to add the file to the trimming queue.
   - You can also play the source video to verify the trim times.

3. **Play Selected Clips**:

   The MP4 Stitch and Trim Tool allows you to preview and play selected clips before performing any trimming or stitching operations. This feature is particularly useful when you want to verify the content of a specific clip or ensure that the trim times are set correctly.

   To use the "Edit Trim" button and play selected clips:

   1. Add MP4 files to the trimming and stitching queue using the "Add MP4 File" button.
   2. Specify the start and stop times for trimming each file in the format `hh:mm:ss`.
   3. Click the "Add to Array" button to add the file to the trimming queue.
   4. Select the clip, click the "Edit Trim" button
   5. Set the new start and stop times
   6. Click the preview button to see if the new times work, adjust as necessary.
   7. Once happy, click Save. The duration and start/stop of the clip has now been updated.
   

4. **Export Individual Trimmed Segments**:
   - After specifying trim times, use the "Export Individual Trims" button to save each trimmed segment as a separate MP4 file.
   - Select a destination folder to save the individual trims.
   - This feature is useful when you need to keep each trimmed segment as a separate file.

5. **Export Individual Trims to GIF**

   The MP4 Stitch and Trim Tool also provides the ability to export individual trimmed segments as GIF files. This feature can be useful when you want to create animated GIFs from specific parts of your videos.

   To export individual trims to GIF:

   1. After specifying trim times for each file, click the "Export Individual Trims" button.
   2. In the export options dialog, select the "GIF" format.
   3. Choose a destination folder to save the GIF files.
   4. Click "Export" to start the export process.
   5. The tool will generate a separate GIF file for each trimmed segment, preserving the animation and quality of the original video.

   Note: The export to GIF feature requires additional dependencies, such as ImageMagick, to be installed on your system. Make sure to install these dependencies before using this feature.

   Enjoy creating animated GIFs from your trimmed video segments with the MP4 Stitch and Trim Tool!


6. **Play Selected Clips**:
   - Select a clip in the ListView and click "Play Selected File" to preview it with VLC media player.

7. **Manage the Queue**:
   - Use the ListView to view and manage the files in the queue.
   - Reorder files by selecting an item and clicking "Move Up" or "Move Down."
   - To delete a file from the queue, select it and click "Delete Selected."

8. **Trim and Stitch**:
   - Click the "Trim and Stitch" button to process the files in the queue.
   - Specify the output file location in the file dialog that appears.
   - After processing, you will have the option to play the merged video with VLC.

9. **Clear the Queue**:
   - Click "Clear All" to remove all files from the queue.

10. **Exit the Application**:
   - Click "Exit" to close the application.


- **Dependencies**: The tool requires the following dependencies to be installed:
  1. **FFmpeg**: Used for video trimming and stitching. Make sure it is available in your system's PATH. Download FFmpeg from [here](https://ffmpeg.org/download.html).
  2. **Default Media Player capable of playing the selected source video types**: Required for playing video files. VLC is one such video player. Get VLC from [here](https://www.videolan.org/vlc/).

## License

This project is licensed under the GNU v3 License. See the [LICENSE](LICENSE) file for full license details.

## Acknowledgments

- This application relies on FFmpeg for video processing.

## Contributing

If you'd like to contribute to the development of this tool or report issues, please check the [Issues](link_to_issues) section.