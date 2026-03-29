import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

export const OutroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const mainScale = spring({ fps, frame, config: { damping: 20, stiffness: 60 }, from: 0.85, to: 1, delay: 0 });
  const mainOpacity = interpolate(frame, [0, 18], [0, 1], { extrapolateRight: "clamp" });

  // CTA pulse — subtle breathing
  const pulse = 1 + 0.035 * Math.sin((frame / fps) * Math.PI * 2.2);

  // Fade out at end
  const endFade = interpolate(frame, [90, 110], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  const btnOpacity = interpolate(frame, [35, 55], [0, 1], { extrapolateRight: "clamp" });
  const btn2Opacity = interpolate(frame, [48, 68], [0, 1], { extrapolateRight: "clamp" });
  const urlOpacity = interpolate(frame, [65, 80], [0, 1], { extrapolateRight: "clamp" });

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        background: BRAND.bg,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: BRAND.fontFamily,
        overflow: "hidden",
        opacity: endFade,
        position: "relative",
      }}
    >
      {/* Glow */}
      <div
        style={{
          position: "absolute",
          width: 700,
          height: 700,
          borderRadius: "50%",
          background: `radial-gradient(circle, rgba(253,182,35,0.1) 0%, transparent 65%)`,
          pointerEvents: "none",
        }}
      />

      <div
        style={{
          transform: `scale(${mainScale})`,
          opacity: mainOpacity,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 0,
        }}
      >
        {/* Real icon */}
        <Img
          src={staticFile("icon.png")}
          style={{
            width: 120,
            height: 120,
            borderRadius: 28,
            boxShadow: `0 12px 40px rgba(253,182,35,0.3)`,
            marginBottom: 24,
          }}
        />

        <div
          style={{
            fontSize: 80,
            fontWeight: 700,
            color: BRAND.textPrimary,
            letterSpacing: -2,
            lineHeight: 1,
            marginBottom: 14,
          }}
        >
          Scagen
        </div>

        <div
          style={{
            fontSize: 20,
            color: BRAND.textMuted,
            textAlign: "center",
            maxWidth: 420,
            lineHeight: 1.55,
            marginBottom: 36,
          }}
        >
          Free. Open source. Your QR codes, your way.
        </div>

        {/* CTA buttons */}
        <div style={{ display: "flex", gap: 16, marginBottom: 20 }}>
          <div
            style={{
              opacity: btnOpacity,
              background: BRAND.primary,
              borderRadius: 14,
              padding: "14px 30px",
              fontSize: 16,
              fontWeight: 700,
              color: "#1A1A1A",
              boxShadow: `0 8px 24px rgba(253,182,35,0.4)`,
              transform: `scale(${pulse})`,
              display: "flex",
              alignItems: "center",
              gap: 8,
            }}
          >
            ⭐ Star on GitHub
          </div>
          <div
            style={{
              opacity: btn2Opacity,
              background: BRAND.bgCard,
              border: "1px solid rgba(255,255,255,0.1)",
              borderRadius: 14,
              padding: "14px 30px",
              fontSize: 16,
              fontWeight: 600,
              color: BRAND.textPrimary,
              display: "flex",
              alignItems: "center",
              gap: 8,
            }}
          >
            📲 Download Free
          </div>
        </div>

        <div
          style={{
            opacity: urlOpacity,
            fontSize: 14,
            color: BRAND.textMuted,
            letterSpacing: 0.3,
          }}
        >
          scagen.app
        </div>
      </div>
    </div>
  );
};
