import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

// Google Play hi-res icon: 512×512 PNG
// Must be: PNG, 32-bit, no transparency, rounded corners applied by Play Store itself
export const StoreIcon: React.FC = () => (
  <div
    style={{
      width: 512,
      height: 512,
      background: BRAND.primary,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      position: "relative",
      overflow: "hidden",
    }}
  >
    {/* Subtle inner gradient for depth */}
    <div
      style={{
        position: "absolute",
        inset: 0,
        background:
          "radial-gradient(ellipse 90% 80% at 50% 30%, rgba(255,255,255,0.18) 0%, transparent 60%)",
        pointerEvents: "none",
      }}
    />
    <Img
      src={staticFile("icon.png")}
      style={{ width: 512, height: 512, objectFit: "cover" }}
    />
  </div>
);
