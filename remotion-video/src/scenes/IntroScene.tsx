import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { SplashScreen } from "../screens/SplashScreen";

export const IntroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const bgOpacity = interpolate(frame, [0, 15], [0, 1], { extrapolateRight: "clamp" });

  const phoneY = spring({ fps, frame, config: { damping: 18, stiffness: 80 }, from: 160, to: 0, delay: 8 });
  const phoneScale = spring({ fps, frame, config: { damping: 18, stiffness: 80 }, from: 0.7, to: 1, delay: 8 });

  const titleOpacity = interpolate(frame, [30, 55], [0, 1], { extrapolateRight: "clamp" });
  const titleY = interpolate(frame, [30, 55], [24, 0], { extrapolateRight: "clamp" });

  const PHONE_SCALE = 0.88;

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        background: BRAND.bg,
        opacity: bgOpacity,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: BRAND.fontFamily,
        overflow: "hidden",
        position: "relative",
      }}
    >
      {/* Subtle radial glow behind phone */}
      <div
        style={{
          position: "absolute",
          width: 700,
          height: 700,
          borderRadius: "50%",
          background: `radial-gradient(circle, rgba(253,182,35,0.08) 0%, transparent 65%)`,
          pointerEvents: "none",
        }}
      />

      {/* Phone */}
      <div style={{ transform: `translateY(${phoneY}px) scale(${phoneScale})`, flexShrink: 0 }}>
        <PhoneFrame scale={PHONE_SCALE}>
          <SplashScreen scale={PHONE_SCALE} />
        </PhoneFrame>
      </div>

      {/* Text block */}
      <div
        style={{
          marginLeft: 72,
          maxWidth: 500,
          opacity: titleOpacity,
          transform: `translateY(${titleY}px)`,
        }}
      >
        <div
          style={{
            fontSize: 13,
            fontWeight: 600,
            color: BRAND.primary,
            letterSpacing: 3,
            textTransform: "uppercase",
            marginBottom: 14,
          }}
        >
          Introducing
        </div>
        <div
          style={{
            fontSize: 88,
            fontWeight: 700,
            color: BRAND.textPrimary,
            lineHeight: 1,
            letterSpacing: -2,
          }}
        >
          Scagen
        </div>
        <div
          style={{
            fontSize: 22,
            color: BRAND.textMuted,
            marginTop: 16,
            fontWeight: 400,
            lineHeight: 1.5,
          }}
        >
          QR codes, beautifully done.
        </div>

        <div style={{ marginTop: 40, display: "flex", flexDirection: "column", gap: 18 }}>
          {[
            { icon: "📷", text: "Scan any QR code instantly" },
            { icon: "✨", text: "Generate 15+ types of QR codes" },
            { icon: "☁️", text: "Offline-first with cloud sync" },
            { icon: "🌍", text: "4 languages · Free & open source" },
          ].map(({ icon, text }, i) => {
            const itemOpacity = interpolate(frame, [55 + i * 12, 75 + i * 12], [0, 1], { extrapolateRight: "clamp" });
            const itemX = interpolate(frame, [55 + i * 12, 75 + i * 12], [20, 0], { extrapolateRight: "clamp" });
            return (
              <div key={text} style={{ display: "flex", alignItems: "center", gap: 14, opacity: itemOpacity, transform: `translateX(${itemX}px)` }}>
                <div
                  style={{
                    width: 42,
                    height: 42,
                    borderRadius: 12,
                    background: "rgba(253,182,35,0.12)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 20,
                    flexShrink: 0,
                    border: "1px solid rgba(253,182,35,0.2)",
                  }}
                >
                  {icon}
                </div>
                <div style={{ fontSize: 17, color: BRAND.textSecondary, fontWeight: 500 }}>{text}</div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
