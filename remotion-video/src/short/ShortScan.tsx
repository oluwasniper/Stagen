import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { ScanScreen } from "../screens/ScanScreen";

export const ShortScan: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneScale = spring({ fps, frame, config: { damping: 16, stiffness: 90 }, from: 0.7, to: 1, delay: 4 });
  const phoneOpacity = interpolate(frame, [4, 18], [0, 1], { extrapolateRight: "clamp" });

  const labelOpacity = interpolate(frame, [20, 36], [0, 1], { extrapolateRight: "clamp" });
  const labelY = interpolate(frame, [20, 36], [20, 0], { extrapolateRight: "clamp" });

  const subOpacity = interpolate(frame, [34, 50], [0, 1], { extrapolateRight: "clamp" });

  const scanProgress = (frame % (fps * 2)) / (fps * 2);
  const detectionThreshold = Math.round(fps * (55 / 30));
  const detected = frame >= detectionThreshold;

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
      {/* Glow */}
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
          Feature 01
        </div>
        <div style={{ fontSize: 56, fontWeight: 800, color: BRAND.textPrimary, letterSpacing: -1, lineHeight: 1.05 }}>
          Instant Scanning
        </div>
      </div>

      {/* Phone */}
      <div style={{
        transform: `scale(${phoneScale})`,
        opacity: phoneOpacity,
        zIndex: 2,
      }}>
        <PhoneFrame scale={PHONE_SCALE}>
          <ScanScreen scale={PHONE_SCALE} scanProgress={scanProgress} detected={detected} />
        </PhoneFrame>
      </div>

      {/* Bottom bullets */}
      <div style={{ opacity: subOpacity, display: "flex", flexDirection: "column", gap: 14, zIndex: 2, alignItems: "center" }}>
        {["Camera + gallery upload", "One-tap open or share"].map((t, i) => (
          <div key={i} style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <div style={{ width: 7, height: 7, borderRadius: "50%", background: BRAND.primary }} />
            <div style={{ fontSize: 20, color: BRAND.textSecondary, fontWeight: 500 }}>{t}</div>
          </div>
        ))}
      </div>
    </div>
  );
};
