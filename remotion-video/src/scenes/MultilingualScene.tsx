import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { SettingsScreen } from "../screens/SettingsScreen";

const LANGS = [
  { code: "EN", name: "English", flag: "🇺🇸", phrase: "Scan, Generate, Share" },
  { code: "ES", name: "Español", flag: "🇪🇸", phrase: "Escanear · Generar · Compartir" },
  { code: "FR", name: "Français", flag: "🇫🇷", phrase: "Scanner · Générer · Partager" },
  { code: "PT", name: "Português", flag: "🇧🇷", phrase: "Digitalizar · Gerar · Compartilhar" },
];

export const MultilingualScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneX = spring({ fps, frame, config: { damping: 20, stiffness: 70 }, from: 280, to: 0, delay: 5 });
  const textOpacity = interpolate(frame, [18, 42], [0, 1], { extrapolateRight: "clamp" });
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
      }}
    >
      {/* Left copy */}
      <div style={{ maxWidth: 480, marginRight: 72, opacity: textOpacity }}>
        <div style={{ fontSize: 12, fontWeight: 600, color: BRAND.primary, letterSpacing: 3, textTransform: "uppercase", marginBottom: 12 }}>
          Built for Everyone
        </div>
        <div style={{ fontSize: 56, fontWeight: 700, color: BRAND.textPrimary, lineHeight: 1.05, letterSpacing: -1 }}>
          4 Languages,<br />One App
        </div>
        <div style={{ fontSize: 17, color: BRAND.textMuted, marginTop: 18, lineHeight: 1.65 }}>
          Scagen speaks your language. Switch between English, Spanish, French, and Portuguese right from the settings screen.
        </div>

        {/* Language cards */}
        <div style={{ marginTop: 28, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {LANGS.map((lang, i) => {
            const cardScale = spring({ fps, frame, config: { damping: 18, stiffness: 90 }, from: 0, to: 1, delay: 42 + i * 10 });
            const cardOpacity = interpolate(frame, [42 + i * 10, 58 + i * 10], [0, 1], { extrapolateRight: "clamp" });
            const isFirst = i === 0;
            return (
              <div
                key={lang.code}
                style={{
                  transform: `scale(${cardScale})`,
                  opacity: cardOpacity,
                  background: isFirst ? BRAND.primary : BRAND.bgCard,
                  borderRadius: 16,
                  padding: "18px 16px",
                  display: "flex",
                  flexDirection: "column",
                  gap: 6,
                  border: `1px solid ${isFirst ? BRAND.primary : "rgba(255,255,255,0.06)"}`,
                  boxShadow: isFirst ? `0 8px 24px rgba(253,182,35,0.25)` : "none",
                }}
              >
                <div style={{ fontSize: 28 }}>{lang.flag}</div>
                <div style={{ fontSize: 15, fontWeight: 600, color: isFirst ? "#1A1A1A" : BRAND.textPrimary }}>{lang.name}</div>
                <div style={{ fontSize: 11, color: isFirst ? "rgba(0,0,0,0.6)" : BRAND.textMuted, lineHeight: 1.4 }}>{lang.phrase}</div>
              </div>
            );
          })}
        </div>

        <div style={{ marginTop: 20, fontSize: 14, color: BRAND.textMuted, opacity: interpolate(frame, [90, 108], [0, 1], { extrapolateRight: "clamp" }) }}>
          MIT License · Open source · Android & iOS
        </div>
      </div>

      {/* Phone showing settings */}
      <div style={{ transform: `translateX(${phoneX}px)`, flexShrink: 0 }}>
        <PhoneFrame scale={PHONE_SCALE}>
          <SettingsScreen scale={PHONE_SCALE} />
        </PhoneFrame>
      </div>
    </div>
  );
};
