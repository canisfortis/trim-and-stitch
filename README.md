# MP4 Stitch and Trim Tool

The MP4 Stitch and Trim Tool is a Windows application that allows you to easily trim and stitch together MP4 video files. It provides a user-friendly graphical interface for selecting video clips, specifying start and stop times for trimming, and creating a merged video.

## Features

- Add multiple MP4 video files to the trimming and stitching queue.
- Specify start and stop times for each clip.
- Play individual clips to preview them.
- Reorder and delete clips in the queue.
- Trim and stitch the selected clips into a single merged MP4 file.
- Play the merged video with VLC media player.
- Clear the queue and start over.

## Dependencies

Before using this application, make sure you have the following dependencies installed:

1. **FFmpeg**: This tool is used for video trimming and stitching. It should be available in your system's PATH. You can download FFmpeg from [https://ffmpeg.org/download.html](https://ffmpeg.org/download.html).

2. **VLC media player**: VLC is required to play video files. Ensure that VLC is installed on your system and also available in your system's PATH. You can download VLC from [https://www.videolan.org/vlc/](https://www.videolan.org/vlc/).

## Usage

1. **Adding MP4 Files**:
   - Click the "Add MP4 File" button to add video files to the queue.
   - Select a video file from the file dialog.

2. **Specifying Trim Times**:
   - For each added file, specify the start and stop times for trimming in the format `hh:mm:ss`.
   - Click "Add to Array" to add the file to the trimming queue.
   - You can also play the source video to verify the trim times.

3. **Managing the Queue**:
   - Use the ListView to view and manage the files in the queue.
   - You can reorder files by selecting an item and clicking "Move Up" or "Move Down."
   - To delete a file from the queue, select it and click "Delete Selected."

4. **Trimming and Stitching**:
   - Click the "Trim and Stitch" button to process the files in the queue.
   - Specify the output file location in the file dialog that appears.
   - After processing, you will have the option to play the merged video with VLC.

5. **Playing Selected Clips**:
   - Select a clip in the ListView and click "Play Selected File" to preview it with VLC.

6. **Clearing the Queue**:
   - Click "Clear All" to remove all files from the queue.

7. **Exiting the Application**:
   - Click "Exit" to close the application.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- This application uses FFmpeg for video processing.
- VLC media player is used for video playback.

## Contributing


## Issues

