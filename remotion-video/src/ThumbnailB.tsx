import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "./brand";
import { PhoneFrame } from "./components/PhoneFrame";
import { GeneratedQRScreen } from "./screens/GeneratedQRScreen";

export const ThumbnailB: React.FC = () => (
  <div
    style={{
      width: 1280,
      height: 720,
      fontFamily: BRAND.fontFamily,
      display: "flex",
      alignItems: "stretch",
      overflow: "hidden",
      position: "relative",
    }}
  >
    {/* Left half — dark with big QR visual */}
    <div style={{
      width: 580,
      background: BRAND.bg,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      position: "relative",
      flexShrink: 0,
    }}>
      {/* Glow behind phone */}
      <div style={{
        position: "absolute",
        width: 420,
        height: 420,
        borderRadius: "50%",
        background: "radial-gradient(circle, rgba(253,182,35,0.13) 0%, transparent 70%)",
        pointerEvents: "none",
      }} />
      <PhoneFrame scale={0.74}>
        <GeneratedQRScreen scale={0.74} qrType="Website" qrData="https://scagen.app" />
      </PhoneFrame>
    </div>

    {/* Diagonal divider */}
    <svg
      style={{ position: "absolute", top: 0, left: 0, width: "100%", height: "100%", pointerEvents: "none", zIndex: 3 }}
      viewBox="0 0 1280 720"
    >
      <polygon points="540,0 620,0 580,720 500,720" fill={BRAND.primary} />
    </svg>

    {/* Right half — golden background */}
    <div style={{
      flex: 1,
      background: BRAND.primary,
      display: "flex",
      flexDirection: "column",
      justifyContent: "center",
      paddingLeft: 100,
      paddingRight: 60,
      position: "relative",
      zIndex: 2,
    }}>
      {/* Top label */}
      <div style={{
        display: "inline-flex", alignItems: "center", gap: 8,
        background: "rgba(0,0,0,0.12)",
        borderRadius: 8, padding: "5px 14px",
        marginBottom: 20, alignSelf: "flex-start",
      }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: "#1A1A1A", letterSpacing: 2, textTransform: "uppercase" }}>
          Free · Open Source
        </span>
      </div>

      {/* Headline */}
      <div style={{
        fontSize: 68,
        fontWeight: 800,
        color: "#1A1A1A",
        lineHeight: 1.0,
        letterSpacing: -2,
      }}>
        Stop Paying<br />for QR Apps.
      </div>

      <div style={{
        fontSize: 21,
        color: "rgba(0,0,0,0.65)",
        marginTop: 18,
        lineHeight: 1.55,
        maxWidth: 380,
      }}>
        Scan. Generate. Share.<br />
        15+ types · Works offline · 4 languages.
      </div>

      {/* App identity */}
      <div style={{
        display: "flex", alignItems: "center", gap: 14, marginTop: 36,
        background: "rgba(0,0,0,0.1)", borderRadius: 14,
        padding: "12px 18px", alignSelf: "flex-start",
      }}>
        <Img
          src={staticFile("icon.png")}
          style={{ width: 48, height: 48, borderRadius: 12 }}
        />
        <div>
          <div style={{ fontSize: 20, fontWeight: 700, color: "#1A1A1A" }}>Scagen</div>
          <div style={{ fontSize: 13, color: "rgba(0,0,0,0.55)" }}>Android & iOS — Free Download</div>
        </div>
      </div>
    </div>
  </div>
);
