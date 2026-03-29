import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { ScanScreen } from "../screens/ScanScreen";
import { GenerateScreen } from "../screens/GenerateScreen";

// Google Play feature graphic: 1024×500 PNG
// Shown at top of store listing. Must be impactful at small sizes.

export const FeatureGraphic: React.FC = () => (
  <div
    style={{
      width: 1024,
      height: 500,
      background: BRAND.bg,
      fontFamily: BRAND.fontFamily,
      display: "flex",
      alignItems: "center",
      position: "relative",
      overflow: "hidden",
    }}
  >
    {/* Background radial glow */}
    <div
      style={{
        position: "absolute",
        inset: 0,
        background:
          "radial-gradient(ellipse 75% 90% at 65% 50%, rgba(253,182,35,0.10) 0%, transparent 65%)",
        pointerEvents: "none",
      }}
    />

    {/* Decorative golden arc — top right */}
    <div
      style={{
        position: "absolute",
        top: -160,
        right: -160,
        width: 480,
        height: 480,
        borderRadius: "50%",
        border: "2px solid rgba(253,182,35,0.12)",
        pointerEvents: "none",
      }}
    />
    <div
      style={{
        position: "absolute",
        top: -90,
        right: -90,
        width: 340,
        height: 340,
        borderRadius: "50%",
        border: "1px solid rgba(253,182,35,0.08)",
        pointerEvents: "none",
      }}
    />

    {/* Left text block */}
    <div
      style={{
        flex: 1,
        paddingLeft: 64,
        paddingRight: 24,
        zIndex: 2,
        display: "flex",
        flexDirection: "column",
        gap: 0,
      }}
    >
      {/* Badge */}
      <div
        style={{
          display: "inline-flex",
          alignItems: "center",
          background: BRAND.primary,
          borderRadius: 8,
          padding: "5px 14px",
          marginBottom: 20,
          alignSelf: "flex-start",
        }}
      >
        <span
          style={{
            fontSize: 12,
            fontWeight: 700,
            color: "#1A1A1A",
            letterSpacing: 1.5,
            textTransform: "uppercase",
          }}
        >
          Free · Open Source
        </span>
      </div>

      {/* Headline */}
      <div
        style={{
          fontSize: 62,
          fontWeight: 800,
          color: BRAND.textPrimary,
          lineHeight: 1.0,
          letterSpacing: -2,
        }}
      >
        Scan. Generate.{" "}
        <span style={{ color: BRAND.primary }}>Share.</span>
      </div>

      {/* Sub */}
      <div
        style={{
          fontSize: 20,
          color: BRAND.textMuted,
          marginTop: 18,
          lineHeight: 1.5,
          maxWidth: 360,
        }}
      >
        15+ QR code types · Offline-first
        <br />
        Cloud sync · 4 languages
      </div>

      {/* Icon + name row */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 14,
          marginTop: 28,
        }}
      >
        <Img
          src={staticFile("icon.png")}
          style={{
            width: 52,
            height: 52,
            borderRadius: 13,
            boxShadow: `0 4px 14px rgba(253,182,35,0.35)`,
          }}
        />
        <div>
          <div
            style={{ fontSize: 22, fontWeight: 700, color: BRAND.textPrimary }}
          >
            Scagen
          </div>
          <div style={{ fontSize: 13, color: BRAND.textMuted }}>
            Android & iOS
          </div>
        </div>
      </div>
    </div>

    {/* Right: two overlapping phones */}
    <div
      style={{
        position: "relative",
        width: 420,
        height: 480,
        flexShrink: 0,
        marginRight: 32,
        zIndex: 2,
      }}
    >
      {/* Back phone — generate, rotated */}
      <div
        style={{
          position: "absolute",
          top: 30,
          right: 0,
          transform: "rotate(5deg) scale(0.78)",
          transformOrigin: "bottom right",
          filter: "drop-shadow(0 16px 36px rgba(0,0,0,0.65))",
          opacity: 0.82,
          zIndex: 1,
        }}
      >
        <PhoneFrame scale={0.58}>
          <GenerateScreen scale={0.58} highlightIndex={2} />
        </PhoneFrame>
      </div>

      {/* Front phone — scan */}
      <div
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          filter: "drop-shadow(0 24px 50px rgba(0,0,0,0.75))",
          zIndex: 2,
        }}
      >
        <PhoneFrame scale={0.62}>
          <ScanScreen scale={0.62} scanProgress={0.45} detected={false} />
        </PhoneFrame>
      </div>
    </div>
  </div>
);
