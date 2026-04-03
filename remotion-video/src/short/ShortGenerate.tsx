import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { GenerateScreen } from "../screens/GenerateScreen";
import { GeneratedQRScreen } from "../screens/GeneratedQRScreen";

export const ShortGenerate: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneScale = spring({ fps, frame, config: { damping: 16, stiffness: 90 }, from: 0.7, to: 1, delay: 4 });
  const phoneOpacity = interpolate(frame, [4, 18], [0, 1], { extrapolateRight: "clamp" });
  const labelOpacity = interpolate(frame, [18, 34], [0, 1], { extrapolateRight: "clamp" });
  const labelY = interpolate(frame, [18, 34], [20, 0], { extrapolateRight: "clamp" });
  const subOpacity = interpolate(frame, [32, 48], [0, 1], { extrapolateRight: "clamp" });

  const highlightIndex = Math.floor(frame / 14) % 8;
  const showGenerated = frame >= 60;
  const genOpacity = interpolate(frame, [60, 72], [0, 1], { extrapolateRight: "clamp" });
  const genScale = spring({ fps, frame, config: { damping: 18, stiffness: 110 }, from: 0.88, to: 1, delay: 60 });

  const PHONE_SCALE = 0.72;

  return (
    <div style={{
      width: "100%",
      height: "100%",
      background: BRAND.bg,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: BRAND.fontFamily,
      gap: 40,
      position: "relative",
      overflow: "hidden",
    }}>
      <div style={{
        position: "absolute",
        width: 600, height: 600, borderRadius: "50%",
        background: `radial-gradient(circle, rgba(253,182,35,0.1) 0%, transparent 65%)`,
        pointerEvents: "none",
      }} />

      {/* Top label */}
      <div style={{
        opacity: labelOpacity,
        transform: `translateY(${labelY}px)`,
        textAlign: "center",
        zIndex: 2,
      }}>
        <div style={{ fontSize: 13, fontWeight: 700, color: BRAND.primary, letterSpacing: 3, textTransform: "uppercase", marginBottom: 10 }}>
          Feature 02
        </div>
        <div style={{ fontSize: 56, fontWeight: 800, color: BRAND.textPrimary, letterSpacing: -1, lineHeight: 1.05 }}>
          Generate Any Type
        </div>
      </div>

      {/* Phone */}
      <div style={{
        transform: `scale(${showGenerated ? genScale : phoneScale})`,
        opacity: showGenerated ? genOpacity : phoneOpacity,
        zIndex: 2,
      }}>
        <PhoneFrame scale={PHONE_SCALE}>
          {showGenerated
            ? <GeneratedQRScreen scale={PHONE_SCALE} qrType="Website" />
            : <GenerateScreen scale={PHONE_SCALE} highlightIndex={highlightIndex} />
          }
        </PhoneFrame>
      </div>

      {/* Type pills */}
      <div style={{ opacity: subOpacity, display: "flex", flexWrap: "wrap", gap: 10, justifyContent: "center", maxWidth: 700, zIndex: 2 }}>
        {["Website", "Wi-Fi", "Contact", "Event", "Location", "+10 more"].map((t, i) => (
          <div key={t} style={{
            background: i === 5 ? "transparent" : "rgba(51,51,51,0.9)",
            border: i === 5 ? "none" : "1px solid rgba(255,255,255,0.08)",
            borderRadius: 20,
            padding: "8px 18px",
            fontSize: 18,
            color: i === 5 ? BRAND.textMuted : BRAND.textSecondary,
            fontWeight: 500,
          }}>{t}</div>
        ))}
      </div>
    </div>
  );
};
