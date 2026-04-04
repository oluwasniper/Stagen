import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { ScanScreen } from "../screens/ScanScreen";

export const ScanFeatureScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneX = spring({ fps, frame, config: { damping: 20, stiffness: 70 }, from: -280, to: 0, delay: 5 });
  const textOpacity = interpolate(frame, [18, 42], [0, 1], { extrapolateRight: "clamp" });
  const textX = interpolate(frame, [18, 42], [32, 0], { extrapolateRight: "clamp" });

  // Scan line sweeps top → bottom continuously
  const scanProgress = (frame % (fps * 2)) / (fps * 2);

  // At frame 75, show "detected" state
  const detected = frame >= 75;
  const resultOpacity = interpolate(frame, [75, 92], [0, 1], { extrapolateRight: "clamp" });
  const resultScale = spring({ fps, frame, config: { damping: 18, stiffness: 120 }, from: 0.85, to: 1, delay: 75 });

  const PHONE_SCALE = 0.84;

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        background: BRAND.bg,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: BRAND.fontFamily,
        overflow: "hidden",
        position: "relative",
      }}
    >
      {/* Glow */}
      <div style={{ position: "absolute", width: 500, height: 700, borderRadius: "50%", background: `radial-gradient(ellipse, rgba(253,182,35,0.07) 0%, transparent 70%)`, left: 100, top: "50%", transform: "translateY(-50%)", pointerEvents: "none" }} />

      {/* Phone */}
      <div style={{ transform: `translateX(${phoneX}px)`, flexShrink: 0 }}>
        <PhoneFrame scale={PHONE_SCALE}>
          <ScanScreen scale={PHONE_SCALE} scanProgress={scanProgress} detected={detected} />
        </PhoneFrame>
      </div>

      {/* Copy */}
      <div style={{ marginLeft: 72, maxWidth: 480, opacity: textOpacity, transform: `translateX(${textX}px)` }}>
        <div style={{ fontSize: 12, fontWeight: 600, color: BRAND.primary, letterSpacing: 3, textTransform: "uppercase", marginBottom: 12 }}>
          Feature 01
        </div>
        <div style={{ fontSize: 56, fontWeight: 700, color: BRAND.textPrimary, lineHeight: 1.05, letterSpacing: -1 }}>
          Instant<br />QR Scanning
        </div>
        <div style={{ fontSize: 17, color: BRAND.textMuted, marginTop: 18, lineHeight: 1.65 }}>
          Point your camera at any QR code and get results in milliseconds. URLs, contacts, Wi-Fi, and more — all decoded on the spot.
        </div>

        <div style={{ marginTop: 28, display: "flex", flexDirection: "column", gap: 12 }}>
          {[
            "Camera + gallery image upload",
            "Smart content type detection",
            "One-tap open, copy, or share",
          ].map((f, i) => {
            const op = interpolate(frame, [42 + i * 12, 58 + i * 12], [0, 1], { extrapolateRight: "clamp" });
            return (
              <div key={f} style={{ display: "flex", alignItems: "center", gap: 10, opacity: op }}>
                <div style={{ width: 6, height: 6, borderRadius: "50%", background: BRAND.primary, flexShrink: 0 }} />
                <div style={{ fontSize: 15, color: BRAND.textSecondary }}>{f}</div>
              </div>
            );
          })}
        </div>

        {/* Detected result callout */}
        <div
          style={{
            marginTop: 26,
            background: "rgba(51,51,51,0.84)",
            border: `1px solid rgba(253,182,35,0.3)`,
            borderRadius: 14,
            padding: "14px 18px",
            opacity: resultOpacity,
            transform: `scale(${resultScale})`,
            transformOrigin: "left center",
          }}
        >
          <div style={{ fontSize: 11, color: BRAND.primary, fontWeight: 600, letterSpacing: 0.5, marginBottom: 5 }}>SCANNED RESULT</div>
          <div style={{ fontSize: 14, color: BRAND.textPrimary, fontWeight: 500 }}>
            🌐 scagen.app
          </div>
          <div style={{ fontSize: 12, color: BRAND.textMuted, marginTop: 4 }}>Tap to open in browser →</div>
        </div>
      </div>
    </div>
  );
};
