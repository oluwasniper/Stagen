/**
 * Generates public/voiceover.mp3 using ElevenLabs TTS.
 * Run: node scripts/generate-voiceover.mjs
 * Requires ELEVENLABS_API_KEY in ../.env or process.env
 */

import { readFileSync, writeFileSync, existsSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const __dir = dirname(fileURLToPath(import.meta.url));
const ENV_KEY = "ELEVENLABS_API_KEY";
const MAX_ENV_VALUE_LENGTH = 512;

// Load .env from remotion-video/ or root Stagen/
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

// Narration script — ~35s, high-conversion, conversational tone.
// Structure: Hook → Problem → Solution → Features (benefit-first) → Social proof → CTA
const SCRIPT = `You just saw a QR code. What do you do?

Most apps make it complicated. Scagen doesn't.

Point your camera — it scans instantly. No signup, no ads, no nonsense. Just the result, right there.

And when you need to create one? Choose from over fifteen types. Website links, Wi-Fi passwords, contact cards, event details — Scagen handles all of it, beautifully.

Everything stays saved. Offline or online, your history is always there.

Oh, and it speaks four languages. Because good tools work for everyone.

Scagen is completely free and open source. Download it today — and if you love it, give it a star on GitHub.`;

// Voice: "Adam" — deep, warm narrator
// Voice ID: pNInz6obpgDQGcFmaJgB
const VOICE_ID = "pNInz6obpgDQGcFmaJgB";

async function generate() {
  console.log("Calling ElevenLabs API...");

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
          stability: 0.38,        // lower = more expressive, natural variation
          similarity_boost: 0.75,
          style: 0.55,            // more personality/character
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
  const out = resolve(__dir, "../public/voiceover.mp3");
  writeFileSync(out, buf);
  console.log(`✓ Saved ${buf.length} bytes → ${out}`);
}

generate().catch((err) => {
  console.error("[generate-voiceover] generate failed:", err);
  process.exit(1);
});
