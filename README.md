# MP4 Stitch and Trim Tool

The MP4 Stitch and Trim Tool is a user-friendly Windows application that simplifies the process of trimming and stitching together MP4 video files. This tool is designed for ease of use, allowing you to select video clips, set start and stop times for trimming, and create a merged video with just a few clicks.

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

3. **Export Individual Trimmed Segments**:
   - After specifying trim times, use the "Export Individual Trims" button to save each trimmed segment as a separate MP4 file.
   - Select a destination folder to save the individual trims.
   - This feature is useful when you need to keep each trimmed segment as a separate file.

4. **Play Selected Clips**:
   - Select a clip in the ListView and click "Play Selected File" to preview it with VLC media player.

5. **Manage the Queue**:
   - Use the ListView to view and manage the files in the queue.
   - Reorder files by selecting an item and clicking "Move Up" or "Move Down."
   - To delete a file from the queue, select it and click "Delete Selected."

6. **Trim and Stitch**:
   - Click the "Trim and Stitch" button to process the files in the queue.
   - Specify the output file location in the file dialog that appears.
   - After processing, you will have the option to play the merged video with VLC.

7. **Clear the Queue**:
   - Click "Clear All" to remove all files from the queue.

8. **Exit the Application**:
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