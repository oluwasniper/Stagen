/**
 * Generates public/voiceover-short.mp3 using ElevenLabs TTS.
 * Run: node scripts/generate-short-voiceover.mjs
 * Requires ELEVENLABS_API_KEY in ../.env or process.env
 */

import { readFileSync, writeFileSync, existsSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const __dir = dirname(fileURLToPath(import.meta.url));
const ENV_KEY = "ELEVENLABS_API_KEY";
const MAX_ENV_VALUE_LENGTH = 512;

function loadEnv() {
  const candidates = [
    resolve(__dir, "../.env"),
    resolve(__dir, "../../.env"),
  ];
  for (const p of candidates) {
    if (existsSync(p)) {
      const match = readFileSync(p, "utf8").match(
        /^ELEVENLABS_API_KEY=(.+)$/m,
      );
      const value = match?.[1]?.trim().replace(/^['"]|['"]$/g, "");
      if (value && !process.env[ENV_KEY]) {
        process.env[ENV_KEY] = value.slice(0, MAX_ENV_VALUE_LENGTH);
      }
    }
  }
}

loadEnv();

const API_KEY = process.env[ENV_KEY];
if (!API_KEY) {
  console.error(`Missing ${ENV_KEY}. Add it to .env`);
  process.exit(1);
}

// Short script — punchy, fast, ~25s
// Hook → pain point → solution → features → CTA
const SCRIPT = `Still paying for a QR code app?

Scagen is completely free. Point your camera — it scans instantly. No ads, no nonsense.

Need to create one? Website, Wi-Fi, contact, event — fifteen types, done in seconds.

Everything saved offline. Always there when you need it.

Free. Open source. Download Scagen today.`;

// Voice: Adam — deep, warm narrator
const VOICE_ID = "pNInz6obpgDQGcFmaJgB";

async function generate() {
  console.log("Calling ElevenLabs API for Short voiceover...");

  const res = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}`,
    {
      method: "POST",
      headers: {
        "xi-api-key": API_KEY,
        "Content-Type": "application/json",
        Accept: "audio/mpeg",
      },
      body: JSON.stringify({
        text: SCRIPT,
        model_id: "eleven_turbo_v2_5",
        voice_settings: {
          stability: 0.35,
          similarity_boost: 0.75,
          style: 0.6,
          use_speaker_boost: true,
        },
      }),
    }
  );

  if (!res.ok) {
    const err = await res.text();
    console.error("ElevenLabs error:", res.status, err);
    process.exit(1);
  }

  const buf = Buffer.from(await res.arrayBuffer());
  const out = resolve(__dir, "../public/voiceover-short.mp3");
  writeFileSync(out, buf);
  console.log(`✓ Saved ${buf.length} bytes → ${out}`);
}

generate().catch((err) => {
  console.error("[generate-short-voiceover] generate failed:", err);
  process.exit(1);
});
