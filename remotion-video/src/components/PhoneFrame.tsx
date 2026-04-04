import React from "react";
import { BRAND } from "../brand";

interface PhoneFrameProps {
  children: React.ReactNode;
  scale?: number;
}

export const PhoneFrame: React.FC<PhoneFrameProps> = ({ children, scale = 1 }) => {
  const w = 390;
  const h = 844;

  return (
    <div
      style={{
        width: w * scale,
        height: h * scale,
        borderRadius: 52 * scale,
        background: "#0a0a0a",
        boxShadow: `
          0 ${40 * scale}px ${100 * scale}px rgba(0,0,0,0.8),
          0 0 0 ${2 * scale}px #2a2a2a,
          inset 0 0 0 ${1 * scale}px #444
        `,
        overflow: "hidden",
        position: "relative",
        flexShrink: 0,
      }}
    >
      {/* Dynamic island */}
      <div
        style={{
          position: "absolute",
          top: 14 * scale,
          left: "50%",
          transform: "translateX(-50%)",
          width: 126 * scale,
          height: 37 * scale,
          background: "#0a0a0a",
          borderRadius: 20 * scale,
          zIndex: 10,
        }}
      />
      {/* Screen */}
      <div
        style={{
          width: "100%",
          height: "100%",
          borderRadius: 52 * scale,
          overflow: "hidden",
          background: BRAND.bg,
        }}
      >
        {children}
      </div>
    </div>
  );
};
