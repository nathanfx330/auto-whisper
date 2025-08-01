#!/bin/bash

# --- SCRIPT CONFIGURATION ---
# Output directory for transcriptions
OUT_DIR="./output"
# The audio file extension to look for
FILE_EXT=".mp3"
# A temporary, safe filename to use for processing
TEMP_LINK_NAME="whisper_temp_processing_file"
# --- END CONFIGURATION ---

# Create the output directory if it doesn't exist
mkdir -p "$OUT_DIR"

# Enable nullglob so that the glob pattern returns empty if no files match
shopt -s nullglob

# Find all files with the specified extension
ALL_FILES=(./*"$FILE_EXT")
TOTAL=${#ALL_FILES[@]}

# --- Cleanup function ---
# This ensures the temporary files are always removed, even if the script is cancelled (Ctrl+C)
cleanup() {
    rm -f "${TEMP_LINK_NAME}${FILE_EXT}"
    rm -f "$OUT_DIR/${TEMP_LINK_NAME}.txt"
    rm -f "$OUT_DIR/${TEMP_LINK_NAME}.srt"
    rm -f "$OUT_DIR/${TEMP_LINK_NAME}.vtt"
    rm -f "$OUT_DIR/${TEMP_LINK_NAME}.json"
}
# Trap the EXIT signal to run the cleanup function when the script ends for any reason
trap cleanup EXIT

# --- Pre-computation Step ---
PROCESSED=0
for FILE in "${ALL_FILES[@]}"; do
    BASENAME_ONLY="${FILE##*/}"
    BASENAME_NO_EXT="${BASENAME_ONLY%$FILE_EXT}"
    if [[ -f "$OUT_DIR/$BASENAME_NO_EXT.txt" || -f "$OUT_DIR/$BASENAME_NO_EXT.srt" || -f "$OUT_DIR/$BASENAME_NO_EXT.vtt" ]]; then
        ((PROCESSED++))
    fi
done

TO_PROCESS=$((TOTAL - PROCESSED))
echo "🎧 Detected $TOTAL ${FILE_EXT} file(s)"
echo "✅ Already processed: $PROCESSED"
echo "⏳ Remaining to process: $TO_PROCESS"
echo

# --- Main Processing Loop ---
START_TIME=$(date +%s)
FILES_DONE=0

for FILE in "${ALL_FILES[@]}"; do
    BASENAME_ONLY="${FILE##*/}"
    BASENAME_NO_EXT="${BASENAME_ONLY%$FILE_EXT}"

    # Skip if the final output file already exists
    if [[ -f "$OUT_DIR/$BASENAME_NO_EXT.txt" || -f "$OUT_DIR/$BASENAME_NO_EXT.srt" || -f "$OUT_DIR/$BASENAME_NO_EXT.vtt" ]]; then
        continue
    fi

    echo "➡️  [$((PROCESSED + FILES_DONE + 1))/$TOTAL] Preparing to transcribe: $FILE"

    # --- THE CORE FIX ---
    # 1. Create a safe, temporary symbolic link to the original file
    ln -s "$FILE" "${TEMP_LINK_NAME}${FILE_EXT}"

    # 2. Run whisper on the SAFE link name
    echo "    (Processing as ${TEMP_LINK_NAME}${FILE_EXT})"
    whisper "${TEMP_LINK_NAME}${FILE_EXT}" --language English --model base.en --output_dir "$OUT_DIR" --device cuda
    EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        echo "❌ Whisper failed on $FILE (exit code $EXIT_CODE). Exiting..."
        # The 'trap' will handle cleanup.
        exit $EXIT_CODE
    fi
    
    # 3. Rename whisper's output to match the ORIGINAL filename
    echo "    Renaming output files to match original..."
    for OUTPUT_EXT in txt srt vtt json; do
      if [ -f "$OUT_DIR/${TEMP_LINK_NAME}.${OUTPUT_EXT}" ]; then
        mv "$OUT_DIR/${TEMP_LINK_NAME}.${OUTPUT_EXT}" "$OUT_DIR/${BASENAME_NO_EXT}.${OUTPUT_EXT}"
      fi
    done
    # --- END OF FIX ---
    
    # 4. Cleanup the temporary symlink immediately
    rm -f "${TEMP_LINK_NAME}${FILE_EXT}"

    FILE_END=$(date +%s)
    ((FILES_DONE++))

    # --- Timing and ETA ---
    ELAPSED=$((FILE_END - START_TIME))
    if [[ $FILES_DONE -gt 0 ]]; then
        AVG_TIME_PER_FILE=$((ELAPSED / FILES_DONE))
        REMAINING_FILES=$((TOTAL - PROCESSED - FILES_DONE))
        ESTIMATED_REMAINING=$((AVG_TIME_PER_FILE * REMAINING_FILES))

        echo "✅ Done: $FILE"
        echo "📊 Progress: $((PROCESSED + FILES_DONE)) / $TOTAL"
        echo "⏱️  Avg/file: ${AVG_TIME_PER_FILE}s | ETA: ~${ESTIMATED_REMAINING}s (~$((ESTIMATED_REMAINING / 60))m)"
        echo
    fi
done

TOTAL_TIME=$((`date +%s` - START_TIME))
if [[ $FILES_DONE -gt 0 ]]; then
    echo "🎉 All new files processed in ${TOTAL_TIME}s (~$((TOTAL_TIME / 60))m)"
else
    echo "🎉 All files were already processed. Nothing to do."
fi
