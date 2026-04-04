import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

export const ShortCTA: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const iconScale = spring({ fps, frame, config: { damping: 14, stiffness: 100 }, from: 0, to: 1, delay: 4 });
  const titleOpacity = interpolate(frame, [18, 34], [0, 1], { extrapolateRight: "clamp" });
  const titleY = interpolate(frame, [18, 34], [24, 0], { extrapolateRight: "clamp" });
  const subOpacity = interpolate(frame, [32, 48], [0, 1], { extrapolateRight: "clamp" });
  const btn1Opacity = interpolate(frame, [46, 60], [0, 1], { extrapolateRight: "clamp" });
  const btn2Opacity = interpolate(frame, [58, 72], [0, 1], { extrapolateRight: "clamp" });
  const urlOpacity = interpolate(frame, [70, 84], [0, 1], { extrapolateRight: "clamp" });
  const btnPulse = 1 + 0.04 * Math.sin((frame / fps) * Math.PI * 2.5);

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
      gap: 28,
      position: "relative",
      overflow: "hidden",
    }}>
      {/* Glow */}
      <div style={{
        position: "absolute",
        width: 700, height: 700, borderRadius: "50%",
        background: `radial-gradient(circle, rgba(253,182,35,0.12) 0%, transparent 65%)`,
        pointerEvents: "none",
      }} />

      {/* Icon */}
      <div style={{ transform: `scale(${iconScale})` }}>
        <Img
          src={staticFile("icon.png")}
          style={{ width: 140, height: 140, borderRadius: 36, boxShadow: `0 16px 50px rgba(253,182,35,0.35)` }}
        />
      </div>

      {/* Headline */}
      <div style={{
        opacity: titleOpacity,
        transform: `translateY(${titleY}px)`,
        textAlign: "center",
      }}>
        <div style={{ fontSize: 72, fontWeight: 800, color: BRAND.textPrimary, letterSpacing: -2, lineHeight: 1 }}>
          Free.<br />Open Source.
        </div>
      </div>

      {/* Sub */}
      <div style={{ opacity: subOpacity, fontSize: 24, color: BRAND.textMuted, textAlign: "center", maxWidth: 560, lineHeight: 1.5 }}>
        No ads. No subscriptions.<br />Just a great QR app.
      </div>

      {/* CTA buttons */}
      <div style={{ display: "flex", flexDirection: "column", gap: 14, width: 560, opacity: btn1Opacity }}>
        <div style={{
          background: BRAND.primary,
          borderRadius: 18,
          padding: "18px 0",
          textAlign: "center",
          fontSize: 22,
          fontWeight: 700,
          color: "#1A1A1A",
          boxShadow: `0 8px 30px rgba(253,182,35,0.4)`,
          transform: `scale(${btnPulse})`,
        }}>
          📲 Download Free
        </div>
        <div style={{
          opacity: btn2Opacity,
          background: "rgba(51,51,51,0.9)",
          border: "1px solid rgba(255,255,255,0.1)",
          borderRadius: 18,
          padding: "18px 0",
          textAlign: "center",
          fontSize: 22,
          fontWeight: 600,
          color: BRAND.textPrimary,
        }}>
          ⭐ Star on GitHub
        </div>
      </div>

      {/* URL */}
      <div style={{
        opacity: urlOpacity,
        fontSize: 16,
        color: BRAND.textMuted,
        letterSpacing: 0.3,
      }}>
        scagen.app
      </div>
    </div>
  );
};
