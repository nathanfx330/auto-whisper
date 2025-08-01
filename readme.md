Auto_Whisper.sh
Overview

Auto_Whisper.sh is a bash script that automatically batches and transcribes all .mp3 audio files in the current directory using OpenAI’s Whisper CLI tool. It outputs transcriptions into a specified folder and supports:

    Resuming interrupted transcriptions by skipping already processed files

    Showing progress, including counts and estimated time remaining

    Using GPU acceleration if available

    Configurable model, language, and output directory

Requirements

    OpenAI Whisper CLI installed and accessible via whisper command

    bash shell (Linux/macOS)

    Optional: NVIDIA GPU with CUDA drivers for GPU acceleration (recommended for speed)

Setup

    Place your .mp3 audio files in the same directory as the script (or adjust the glob pattern in the script if needed).

    Make sure the script is executable:

    chmod +x Auto_Whisper.sh

    (Optional) Edit the script to customize:

        Output folder (OUT_DIR)

        Audio file pattern (currently ./*.mp3)

        Whisper model (e.g., small, base, tiny)

        Language (default is English)

        Device (cuda for GPU, cpu for CPU-only)

Usage

Run the script in the directory with your audio files:

./Auto_Whisper.sh

The script will:

    Scan for all .mp3 files

    Skip files already transcribed (checking for existing transcript files)

    Transcribe new files with Whisper

    Save transcripts to the output folder

    Show real-time progress and estimated time remaining

Customization

Edit these parts inside the script:

OUT_DIR="./output"            # Output directory for transcripts
ALL_FILES=(./*.mp3)           # Audio file pattern to process
whisper "$FILE" --language English --model small --output_dir "$OUT_DIR" --device cuda
                             # Whisper command options

Troubleshooting

    If Whisper fails with an error about the model name, check available models and update --model accordingly.

    If running without GPU, change --device cuda to --device cpu or remove the flag.

    Ensure ffmpeg is installed as Whisper depends on it for audio processing.

License

This script is provided as-is under the MIT License. Modify and use freely.
