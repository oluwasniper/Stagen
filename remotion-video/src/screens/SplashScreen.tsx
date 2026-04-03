import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

export const SplashScreen: React.FC<{ scale?: number }> = ({ scale = 1 }) => (
  <div
    style={{
      width: "100%",
      height: "100%",
      background: BRAND.splashBg,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      fontFamily: BRAND.fontFamily,
      gap: 14 * scale,
    }}
  >
    {/* Real app icon */}
    <Img
      src={staticFile("icon.png")}
      style={{
        width: 148 * scale,
        height: 148 * scale,
        borderRadius: 32 * scale,
      }}
    />
    <div
      style={{
        fontSize: 36 * scale,
        fontWeight: 600,
        color: BRAND.splashText,
        letterSpacing: 1.5,
      }}
    >
      Scagen
    </div>
    <div
      style={{
        fontSize: 13 * scale,
        fontWeight: 400,
        color: BRAND.splashSubtext,
        letterSpacing: 1.2,
      }}
    >
      Scan, Generate, Share
    </div>
  </div>
);
