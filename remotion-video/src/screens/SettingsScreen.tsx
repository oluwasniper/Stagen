import React from "react";
import { BRAND } from "../brand";

interface RowProps {
  icon: string;
  title: string;
  subtitle: string;
  isToggle?: boolean;
  on?: boolean;
  scale: number;
}

const Row: React.FC<RowProps> = ({ icon, title, subtitle, isToggle, on, scale }) => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      gap: 12 * scale,
      padding: `${12 * scale}px ${16 * scale}px`,
      background: "rgba(51,51,51,0.84)",
      borderRadius: 12 * scale,
    }}
  >
    <div style={{ fontSize: 22 * scale, width: 32 * scale, textAlign: "center" }}>{icon}</div>
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ fontSize: 14 * scale, fontWeight: 500, color: BRAND.textPrimary }}>{title}</div>
      <div style={{ fontSize: 11 * scale, color: BRAND.textMuted, marginTop: 1 * scale }}>{subtitle}</div>
    </div>
    {isToggle ? (
      <div
        style={{
          width: 44 * scale,
          height: 24 * scale,
          borderRadius: 12 * scale,
          background: on ? BRAND.primary : "rgba(255,255,255,0.15)",
          position: "relative",
          flexShrink: 0,
        }}
      >
        <div
          style={{
            position: "absolute",
            width: 20 * scale,
            height: 20 * scale,
            borderRadius: "50%",
            background: on ? "#1A1A1A" : "white",
            top: 2 * scale,
            left: on ? 22 * scale : 2 * scale,
            boxShadow: "0 1px 3px rgba(0,0,0,0.4)",
          }}
        />
      </div>
    ) : (
      <div style={{ color: "rgba(255,255,255,0.25)", fontSize: 16 * scale }}>›</div>
    )}
  </div>
);

const SectionHeader: React.FC<{ label: string; scale: number }> = ({ label, scale }) => (
  <div
    style={{
      fontSize: 26 * scale,
      fontWeight: 400,
      color: BRAND.primary,
      paddingTop: 8 * scale,
      paddingBottom: 8 * scale,
    }}
  >
    {label}
  </div>
);

export const SettingsScreen: React.FC<{ scale?: number }> = ({ scale = 1 }) => (
  <div
    style={{
      width: "100%",
      height: "100%",
      background: BRAND.bg,
      display: "flex",
      flexDirection: "column",
      fontFamily: BRAND.fontFamily,
      overflowY: "hidden",
    }}
  >
    <div style={{ height: 60 * scale }} />
    <div style={{ padding: `0 ${20 * scale}px`, display: "flex", flexDirection: "column", gap: 6 * scale, overflowY: "hidden" }}>
      <SectionHeader label="Settings" scale={scale} />
      <Row icon="📳" title="Vibrate" subtitle="Vibrate on successful scan" isToggle on={true} scale={scale} />
      <Row icon="🔔" title="Beep" subtitle="Play sound on successful scan" isToggle on={false} scale={scale} />
      <Row icon="🌐" title="Change Language" subtitle="English" scale={scale} />

      <SectionHeader label="Privacy" scale={scale} />
      <Row icon="📊" title="Share Analytics" subtitle="Help improve the app" isToggle on={true} scale={scale} />

      <SectionHeader label="Support" scale={scale} />
      <Row icon="⭐" title="Rate Us" subtitle="Love the app? Leave a review" scale={scale} />
      <Row icon="↑" title="Share" subtitle="Share Scagen with friends" scale={scale} />
      <Row icon="🔒" title="Privacy Policy" subtitle="Read our privacy policy" scale={scale} />
    </div>
  </div>
);
