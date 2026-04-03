import React from "react";
import { BRAND } from "../brand";
import { BottomNav } from "../components/BottomNav";

export const ScanScreen: React.FC<{ scale?: number; scanProgress?: number; detected?: boolean }> = ({
  scale = 1,
  scanProgress = 0.4,
  detected = false,
}) => {
  const scanWindowSize = 240 * scale;

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        background: "#111",
        position: "relative",
        overflow: "hidden",
        fontFamily: BRAND.fontFamily,
      }}
    >
      {/* Simulated camera feed gradient */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: "linear-gradient(180deg, #1a1a1a 0%, #0d0d0d 100%)",
        }}
      />

      {/* Dark overlay with center cutout using box-shadow trick */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -57%)",
          width: scanWindowSize,
          height: scanWindowSize,
          borderRadius: 16 * scale,
          boxShadow: `0 0 0 1000px rgba(0,0,0,${detected ? 0.25 : 0.55})`,
          zIndex: 1,
        }}
      />

      {/* Corner brackets */}
      {[
        { top: "50%", left: "50%", tx: -scanWindowSize / 2, ty: -(scanWindowSize / 2 + scanWindowSize * 0.57), rot: "0deg" },
        { top: "50%", left: "50%", tx: scanWindowSize / 2 - 28 * scale, ty: -(scanWindowSize / 2 + scanWindowSize * 0.57), rot: "90deg" },
        { top: "50%", left: "50%", tx: -scanWindowSize / 2, ty: scanWindowSize / 2 - 28 * scale - scanWindowSize * 0.57, rot: "270deg" },
        { top: "50%", left: "50%", tx: scanWindowSize / 2 - 28 * scale, ty: scanWindowSize / 2 - 28 * scale - scanWindowSize * 0.57, rot: "180deg" },
      ].map((b, i) => (
        <div
          key={i}
          style={{
            position: "absolute",
            top: b.top,
            left: b.left,
            transform: `translate(${b.tx}px, ${b.ty}px) rotate(${b.rot})`,
            width: 28 * scale,
            height: 28 * scale,
            borderTop: `3.5px solid ${detected ? BRAND.success : BRAND.primary}`,
            borderLeft: `3.5px solid ${detected ? BRAND.success : BRAND.primary}`,
            borderRadius: `${4 * scale}px 0 0 0`,
            zIndex: 2,
          }}
        />
      ))}

      {/* Scan line */}
      {!detected && (
        <div
          style={{
            position: "absolute",
            top: `calc(50% - ${scanWindowSize * 0.57}px + ${scanProgress * scanWindowSize}px)`,
            left: "50%",
            transform: `translateX(-${scanWindowSize / 2}px)`,
            width: scanWindowSize,
            height: 2,
            background: `linear-gradient(90deg, transparent, ${BRAND.primary}, ${BRAND.primary}, transparent)`,
            boxShadow: `0 0 6px ${BRAND.primary}99`,
            zIndex: 2,
          }}
        />
      )}

      {/* Top control bar */}
      <div
        style={{
          position: "absolute",
          top: 60 * scale,
          left: 20 * scale,
          right: 20 * scale,
          height: 52 * scale,
          background: "rgba(0,0,0,0.5)",
          borderRadius: 16 * scale,
          border: "0.5px solid rgba(255,255,255,0.12)",
          display: "flex",
          alignItems: "center",
          justifyContent: "space-evenly",
          zIndex: 3,
        }}
      >
        {[
          { emoji: "🖼️", label: "Gallery" },
          { emoji: "💡", label: "Torch" },
          { emoji: "🔄", label: "Flip" },
        ].map((btn, i) => (
          <React.Fragment key={btn.label}>
            {i > 0 && (
              <div style={{ width: 0.5, height: 28 * scale, background: "rgba(255,255,255,0.15)" }} />
            )}
            <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 2 * scale }}>
              <span style={{ fontSize: 18 * scale }}>{btn.emoji}</span>
              <span style={{ fontSize: 9 * scale, color: "rgba(255,255,255,0.7)" }}>{btn.label}</span>
            </div>
          </React.Fragment>
        ))}
      </div>

      {/* Hint label */}
      <div
        style={{
          position: "absolute",
          top: `calc(50% - ${scanWindowSize * 0.57}px - ${30 * scale}px)`,
          left: "50%",
          transform: "translateX(-50%)",
          background: "rgba(0,0,0,0.45)",
          borderRadius: 20 * scale,
          padding: `${9 * scale}px ${18 * scale}px`,
          zIndex: 3,
        }}
      >
        <div
          style={{
            fontSize: 14 * scale,
            fontWeight: 500,
            letterSpacing: 0.3,
            color: detected ? BRAND.success : "rgba(255,255,255,0.85)",
            whiteSpace: "nowrap",
          }}
        >
          {detected ? "✓ QR Code Detected" : "Scan"}
        </div>
      </div>

      <BottomNav active="scan" scale={scale} />
    </div>
  );
};
