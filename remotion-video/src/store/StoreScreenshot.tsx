import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { ScanScreen } from "../screens/ScanScreen";
import { GenerateScreen } from "../screens/GenerateScreen";
import { GeneratedQRScreen } from "../screens/GeneratedQRScreen";
import { HistoryScreen } from "../screens/HistoryScreen";
import { SettingsScreen } from "../screens/SettingsScreen";

// Play Store portrait screenshots: 1080×1920
// Phone frame is 390×844; scale to fill nicely within the 1080w canvas

const W = 1080;
const H = 1920;
const PHONE_SCALE = 2.1; // 390*2.1 = 819px wide, 844*2.1 = 1772px tall — fits snugly

interface ScreenshotProps {
  headline: string;
  sub: string;
  children: React.ReactNode;
  accentTop?: boolean;
}

const ScreenshotShell: React.FC<ScreenshotProps> = ({ headline, sub, children, accentTop = false }) => (
  <div
    style={{
      width: W,
      height: H,
      background: BRAND.bg,
      fontFamily: BRAND.fontFamily,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      position: "relative",
      overflow: "hidden",
    }}
  >
    {/* Radial glow */}
    <div
      style={{
        position: "absolute",
        top: accentTop ? -200 : H * 0.2,
        left: "50%",
        transform: "translateX(-50%)",
        width: 900,
        height: 900,
        borderRadius: "50%",
        background: `radial-gradient(circle, rgba(253,182,35,0.09) 0%, transparent 65%)`,
        pointerEvents: "none",
      }}
    />

    {/* Top text block */}
    <div
      style={{
        paddingTop: 80,
        paddingBottom: 48,
        textAlign: "center",
        zIndex: 2,
        paddingLeft: 40,
        paddingRight: 40,
      }}
    >
      <div
        style={{
          fontSize: 52,
          fontWeight: 800,
          color: BRAND.textPrimary,
          lineHeight: 1.1,
          letterSpacing: -1,
        }}
      >
        {headline}
      </div>
      <div
        style={{
          fontSize: 28,
          color: BRAND.textMuted,
          marginTop: 16,
          fontWeight: 400,
          lineHeight: 1.4,
        }}
      >
        {sub}
      </div>
    </div>

    {/* Phone */}
    <div
      style={{
        zIndex: 2,
        filter: "drop-shadow(0 40px 80px rgba(0,0,0,0.7))",
        flexShrink: 0,
      }}
    >
      <PhoneFrame scale={PHONE_SCALE}>{children}</PhoneFrame>
    </div>

    {/* Bottom branding strip */}
    <div
      style={{
        position: "absolute",
        bottom: 0,
        left: 0,
        right: 0,
        height: 100,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        gap: 16,
        background: "rgba(26,26,26,0.9)",
        borderTop: "1px solid rgba(255,255,255,0.06)",
        zIndex: 3,
      }}
    >
      <Img
        src={staticFile("icon.png")}
        style={{ width: 44, height: 44, borderRadius: 12, boxShadow: `0 4px 12px rgba(253,182,35,0.3)` }}
      />
      <div style={{ fontSize: 26, fontWeight: 700, color: BRAND.textPrimary }}>Scagen</div>
      <div
        style={{
          height: 22,
          width: 1,
          background: "rgba(255,255,255,0.15)",
        }}
      />
      <div style={{ fontSize: 18, color: BRAND.textMuted }}>Free · Open Source</div>
    </div>
  </div>
);

// Screenshot 1 — Scan
export const SS1Scan: React.FC = () => (
  <ScreenshotShell
    headline={"Scan Any\nQR Code"}
    sub="Point. Tap. Done."
  >
    <ScanScreen scale={PHONE_SCALE} scanProgress={0.5} detected={false} />
  </ScreenshotShell>
);

// Screenshot 2 — Scan detected
export const SS2Detected: React.FC = () => (
  <ScreenshotShell
    headline={"Instant\nResults"}
    sub="URL, Wi-Fi, contacts & more"
  >
    <ScanScreen scale={PHONE_SCALE} scanProgress={0.5} detected={true} />
  </ScreenshotShell>
);

// Screenshot 3 — Generate grid
export const SS3Generate: React.FC = () => (
  <ScreenshotShell
    headline={"Generate\n15+ Types"}
    sub="Text, Wi-Fi, vCard, location & more"
  >
    <GenerateScreen scale={PHONE_SCALE} highlightIndex={2} />
  </ScreenshotShell>
);

// Screenshot 4 — Generated QR result
export const SS4QRResult: React.FC = () => (
  <ScreenshotShell
    headline={"Share in\nOne Tap"}
    sub="Copy, share or save your QR code"
  >
    <GeneratedQRScreen scale={PHONE_SCALE} qrType="Website" qrData="https://scagen.app" />
  </ScreenshotShell>
);

// Screenshot 5 — History
export const SS5History: React.FC = () => (
  <ScreenshotShell
    headline={"Full\nHistory"}
    sub="Every scan & creation, synced across devices"
  >
    <HistoryScreen scale={PHONE_SCALE} visibleCount={5} activeTab="scan" />
  </ScreenshotShell>
);

// Screenshot 6 — Settings
export const SS6Settings: React.FC = () => (
  <ScreenshotShell
    headline={"Your App,\nYour Rules"}
    sub="Language, privacy, notifications & more"
  >
    <SettingsScreen scale={PHONE_SCALE} />
  </ScreenshotShell>
);
