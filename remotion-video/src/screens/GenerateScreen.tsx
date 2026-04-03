import React from "react";
import { BRAND } from "../brand";
import { BottomNav } from "../components/BottomNav";

// QR types from generate_home_screen.dart
const QR_TYPES = [
  { icon: "📝", label: "Text" },
  { icon: "🌐", label: "Website" },
  { icon: "📶", label: "Wi-Fi" },
  { icon: "📅", label: "Event" },
  { icon: "👤", label: "Contact" },
  { icon: "💼", label: "Business" },
  { icon: "📍", label: "Location" },
  { icon: "💬", label: "WhatsApp" },
  { icon: "✉️", label: "Email" },
  { icon: "🐦", label: "Twitter" },
  { icon: "📸", label: "Instagram" },
  { icon: "📞", label: "Telephone" },
];

export const GenerateScreen: React.FC<{ scale?: number; highlightIndex?: number }> = ({
  scale = 1,
  highlightIndex = 0,
}) => (
  <div
    style={{
      width: "100%",
      height: "100%",
      background: BRAND.bg,
      display: "flex",
      flexDirection: "column",
      fontFamily: BRAND.fontFamily,
    }}
  >
    {/* Top safe area + header */}
    <div style={{ height: 60 * scale }} />
    <div
      style={{
        padding: `${0}px ${20 * scale}px ${16 * scale}px`,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
      }}
    >
      <div style={{ fontSize: 22 * scale, fontWeight: 600, color: BRAND.textPrimary }}>
        Generate QR
      </div>
      <div style={{ fontSize: 22 * scale, color: BRAND.textMuted }}>⚙️</div>
    </div>

    {/* 3-column grid */}
    <div
      style={{
        display: "grid",
        gridTemplateColumns: "1fr 1fr 1fr",
        gap: 10 * scale,
        padding: `${0}px ${20 * scale}px`,
        flex: 1,
        overflowY: "hidden",
      }}
    >
      {QR_TYPES.map((type, i) => {
        const isActive = i === highlightIndex;
        return (
          <div
            key={type.label}
            style={{
              background: isActive ? BRAND.primary : BRAND.bgCard,
              borderRadius: 14 * scale,
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              justifyContent: "center",
              gap: 6 * scale,
              padding: `${14 * scale}px ${6 * scale}px`,
              boxShadow: isActive ? `0 4px 14px rgba(253,182,35,0.35)` : "none",
            }}
          >
            <div style={{ fontSize: 22 * scale }}>{type.icon}</div>
            <div
              style={{
                fontSize: 11 * scale,
                fontWeight: 500,
                color: isActive ? "#1A1A1A" : BRAND.textSecondary,
                textAlign: "center",
              }}
            >
              {type.label}
            </div>
          </div>
        );
      })}
    </div>

    <div style={{ height: 100 * scale }} />
    <BottomNav active="generate" scale={scale} />
  </div>
);
