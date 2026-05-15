#!/bin/sh
# entrypoint.sh — cloud deployment bootstrap
set -e

CONFIG_DIR="${HOME}/.openjarvis"
CONFIG_FILE="${CONFIG_DIR}/config.toml"

# ── 1. Bootstrap config ──────────────────────────────────────────────────────
mkdir -p "$CONFIG_DIR" /tmp/openjarvis

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[boot] No user config found. Installing cloud default config..."
  cp /defaults/config.cloud.toml "$CONFIG_FILE"
fi

# ── 2. Groq support via OpenAI-compatible endpoint ───────────────────────────
# Groq speaks the OpenAI API. If GROQ_API_KEY is set, map it so the cloud
# engine picks it up through the standard OPENAI_API_KEY path.
if [ -n "$GROQ_API_KEY" ] && [ -z "$OPENAI_API_KEY" ]; then
  echo "[boot] Groq API key detected — routing through OpenAI-compat layer"
  export OPENAI_API_KEY="$GROQ_API_KEY"
  export OPENAI_BASE_URL="${OPENAI_BASE_URL:-https://api.groq.com/openai/v1}"
fi

# ── 3. Validate at least one key is present ──────────────────────────────────
if [ -z "$OPENAI_API_KEY" ] && \
   [ -z "$ANTHROPIC_API_KEY" ] && \
   [ -z "$GEMINI_API_KEY" ] && \
   [ -z "$OPENROUTER_API_KEY" ]; then
  echo ""
  echo "ERROR: No inference API key found."
  echo "Set one of: GROQ_API_KEY, OPENAI_API_KEY, ANTHROPIC_API_KEY, GEMINI_API_KEY"
  echo ""
  exit 1
fi

echo "[boot] Starting OpenJarvis..."
exec "$@"
