import React from "react";
import { useCurrentFrame, interpolate, spring, useVideoConfig } from "remotion";
import { BRAND } from "../brand";

// Timed to the Short voiceover at 30fps
// Script: "Still paying for a QR code app? / Scagen is completely free. Point your camera — it scans instantly. No ads, no nonsense. / Need to create one? Website, Wi-Fi, contact, event — fifteen types, done in seconds. / Everything saved offline. Always there when you need it. / Free. Open source. Download Scagen today."
const CUES: [number, number, string][] = [
  [5,   55,  "Still paying for a QR code app?"],
  [60,  110, "Scagen is completely free."],
  [112, 165, "Point your camera — scans instantly."],
  [167, 210, "No ads. No nonsense."],
  [225, 275, "Need to create one?"],
  [277, 340, "15 types. Done in seconds."],
  [355, 410, "Everything saved offline."],
  [412, 460, "Always there when you need it."],
  [475, 520, "Free. Open source."],
  [522, 580, "Download Scagen today ↓"],
];

export const ShortCaptions: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const active = CUES.find(([s, e]) => frame >= s && frame <= e);
  if (!active) return null;

  const [start, end, text] = active;
  const fadeIn  = interpolate(frame, [start, start + 6], [0, 1], { extrapolateRight: "clamp" });
  const fadeOut = interpolate(frame, [end - 6, end],     [1, 0], { extrapolateLeft: "clamp" });
  const opacity = Math.min(fadeIn, fadeOut);
  const scaleVal = spring({ fps, frame, config: { damping: 28, stiffness: 220 }, from: 0.9, to: 1, delay: start });

  return (
    <div
      style={{
        position: "absolute",
        bottom: 160,
        left: 0,
        right: 0,
        display: "flex",
        justifyContent: "center",
        opacity,
        transform: `scale(${scaleVal})`,
        pointerEvents: "none",
        zIndex: 100,
        padding: "0 40px",
      }}
    >
      <div
        style={{
          background: "rgba(26,26,26,0.88)",
          backdropFilter: "blur(14px)",
          border: `1.5px solid rgba(253,182,35,0.3)`,
          borderRadius: 20,
          padding: "18px 36px",
          fontFamily: BRAND.fontFamily,
          fontSize: 38,
          fontWeight: 700,
          color: BRAND.textPrimary,
          textAlign: "center",
          lineHeight: 1.3,
          letterSpacing: 0.2,
          boxShadow: "0 8px 40px rgba(0,0,0,0.6)",
          maxWidth: 880,
        }}
      >
        {text}
      </div>
    </div>
  );
};
