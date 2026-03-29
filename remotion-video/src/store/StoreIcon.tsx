import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

// Google Play hi-res icon: 512×512 PNG
// Must be: PNG, 32-bit, no transparency, rounded corners applied by Play Store itself
const SIZE = 512;

export const StoreIcon: React.FC = () => (
  <div
    style={{
      width: SIZE,
      height: SIZE,
      background: BRAND.primary,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      position: "relative",
      overflow: "hidden",
    }}
  >
    <Img
      src={staticFile("icon.png")}
      style={{ width: SIZE, height: SIZE, objectFit: "cover" }}
    />
    {/* Subtle inner gradient for depth — rendered after Img so it paints on top */}
    <div
      style={{
        position: "absolute",
        inset: 0,
        background:
          "radial-gradient(ellipse 90% 80% at 50% 30%, rgba(255,255,255,0.18) 0%, transparent 60%)",
        pointerEvents: "none",
      }}
    />
  </div>
);
