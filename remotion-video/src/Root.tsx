import React from "react";
import { Composition, Audio, staticFile, AbsoluteFill } from "remotion";
import { TransitionSeries, linearTiming, springTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { wipe } from "@remotion/transitions/wipe";
import { slide } from "@remotion/transitions/slide";
import { FPS, WIDTH, HEIGHT } from "./brand";
import { IntroScene } from "./scenes/IntroScene";
import { ScanFeatureScene } from "./scenes/ScanFeatureScene";
import { GenerateFeatureScene } from "./scenes/GenerateFeatureScene";
import { HistoryFeatureScene } from "./scenes/HistoryFeatureScene";
import { MultilingualScene } from "./scenes/MultilingualScene";
import { OutroScene } from "./scenes/OutroScene";
import { Captions } from "./components/Captions";
import { Thumbnail } from "./Thumbnail";
import { ThumbnailB } from "./ThumbnailB";
import { ScagenShort, SHORT_TOTAL } from "./short/ScagenShort";
import { SS1Scan, SS2Detected, SS3Generate, SS4QRResult, SS5History, SS6Settings } from "./store/StoreScreenshot";
import { StoreIcon } from "./store/StoreIcon";
import { FeatureGraphic } from "./store/FeatureGraphic";
import { T7_Scan, T7_Generate, T7_History, T7_Settings, T10_Scan, T10_Generate, T10_History, T10_Settings } from "./store/TabletScreenshot";

// Scene durations in frames (at 30fps) — sized to match the ~35s narration.
// Hook (0-3s) + Scan (3-10s) + Generate (10-18s) + History (18-24s) + Multi (24-29s) + Outro (29-35s)
const INTRO = 150;        // 5s  — hook + brand reveal
const SCAN = 210;         // 7s  — scanning demo, result pop
const GENERATE = 240;     // 8s  — grid cycle + QR reveal
const HISTORY = 180;      // 6s  — history list
const MULTILINGUAL = 150; // 5s  — language cards
const OUTRO = 180;        // 6s  — CTA, breathing room

// Transition durations in frames
const T_WIPE = 22;   // wipe between intro → scan
const T_SLIDE = 22;  // slide between scenes
const T_FADE = 18;   // fade into outro

const TOTAL =
  INTRO + SCAN - T_WIPE +
  GENERATE - T_SLIDE +
  HISTORY - T_SLIDE +
  MULTILINGUAL - T_SLIDE +
  OUTRO - T_FADE;

const ScagenPromoVideo: React.FC = () => (
  <>
    <Audio src={staticFile("voiceover.mp3")} volume={1} />
    <TransitionSeries>
    <TransitionSeries.Sequence durationInFrames={INTRO}>
      <IntroScene />
    </TransitionSeries.Sequence>

    {/* Wipe right-to-left: golden swipe into Scan scene */}
    <TransitionSeries.Transition
      presentation={wipe({ direction: "from-right" })}
      timing={springTiming({ durationInFrames: T_WIPE, config: { damping: 200, stiffness: 200, mass: 0.5 }, durationRestThreshold: 0.001 })}
    />

    <TransitionSeries.Sequence durationInFrames={SCAN}>
      <ScanFeatureScene />
    </TransitionSeries.Sequence>

    {/* Slide left: scene slides out while next slides in */}
    <TransitionSeries.Transition
      presentation={slide({ direction: "from-right" })}
      timing={springTiming({ durationInFrames: T_SLIDE, config: { damping: 200, stiffness: 200, mass: 0.5 }, durationRestThreshold: 0.001 })}
    />

    <TransitionSeries.Sequence durationInFrames={GENERATE}>
      <GenerateFeatureScene />
    </TransitionSeries.Sequence>

    <TransitionSeries.Transition
      presentation={slide({ direction: "from-right" })}
      timing={springTiming({ durationInFrames: T_SLIDE, config: { damping: 200, stiffness: 200, mass: 0.5 }, durationRestThreshold: 0.001 })}
    />

    <TransitionSeries.Sequence durationInFrames={HISTORY}>
      <HistoryFeatureScene />
    </TransitionSeries.Sequence>

    <TransitionSeries.Transition
      presentation={slide({ direction: "from-right" })}
      timing={springTiming({ durationInFrames: T_SLIDE, config: { damping: 200, stiffness: 200, mass: 0.5 }, durationRestThreshold: 0.001 })}
    />

    <TransitionSeries.Sequence durationInFrames={MULTILINGUAL}>
      <MultilingualScene />
    </TransitionSeries.Sequence>

    {/* Fade to outro — calm ending */}
    <TransitionSeries.Transition
      presentation={fade()}
      timing={linearTiming({ durationInFrames: T_FADE })}
    />

    <TransitionSeries.Sequence durationInFrames={OUTRO}>
      <OutroScene />
    </TransitionSeries.Sequence>
    </TransitionSeries>
    {/* Captions overlay — sits above all scenes */}
    <AbsoluteFill style={{ pointerEvents: "none" }}>
      <Captions />
    </AbsoluteFill>
  </>
);

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="ScagenPromo"
      component={ScagenPromoVideo}
      durationInFrames={TOTAL}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />
    <Composition
      id="Thumbnail"
      component={Thumbnail}
      durationInFrames={1}
      fps={30}
      width={1280}
      height={720}
    />
    <Composition
      id="ThumbnailB"
      component={ThumbnailB}
      durationInFrames={1}
      fps={30}
      width={1280}
      height={720}
    />
    <Composition
      id="ScagenShort"
      component={ScagenShort}
      durationInFrames={SHORT_TOTAL}
      fps={FPS}
      width={1080}
      height={1920}
    />

    {/* ── Google Play Store assets ── */}
    <Composition id="SS1Scan"      component={SS1Scan}      durationInFrames={1} fps={30} width={1080} height={1920} />
    <Composition id="SS2Detected"  component={SS2Detected}  durationInFrames={1} fps={30} width={1080} height={1920} />
    <Composition id="SS3Generate"  component={SS3Generate}  durationInFrames={1} fps={30} width={1080} height={1920} />
    <Composition id="SS4QRResult"  component={SS4QRResult}  durationInFrames={1} fps={30} width={1080} height={1920} />
    <Composition id="SS5History"   component={SS5History}   durationInFrames={1} fps={30} width={1080} height={1920} />
    <Composition id="SS6Settings"  component={SS6Settings}  durationInFrames={1} fps={30} width={1080} height={1920} />
    <Composition id="StoreIcon"    component={StoreIcon}    durationInFrames={1} fps={30} width={512}  height={512}  />
    <Composition id="FeatureGraphic" component={FeatureGraphic} durationInFrames={1} fps={30} width={1024} height={500} />

    {/* ── 7" tablet screenshots (1920×1200 landscape) ── */}
    <Composition id="T7-Scan"     component={T7_Scan}     durationInFrames={1} fps={30} width={1920} height={1200} />
    <Composition id="T7-Generate" component={T7_Generate} durationInFrames={1} fps={30} width={1920} height={1200} />
    <Composition id="T7-History"  component={T7_History}  durationInFrames={1} fps={30} width={1920} height={1200} />
    <Composition id="T7-Settings" component={T7_Settings} durationInFrames={1} fps={30} width={1920} height={1200} />

    {/* ── 10" tablet screenshots (2560×1600 landscape) ── */}
    <Composition id="T10-Scan"     component={T10_Scan}     durationInFrames={1} fps={30} width={2560} height={1600} />
    <Composition id="T10-Generate" component={T10_Generate} durationInFrames={1} fps={30} width={2560} height={1600} />
    <Composition id="T10-History"  component={T10_History}  durationInFrames={1} fps={30} width={2560} height={1600} />
    <Composition id="T10-Settings" component={T10_Settings} durationInFrames={1} fps={30} width={2560} height={1600} />
  </>
);
