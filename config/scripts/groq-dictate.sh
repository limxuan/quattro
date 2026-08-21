#!/usr/bin/env bash
# Groq Cloud Dictation using whisper-large-v3

PIDFILE="/tmp/groq_dictate.pid"
AUDIOFILE="/tmp/groq_dictate.wav"
API_KEY_FILE="$HOME/.config/groq/api_key"

if [ -f "$PIDFILE" ]; then
  # Stop recording
  PID=$(cat "$PIDFILE")
  rm -f "$PIDFILE"
  kill "$PID" 2>/dev/null || true
  notify-send -u low "󰔟    Transcribing (Groq AI)..." -t 2000

  if [ -f "$AUDIOFILE" ] && [ -s "$AUDIOFILE" ]; then
    GROQ_KEY="${GROQ_API_KEY:-$(cat "$API_KEY_FILE" 2>/dev/null)}"
    if [ -z "$GROQ_KEY" ]; then
      notify-send -u critical "Groq API Key Missing" "Please save your API key in ~/.config/groq/api_key" -t 8000
      exit 1
    fi

    TEXT=$(curl -s -X POST "https://api.groq.com/openai/v1/audio/transcriptions" \
      -H "Authorization: Bearer ${GROQ_KEY}" \
      -H "Content-Type: multipart/form-data" \
      -F "file=@${AUDIOFILE}" \
      -F "model=whisper-large-v3" \
      -F "language=en" \
      -F "response_format=text")

    if [ -n "$TEXT" ]; then
      CLEAN_TEXT=$(echo "$TEXT" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
      if [ -n "$CLEAN_TEXT" ]; then
        wtype "$CLEAN_TEXT "
      fi
    fi
    rm -f "$AUDIOFILE"
  fi
else
  # Start recording (PipeWire native pw-record)
  rm -f "$AUDIOFILE"
  notify-send -u low "󰍬    Recording (Groq AI)..." -t 2000
  pw-record --format=s16 --rate=16000 "$AUDIOFILE" &
  echo $! > "$PIDFILE"
fi
