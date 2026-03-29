import React from "react";
import { useCurrentFrame, interpolate, spring, useVideoConfig } from "remotion";
import { BRAND } from "../brand";

// Each caption: [startFrame, endFrame, text]
// Timed to the ~35s narration at 30fps.
// Adjust start/end frames after regenerating audio to match exact TTS timing.
export const CAPTION_CUES: [number, number, string][] = [
  [10,  60,  "You just saw a QR code."],
  [62,  100, "Most apps make it complicated."],
  [102, 138, "Scagen doesn't."],
  [155, 215, "Scans instantly — no signup, no ads."],
  [230, 280, "Create 15+ types of QR codes."],
  [285, 340, "Websites. Wi-Fi. Contacts. Events."],
  [365, 415, "Your history. Always there."],
  [425, 470, "Four languages. Works for everyone."],
  [488, 555, "100% free and open source."],
  [570, 630, "Download today ↓"],
];

export const Captions: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const active = CAPTION_CUES.find(([s, e]) => frame >= s && frame <= e);
  if (!active) return null;

  const [start, end, text] = active;
  const mid = (start + end) / 2;
  const fadeIn = interpolate(frame, [start, start + 8], [0, 1], { extrapolateRight: "clamp" });
  const fadeOut = interpolate(frame, [end - 8, end], [1, 0], { extrapolateLeft: "clamp" });
  const opacity = Math.min(fadeIn, fadeOut);

  const scaleVal = spring({ fps, frame, config: { damping: 28, stiffness: 200 }, from: 0.92, to: 1, delay: start });

  return (
    <div
      style={{
        position: "absolute",
        bottom: 72,
        left: "50%",
        transform: `translateX(-50%) scale(${scaleVal})`,
        opacity,
        zIndex: 100,
        pointerEvents: "none",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        maxWidth: 900,
        width: "100%",
      }}
    >
      <div
        style={{
          background: "rgba(26, 26, 26, 0.82)",
          backdropFilter: "blur(12px)",
          border: `1px solid rgba(253, 182, 35, 0.25)`,
          borderRadius: 14,
          padding: "14px 28px",
          fontFamily: BRAND.fontFamily,
          fontSize: 26,
          fontWeight: 600,
          color: BRAND.textPrimary,
          letterSpacing: 0.2,
          lineHeight: 1.3,
          textAlign: "center",
          boxShadow: "0 8px 32px rgba(0,0,0,0.5)",
        }}
      >
        {text}
      </div>
    </div>
  );
};
