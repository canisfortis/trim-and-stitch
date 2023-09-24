# MP4 Stitch and Trim Tool

The MP4 Stitch and Trim Tool is a user-friendly Windows application that simplifies the process of trimming and stitching together MP4 video files. This tool is designed for ease of use, allowing you to select video clips, set start and stop times for trimming, and create a merged video with just a few clicks.

## Features

- **Add Multiple MP4 Files**: Add as many MP4 video files as needed to the trimming and stitching queue.

- **Specify Trim Times**: For each video file in the queue, specify precise start and stop times for trimming in the format `hh:mm:ss`.

- **Preview Clips**: Play individual clips to preview them before adding them to the final merged video.

- **Queue Management**: Easily manage your queue of video clips using the ListView. Reorder clips, delete unnecessary ones, or clear the queue entirely.

- **Trim and Stitch**: Combine the selected video clips into a single merged MP4 file. The tool automatically handles the trimming and stitching process.

- **Play Merged Video**: Play the merged video seamlessly with VLC media player directly from the application.

- **Dependencies**: The tool requires the following dependencies to be installed:
  1. **FFmpeg**: Used for video trimming and stitching. Make sure it is available in your system's PATH. Download FFmpeg from [here](https://ffmpeg.org/download.html).
  2. **VLC media player**: Required for playing video files. Ensure VLC is installed and accessible via your system's PATH. Get VLC from [here](https://www.videolan.org/vlc/).

## Usage

1. **Adding MP4 Files**:
   - Click the "Add MP4 File" button to select and add video files to the queue.

2. **Specifying Trim Times**:
   - For each added file, set the start and stop times for trimming in the `hh:mm:ss` format.
   - Click "Add to Array" to include the file in the trimming queue.
   - You can also preview the source video to validate trim times.

3. **Managing the Queue**:
   - Utilize the ListView to view and manage the files in the queue.
   - Rearrange files by selecting an item and clicking "Move Up" or "Move Down."
   - To remove a file from the queue, select it and click "Delete Selected."

4. **Trimming and Stitching**:
   - Click the "Trim and Stitch" button to process the files in the queue.
   - Specify the output file location in the file dialog that appears.
   - After processing, you'll have the option to play the merged video with VLC.

5. **Playing Selected Clips**:
   - Select a clip in the ListView and click "Play Selected File" to preview it using VLC.

6. **Clearing the Queue**:
   - Click "Clear All" to remove all files from the queue.

7. **Exiting the Application**:
   - Click "Exit" to close the application.

## License

This project is licensed under the GNU v3 License. See the [LICENSE](LICENSE) file for full license details.

## Acknowledgments

- This application relies on FFmpeg for video processing.
- VLC media player is used for video playback.

## Contributing

If you'd like to contribute to the development of this tool or report issues, please check the [Issues](link_to_issues) section.

