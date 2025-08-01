# 🎙️ Auto Whisper

**Auto Whisper** is a safe, automated Bash script for batch-transcribing `.mp3` files using [OpenAI Whisper](https://github.com/openai/whisper). It safely handles filenames with spaces, special characters, and Unicode symbols by creating a temporary symbolic link during processing — no renaming or moving your files.

---

## ✅ Features

- 🔐 **Safe filename handling** — avoids Whisper crashes on complex filenames.
- ⚡ **Skips already-transcribed files** — no reprocessing.
- 🗂️ Outputs to clean `/output` directory in `.txt`, `.srt`, `.vtt`, and `.json`.
- ♻️ **Automatic cleanup** — no leftover temp files, even on Ctrl+C.
- 📊 **Progress tracking** — shows ETA, average time per file, and live status.

---

## 🛠 Requirements

- [Whisper CLI](https://github.com/openai/whisper) installed and in your `$PATH`
- Bash (Linux/macOS)
- `cuda`-enabled GPU (or change the `--device` flag to `cpu` if needed)

---

## 🚀 Usage

1. Place `auto_whisper.sh` in the same folder as your `.mp3` files.
2. Make the script executable:

   ```bash
   chmod +x auto_whisper.sh

    Run it:

    ./auto_whisper.sh

Output files will be written to the ./output/ directory using the original filenames.
⚙️ Configuration

Edit the top of the script to configure behavior:

OUT_DIR="./output"      # Output directory
FILE_EXT=".mp3"         # File type to process
TEMP_LINK_NAME="whisper_temp_processing_file"  # Temp symlink name

To support other audio formats (e.g. .wav, .m4a), change FILE_EXT.
📦 Output Format

Each processed audio file generates up to four files in the output folder:

    yourfile.txt — plain text transcript

    yourfile.srt — subtitles (for videos)

    yourfile.vtt — web caption format

    yourfile.json — raw Whisper JSON output

🧽 Cleanup

All temporary files and symbolic links are automatically removed on script exit — even if interrupted with Ctrl+C.
💬 Example Output

🎧 Detected 12 .mp3 file(s)
✅ Already processed: 8
⏳ Remaining to process: 4

➡️  [9/12] Preparing to transcribe: ./Lecture Notes.mp3
    (Processing as whisper_temp_processing_file.mp3)
✅ Done: ./Lecture Notes.mp3
📊 Progress: 9 / 12
⏱️  Avg/file: 42s | ETA: ~2m

🔓 License

MIT License — free for personal and commercial use.
🙌 Acknowledgments

    Built using OpenAI Whisper

    Designed for creators, researchers, archivists, and developers needing a safer Whisper CLI pipeline
