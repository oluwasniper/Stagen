import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

type Tab = "scan" | "generate" | "history";

export const BottomNav: React.FC<{ active: Tab; scale?: number }> = ({ active, scale = 1 }) => (
  <div
    style={{
      position: "absolute",
      bottom: 0,
      left: 0,
      right: 0,
      padding: `${14 * scale}px ${28 * scale}px ${28 * scale}px`,
    }}
  >
    <div
      style={{
        height: 70 * scale,
        background: "rgba(42,42,42,0.92)",
        borderRadius: 22 * scale,
        border: "0.5px solid rgba(255,255,255,0.08)",
        boxShadow: `0 ${8 * scale}px ${24 * scale}px rgba(0,0,0,0.35)`,
        backdropFilter: "blur(20px)",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-around",
        position: "relative",
      }}
    >
      {/* Generate */}
      <NavItem icon="generateIcon.svg" label="Generate" active={active === "generate"} scale={scale} />

      {/* Center FAB — Scan */}
      <div
        style={{
          width: 68 * scale,
          height: 68 * scale,
          borderRadius: "50%",
          background: active === "scan"
            ? "linear-gradient(135deg, #FDC93A, #FDB623)"
            : "#333333",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: active === "scan"
            ? `0 0 ${16 * scale}px rgba(253,182,35,0.5)`
            : `0 ${4 * scale}px ${8 * scale}px rgba(0,0,0,0.3)`,
          position: "absolute",
          top: -20 * scale,
          left: "50%",
          transform: "translateX(-50%)",
        }}
      >
        <Img
          src={staticFile("scanIcon.svg")}
          style={{
            width: 28 * scale,
            height: 28 * scale,
            filter: active === "scan" ? "brightness(0)" : "brightness(0) invert(0.7)",
          }}
        />
      </div>

      {/* History */}
      <NavItem icon="historyIcon.svg" label="History" active={active === "history"} scale={scale} />
    </div>
  </div>
);

const NavItem: React.FC<{ icon: string; label: string; active: boolean; scale: number }> = ({
  icon, label, active, scale,
}) => (
  <div
    style={{
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 3 * scale,
      width: 80 * scale,
      position: "relative",
    }}
  >
    <Img
      src={staticFile(icon)}
      style={{
        width: 26 * scale,
        height: 26 * scale,
        filter: active
          ? "invert(80%) sepia(60%) saturate(500%) hue-rotate(5deg) brightness(1.1)"
          : "brightness(0) invert(0.54)",
        transform: `scale(${active ? 1.18 : 1})`,
        transition: "all 0.2s",
      }}
    />
    <div
      style={{
        fontSize: 11.5 * scale,
        fontWeight: active ? 600 : 400,
        color: active ? BRAND.primary : "rgba(255,255,255,0.54)",
        fontFamily: BRAND.fontFamily,
      }}
    >
      {label}
    </div>
    {active && (
      <div
        style={{
          position: "absolute",
          bottom: -8 * scale,
          width: 22 * scale,
          height: 3 * scale,
          borderRadius: 2 * scale,
          background: BRAND.primary,
          boxShadow: `0 0 ${6 * scale}px rgba(253,182,35,0.5)`,
        }}
      />
    )}
  </div>
);
