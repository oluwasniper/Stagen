// Run with: node generate-voiceover.mjs
// Reads ELEVENLABS_API_KEY from the root .env file and generates public/voiceover.mp3

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// ── Load API key from root .env ───────────────────────────────────────────────
const envPath = path.resolve(__dirname, "../.env");
if (!fs.existsSync(envPath)) {
  console.error(`[generate-voiceover] .env not found at ${envPath}`);
  process.exit(1);
}
const envContent = fs.readFileSync(envPath, "utf8");
const match = envContent.match(/^ELEVENLABS_API_KEY=(.+)$/m);
if (!match) {
  console.error("ELEVENLABS_API_KEY not found in ../.env");
  process.exit(1);
}
const API_KEY = match[1].trim();

// ── Narration script (~52 words, ~23s at calm pace) ──────────────────────────
// Timed to match the 6 scenes:
//  0–5s   Intro
//  5–9s   Scan feature
//  9–14s  Generate feature
// 14–18s  History feature
// 18–22s  Multilingual
// 22–24s  Outro
const SCRIPT = `
Meet Scagen — the free, open-source QR code app that does it all.

Point your camera at any QR code for instant results. URLs, contacts, Wi-Fi — decoded in milliseconds.

Need to create one? Generate QR codes for over fifteen types, from websites to business cards, with a beautiful shareable result.

Every scan and creation is saved locally and synced to the cloud — so your history is always with you, even offline.

Available in English, Spanish, French, and Portuguese.

Scagen. Free, open source, and yours. Star it on GitHub today.
`.trim();

// ── ElevenLabs voice — "George" (professional, calm male narrator) ────────────
// Voice ID can be swapped for any voice from your ElevenLabs account
const VOICE_ID = "JBFqnCBsd6RMkjVDRZzb"; // George

async function generate() {
  console.log("Calling ElevenLabs API...");

  const response = await fetch(
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
          stability: 0.55,
          similarity_boost: 0.8,
          style: 0.1,
          use_speaker_boost: true,
        },
      }),
    }
  );

  if (!response.ok) {
    const err = await response.text();
    console.error("ElevenLabs error:", response.status, err);
    process.exit(1);
  }

  const buffer = await response.arrayBuffer();
  const outPath = path.resolve(__dirname, "public/voiceover.mp3");
  fs.writeFileSync(outPath, Buffer.from(buffer));
  console.log(`✓ Saved to ${outPath} (${(buffer.byteLength / 1024).toFixed(1)} KB)`);
}

generate().catch((err) => {
  console.error("[generate-voiceover] generate failed:", err);
  process.exit(1);
});
