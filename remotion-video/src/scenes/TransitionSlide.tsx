import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate } from "remotion";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";

/** Full-screen wipe transition between scenes */
export const TransitionSlide: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();

  const half = durationInFrames / 2;
  // Slide in from right, pause, slide out to left
  const x = frame < half
    ? interpolate(frame, [0, half], [100, 0], { extrapolateRight: "clamp" })
    : interpolate(frame, [half, durationInFrames], [0, -100], { extrapolateLeft: "clamp" });

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        background: BRAND.primary,
        transform: `translateX(${x}%)`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
      }}
    >
      <Img
        src={staticFile("icon.png")}
        style={{
          width: 80,
          height: 80,
          borderRadius: 20,
          boxShadow: "0 4px 20px rgba(0,0,0,0.25)",
        }}
      />
    </div>
  );
};
