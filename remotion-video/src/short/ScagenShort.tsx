import React from "react";
import { Audio, staticFile, AbsoluteFill } from "remotion";
import { TransitionSeries, springTiming, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { wipe } from "@remotion/transitions/wipe";
import { ShortHook } from "./ShortHook";
import { ShortScan } from "./ShortScan";
import { ShortGenerate } from "./ShortGenerate";
import { ShortCTA } from "./ShortCTA";
import { ShortCaptions } from "./ShortCaptions";

// 45s total @ 30fps = 1350 frames
// YouTube Shorts: 9:16, under 60s
const T = 20; // transition overlap frames

const HOOK     = 105; // 3.5s — brand reveal + hook
const SCAN     = 240; // 8s   — scan demo
const GENERATE = 270; // 9s   — generate demo + QR reveal
const CTA      = 270; // 9s   — CTA with breathing room

export const ScagenShort: React.FC = () => (
  <>
  <Audio src={staticFile("voiceover-short.mp3")} volume={1} />
  <TransitionSeries>
    <TransitionSeries.Sequence durationInFrames={HOOK}>
      <ShortHook />
    </TransitionSeries.Sequence>

    <TransitionSeries.Transition
      presentation={wipe({ direction: "from-bottom" })}
      timing={springTiming({ config: { damping: 200, stiffness: 200, mass: 0.5 }, durationRestThreshold: 0.001 })}
    />

    <TransitionSeries.Sequence durationInFrames={SCAN}>
      <ShortScan />
    </TransitionSeries.Sequence>

    <TransitionSeries.Transition
      presentation={wipe({ direction: "from-bottom" })}
      timing={springTiming({ config: { damping: 200, stiffness: 200, mass: 0.5 }, durationRestThreshold: 0.001 })}
    />

    <TransitionSeries.Sequence durationInFrames={GENERATE}>
      <ShortGenerate />
    </TransitionSeries.Sequence>

    <TransitionSeries.Transition
      presentation={fade()}
      timing={linearTiming({ durationInFrames: T })}
    />

    <TransitionSeries.Sequence durationInFrames={CTA}>
      <ShortCTA />
    </TransitionSeries.Sequence>
  </TransitionSeries>
  <AbsoluteFill style={{ pointerEvents: "none" }}>
    <ShortCaptions />
  </AbsoluteFill>
  </>
);

export const SHORT_TOTAL = HOOK + SCAN - T + GENERATE - T + CTA - T;
