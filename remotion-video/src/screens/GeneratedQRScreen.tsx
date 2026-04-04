import React from "react";
import { BRAND } from "../brand";

// Real-looking QR code SVG (decorative but faithful to the style)
const QRCodeSVG: React.FC<{ size: number }> = ({ size }) => (
  <svg viewBox="0 0 200 200" width={size} height={size} style={{ display: "block" }}>
    {/* Top-left finder */}
    <rect x="10" y="10" width="55" height="55" rx="7" fill="#1A1A1A" />
    <rect x="18" y="18" width="39" height="39" fill="#F5F5F5" />
    <rect x="25" y="25" width="25" height="25" fill="#1A1A1A" />
    {/* Top-right finder */}
    <rect x="135" y="10" width="55" height="55" rx="7" fill="#1A1A1A" />
    <rect x="143" y="18" width="39" height="39" fill="#F5F5F5" />
    <rect x="150" y="25" width="25" height="25" fill="#1A1A1A" />
    {/* Bottom-left finder */}
    <rect x="10" y="135" width="55" height="55" rx="7" fill="#1A1A1A" />
    <rect x="18" y="143" width="39" height="39" fill="#F5F5F5" />
    <rect x="25" y="150" width="25" height="25" fill="#1A1A1A" />
    {/* Data modules (simplified but realistic pattern) */}
    {[
      [75,10],[83,10],[91,10],[99,10],[107,10],
      [75,18],[91,18],[107,18],
      [75,26],[83,26],[91,26],[99,26],
      [83,34],[107,34],
      [75,42],[99,42],[107,42],
      [75,50],[83,50],[91,50],
      // timing
      [75,75],[91,75],[107,75],[123,75],
      [75,83],[83,83],[107,83],
      [75,91],[91,91],[99,91],[115,91],[123,91],
      [75,99],[83,99],[115,99],
      [75,107],[91,107],[99,107],[107,107],[123,107],
      [75,115],[83,115],[107,115],[123,115],
      [75,123],[91,123],[99,123],
      // bottom right data
      [135,75],[143,75],[159,75],[167,75],
      [135,83],[151,83],[167,83],
      [143,91],[151,91],[159,91],
      [135,99],[143,99],[167,99],
      [151,107],[159,107],
      [135,115],[143,115],[151,115],[167,115],
      [135,123],[159,123],[167,123],
      // more bottom data
      [10,75],[18,75],[34,75],[42,75],
      [10,83],[26,83],[42,83],
      [10,91],[18,91],[34,91],
      [10,99],[26,99],[42,99],
      [18,107],[34,107],[42,107],
      [10,115],[18,115],[26,115],[42,115],
      [10,123],[26,123],[34,123],
    ].map(([x, y], i) => (
      <rect key={i} x={x} y={y} width="6" height="6" fill="#1A1A1A" />
    ))}
  </svg>
);

export const GeneratedQRScreen: React.FC<{ scale?: number; qrType?: string; qrData?: string }> = ({
  scale = 1,
  qrType = "Website",
  qrData = "https://scagen.app",
}) => (
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

    {/* Header */}
    <div style={{ padding: `0 ${20 * scale}px ${12 * scale}px`, display: "flex", alignItems: "center" }}>
      <div style={{ fontSize: 16 * scale, color: "rgba(255,255,255,0.5)", marginRight: 8 * scale }}>←</div>
      <div style={{ fontSize: 18 * scale, fontWeight: 600, color: BRAND.textPrimary }}>{qrType}</div>
    </div>

    <div style={{ flex: 1, padding: `0 ${20 * scale}px`, display: "flex", flexDirection: "column", gap: 14 * scale }}>
      {/* Data card */}
      <div
        style={{
          background: BRAND.bgCardAlt,
          borderRadius: 12 * scale,
          padding: `${14 * scale}px`,
          boxShadow: `0 ${8 * scale}px rgba(0,0,0,0.25)`,
        }}
      >
        <div style={{ fontSize: 13 * scale, fontWeight: 600, letterSpacing: 0.5, color: BRAND.primary, marginBottom: 4 * scale }}>
          {qrType}
        </div>
        <div
          style={{
            fontSize: 13 * scale,
            fontWeight: 400,
            lineHeight: 1.5,
            color: BRAND.textSecondary,
            overflow: "hidden",
            display: "-webkit-box",
            WebkitLineClamp: 3,
            WebkitBoxOrient: "vertical",
          } as React.CSSProperties}
        >
          {qrData}
        </div>
      </div>

      {/* QR code display */}
      <div style={{ display: "flex", justifyContent: "center" }}>
        <div
          style={{
            width: 225 * scale,
            height: 225 * scale,
            background: "rgba(245,245,245,0.92)",
            borderRadius: 16 * scale,
            border: `4px solid ${BRAND.primary}`,
            boxShadow: `0 ${6 * scale}px ${16 * scale}px rgba(0,0,0,0.3)`,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <QRCodeSVG size={190 * scale} />
        </div>
      </div>

      {/* Action buttons */}
      <div style={{ display: "flex", justifyContent: "center", gap: 20 * scale }}>
        {[
          { icon: "📋", label: "Copy" },
          { icon: "↑", label: "Share" },
        ].map((btn) => (
          <div key={btn.label} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6 * scale }}>
            <div
              style={{
                width: 54 * scale,
                height: 54 * scale,
                borderRadius: 14 * scale,
                background: BRAND.primary,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 22 * scale,
                boxShadow: `0 0 ${12 * scale}px rgba(253,182,35,0.4)`,
              }}
            >
              {btn.icon}
            </div>
            <div style={{ fontSize: 12 * scale, fontWeight: 500, color: BRAND.textSecondary }}>{btn.label}</div>
          </div>
        ))}
      </div>

      {/* Back to generate button */}
      <div
        style={{
          border: `1.5px solid ${BRAND.primary}`,
          borderRadius: 12 * scale,
          height: 52 * scale,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          gap: 8 * scale,
          color: BRAND.primary,
          fontSize: 14 * scale,
          fontWeight: 500,
        }}
      >
        <span style={{ fontSize: 18 * scale }}>⊞</span> Back to Generate
      </div>
    </div>
  </div>
);
