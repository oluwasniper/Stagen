import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { GenerateScreen } from "../screens/GenerateScreen";
import { GeneratedQRScreen } from "../screens/GeneratedQRScreen";

const QR_TYPES = ["Text", "Website", "Wi-Fi", "Event", "Contact", "Business", "Location", "WhatsApp", "Email", "Twitter", "Instagram", "Telephone"];
const QR_DISPLAYED = 9;

export const GenerateFeatureScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneX = spring({ fps, frame, config: { damping: 20, stiffness: 70 }, from: 280, to: 0, delay: 5 });
  const textOpacity = interpolate(frame, [18, 42], [0, 1], { extrapolateRight: "clamp" });

  // Cycle grid highlight
  const highlightIndex = Math.floor(frame / 18) % QR_TYPES.length;
  const currentType = QR_TYPES[highlightIndex];

  // After frame 85, show the generated QR screen
  const showGenerated = frame >= 85;
  const genOpacity = interpolate(frame, [85, 100], [0, 1], { extrapolateRight: "clamp" });
  const genScale = spring({ fps, frame, config: { damping: 20, stiffness: 100 }, from: 0.9, to: 1, delay: 85 });

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
      <div style={{ position: "absolute", width: 500, height: 700, borderRadius: "50%", background: `radial-gradient(ellipse, rgba(253,182,35,0.07) 0%, transparent 70%)`, right: 100, top: "50%", transform: "translateY(-50%)", pointerEvents: "none" }} />

      {/* Left copy */}
      <div style={{ maxWidth: 480, marginRight: 72, opacity: textOpacity }}>
        <div style={{ fontSize: 12, fontWeight: 600, color: BRAND.primary, letterSpacing: 3, textTransform: "uppercase", marginBottom: 12 }}>
          Feature 02
        </div>
        <div style={{ fontSize: 56, fontWeight: 700, color: BRAND.textPrimary, lineHeight: 1.05, letterSpacing: -1 }}>
          Generate<br />Any QR Type
        </div>
        <div style={{ fontSize: 17, color: BRAND.textMuted, marginTop: 18, lineHeight: 1.65 }}>
          Create QR codes for websites, Wi-Fi networks, contacts, events, and 10+ more types — all with a beautiful, shareable result.
        </div>

        {/* Type pills */}
        <div style={{ marginTop: 24, display: "flex", flexWrap: "wrap", gap: 8 }}>
          {QR_TYPES.slice(0, QR_DISPLAYED).map((type, i) => {
            const pillOpacity = interpolate(frame, [42 + i * 4, 58 + i * 4], [0, 1], { extrapolateRight: "clamp" });
            const isActive = type === currentType;
            return (
              <div
                key={type}
                style={{
                  opacity: pillOpacity,
                  background: isActive ? BRAND.primary : "rgba(51,51,51,0.84)",
                  borderRadius: 20,
                  padding: "6px 14px",
                  fontSize: 13,
                  color: isActive ? "#1A1A1A" : BRAND.textSecondary,
                  fontWeight: isActive ? 600 : 400,
                  border: `1px solid ${isActive ? BRAND.primary : "rgba(255,255,255,0.08)"}`,
                }}
              >
                {type}
              </div>
            );
          })}
          <div style={{ opacity: interpolate(frame, [78, 88], [0, 1], { extrapolateRight: "clamp" }), padding: "6px 14px", color: BRAND.textMuted, fontSize: 13 }}}>+{QR_TYPES.length - QR_DISPLAYED} more</div>
        </div>
      </div>

      {/* Phone */}
      <div
        style={{
          transform: `translateX(${phoneX}px)`,
          flexShrink: 0,
          opacity: showGenerated ? genOpacity : 1,
          scale: showGenerated ? `${genScale}` : "1",
        }}
      >
        <PhoneFrame scale={PHONE_SCALE}>
          {showGenerated
            ? <GeneratedQRScreen scale={PHONE_SCALE} qrType={currentType} />
            : <GenerateScreen scale={PHONE_SCALE} highlightIndex={highlightIndex} />
          }
        </PhoneFrame>
      </div>
    </div>
  );
};
