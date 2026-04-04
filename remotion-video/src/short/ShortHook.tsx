import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

export const ShortHook: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const iconScale = spring({ fps, frame, config: { damping: 14, stiffness: 120 }, from: 0, to: 1, delay: 4 });
  const titleOpacity = interpolate(frame, [18, 34], [0, 1], { extrapolateRight: "clamp" });
  const titleY = interpolate(frame, [18, 34], [30, 0], { extrapolateRight: "clamp" });
  const sub1Opacity = interpolate(frame, [32, 46], [0, 1], { extrapolateRight: "clamp" });
  const sub2Opacity = interpolate(frame, [44, 58], [0, 1], { extrapolateRight: "clamp" });
  const tapOpacity = interpolate(frame, [58, 72], [0, 1], { extrapolateRight: "clamp" });
  const tapPulse = 1 + 0.06 * Math.sin((frame / fps) * Math.PI * 3);

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        background: BRAND.splashBg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: BRAND.fontFamily,
        gap: 0,
        position: "relative",
        overflow: "hidden",
      }}
    >
      {/* Background circles */}
      {[600, 900, 1200].map((s, i) => (
        <div key={i} style={{
          position: "absolute",
          width: s,
          height: s,
          borderRadius: "50%",
          border: `1px solid rgba(0,0,0,${0.06 - i * 0.015})`,
          pointerEvents: "none",
        }} />
      ))}

      {/* App icon */}
      <div style={{ transform: `scale(${iconScale})`, marginBottom: 32 }}>
        <Img
          src={staticFile("icon.png")}
          style={{ width: 160, height: 160, borderRadius: 40, boxShadow: "0 20px 60px rgba(0,0,0,0.25)" }}
        />
      </div>

      {/* Headline */}
      <div style={{
        opacity: titleOpacity,
        transform: `translateY(${titleY}px)`,
        textAlign: "center",
        marginBottom: 20,
      }}>
        <div style={{ fontSize: 72, fontWeight: 800, color: "rgba(0,0,0,0.87)", letterSpacing: -2, lineHeight: 1 }}>
          Scagen
        </div>
        <div style={{ fontSize: 26, fontWeight: 500, color: "rgba(0,0,0,0.6)", marginTop: 8 }}>
          Your free QR code app
        </div>
      </div>

      {/* Bullets */}
      <div style={{ display: "flex", flexDirection: "column", gap: 14, marginTop: 8 }}>
        {[
          { icon: "📷", text: "Scan instantly", opacity: sub1Opacity },
          { icon: "✨", text: "Generate 15+ types", opacity: sub2Opacity },
        ].map(({ icon, text, opacity }) => (
          <div key={text} style={{
            opacity,
            display: "flex", alignItems: "center", gap: 14,
            background: "rgba(0,0,0,0.08)", borderRadius: 16,
            padding: "12px 24px",
          }}>
            <span style={{ fontSize: 28 }}>{icon}</span>
            <span style={{ fontSize: 22, fontWeight: 600, color: "rgba(0,0,0,0.8)" }}>{text}</span>
          </div>
        ))}
      </div>

      {/* Swipe up hint */}
      <div style={{
        position: "absolute",
        bottom: 80,
        opacity: tapOpacity,
        transform: `scale(${tapPulse})`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 6,
      }}>
        <div style={{ fontSize: 18, color: "rgba(0,0,0,0.5)", fontWeight: 500 }}>keep watching ↓</div>
      </div>
    </div>
  );
};
