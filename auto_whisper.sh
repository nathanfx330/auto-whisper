#!/bin/bash

# ======= Configurable variables (change as needed) =======

# Output directory for transcriptions
OUT_DIR="./output"   # <-- Change this if you want transcripts somewhere else

mkdir -p "$OUT_DIR"

# Enable nullglob so that the glob pattern returns empty if no files match
shopt -s nullglob

# Find all audio files to process (currently mp3 only)
ALL_FILES=(./*.mp3)  # <-- Change the file extension or add more patterns if needed
TOTAL=${#ALL_FILES[@]}

# ======= Processing status =======
PROCESSED=0
for FILE in "${ALL_FILES[@]}"; do
    BASENAME="$(basename "$FILE" .mp3)"
    if [[ -f "$OUT_DIR/$BASENAME.txt" || -f "$OUT_DIR/$BASENAME.srt" || -f "$OUT_DIR/$BASENAME.vtt" ]]; then
        ((PROCESSED++))
    fi
done

TO_PROCESS=$((TOTAL - PROCESSED))

echo "🎧 Detected $TOTAL .mp3 file(s)"
echo "✅ Already processed: $PROCESSED"
echo "⏳ Remaining to process: $TO_PROCESS"
echo

# ======= Timer and progress tracking =======
START_TIME=$(date +%s)
FILES_DONE=0

# ======= Main transcription loop =======
for FILE in "${ALL_FILES[@]}"; do
    BASENAME="$(basename "$FILE" .mp3)"

    # Skip files already processed (by checking output files)
    if [[ -f "$OUT_DIR/$BASENAME.txt" || -f "$OUT_DIR/$BASENAME.srt" || -f "$OUT_DIR/$BASENAME.vtt" ]]; then
        continue
    fi

    echo "➡️  [$((PROCESSED + FILES_DONE + 1))/$TOTAL] Transcribing: $FILE"

    FILE_START=$(date +%s)

    # ======= Whisper command - customize model, language, device here =======
    whisper "$FILE" --language English --model small --output_dir "$OUT_DIR" --device cuda
    # Change '--model small' to 'base', 'tiny', or others supported by your installation
    # Change '--device cuda' to '--device cpu' if you want CPU-only processing

    EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
        echo "❌ Whisper failed on $FILE (exit code $EXIT_CODE). Exiting..."
        exit $EXIT_CODE
    fi

    FILE_END=$(date +%s)
    ((FILES_DONE++))

    # ======= ETA and progress calculation =======
    ELAPSED=$((FILE_END - START_TIME))
    AVG_TIME_PER_FILE=$(($ELAPSED / $FILES_DONE))
    REMAINING_FILES=$((TOTAL - PROCESSED - FILES_DONE))
    ESTIMATED_REMAINING=$((AVG_TIME_PER_FILE * REMAINING_FILES))

    echo "✅ Done: $FILE"
    echo "📊 Progress: $((PROCESSED + FILES_DONE)) / $TOTAL"
    echo "⏱️  Avg/file: ${AVG_TIME_PER_FILE}s | ETA: ~${ESTIMATED_REMAINING}s (~$((ESTIMATED_REMAINING / 60))m)"
    echo
done

END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
echo "🎉 All files processed in ${TOTAL_TIME}s (~$((TOTAL_TIME / 60))m)"
