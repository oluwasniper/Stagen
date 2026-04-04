import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "./brand";
import { PhoneFrame } from "./components/PhoneFrame";
import { ScanScreen } from "./screens/ScanScreen";
import { GenerateScreen } from "./screens/GenerateScreen";

export const Thumbnail: React.FC = () => (
  <div
    style={{
      width: 1280,
      height: 720,
      background: BRAND.bg,
      fontFamily: BRAND.fontFamily,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      overflow: "hidden",
      position: "relative",
    }}
  >
    {/* Background radial glow */}
    <div style={{
      position: "absolute", inset: 0,
      background: "radial-gradient(ellipse 80% 80% at 50% 50%, rgba(253,182,35,0.07) 0%, transparent 70%)",
      pointerEvents: "none",
    }} />

    {/* Left bold text block */}
    <div style={{ flex: 1, paddingLeft: 72, paddingRight: 32, zIndex: 2 }}>
      {/* FREE badge */}
      <div style={{
        display: "inline-flex", alignItems: "center", gap: 8,
        background: BRAND.primary, borderRadius: 8,
        padding: "5px 14px", marginBottom: 22,
      }}>
        <span style={{ fontSize: 13, fontWeight: 700, color: "#1A1A1A", letterSpacing: 1.5, textTransform: "uppercase" }}>
          100% Free · Open Source
        </span>
      </div>

      {/* Headline */}
      <div style={{
        fontSize: 74,
        fontWeight: 800,
        color: BRAND.textPrimary,
        lineHeight: 1.0,
        letterSpacing: -2,
      }}>
        The QR App<br />
        <span style={{ color: BRAND.primary }}>You've Been</span><br />
        Waiting For
      </div>

      {/* Sub */}
      <div style={{
        fontSize: 22,
        color: BRAND.textMuted,
        marginTop: 20,
        lineHeight: 1.5,
        maxWidth: 420,
      }}>
        Scan · Generate · Share<br />
        15+ types · Offline · 4 Languages
      </div>

      {/* App icon + name row */}
      <div style={{
        display: "flex", alignItems: "center", gap: 14, marginTop: 32,
      }}>
        <Img
          src={staticFile("icon.png")}
          style={{ width: 52, height: 52, borderRadius: 13, boxShadow: `0 4px 14px rgba(253,182,35,0.35)` }}
        />
        <div>
          <div style={{ fontSize: 22, fontWeight: 700, color: BRAND.textPrimary }}>Scagen</div>
          <div style={{ fontSize: 13, color: BRAND.textMuted }}>Android & iOS</div>
        </div>
      </div>
    </div>

    {/* Right: two phones stacked/overlapping */}
    <div style={{
      position: "relative",
      width: 520,
      height: 660,
      flexShrink: 0,
      marginRight: 40,
    }}>
      {/* Back phone — generate screen, rotated slightly */}
      <div style={{
        position: "absolute",
        top: 40,
        right: 0,
        transform: "rotate(6deg) scale(0.82)",
        transformOrigin: "bottom right",
        filter: "drop-shadow(0 20px 40px rgba(0,0,0,0.6))",
        opacity: 0.85,
        zIndex: 1,
      }}>
        <PhoneFrame scale={0.72}>
          <GenerateScreen scale={0.72} highlightIndex={1} />
        </PhoneFrame>
      </div>

      {/* Front phone — scan screen, straight */}
      <div style={{
        position: "absolute",
        bottom: 0,
        left: 0,
        filter: "drop-shadow(0 30px 60px rgba(0,0,0,0.7))",
        zIndex: 2,
      }}>
        <PhoneFrame scale={0.76}>
          <ScanScreen scale={0.76} scanProgress={0.45} detected={false} />
        </PhoneFrame>
      </div>
    </div>
  </div>
);
