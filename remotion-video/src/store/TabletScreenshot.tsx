import React from "react";
import { Img, staticFile } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { ScanScreen } from "../screens/ScanScreen";
import { GenerateScreen } from "../screens/GenerateScreen";
import { GeneratedQRScreen } from "../screens/GeneratedQRScreen";
import { HistoryScreen } from "../screens/HistoryScreen";
import { SettingsScreen } from "../screens/SettingsScreen";

// Google Play tablet specs (landscape recommended):
//   7"  tablet: 1920×1200
//  10"  tablet: 2560×1600

// Landscape layout: bold text left, phone(s) right — mirrors the feature graphic style
// but taller and more spacious.

interface TabletShellProps {
  headline: string;
  sub: string;
  width: number;
  height: number;
  phoneScale: number;
  children: React.ReactNode;         // primary (front) phone screen
  secondaryChildren?: React.ReactNode; // optional back phone
  secondaryHighlight?: boolean;
}

const TabletShell: React.FC<TabletShellProps> = ({
  headline,
  sub,
  width,
  height,
  phoneScale,
  children,
  secondaryChildren,
}) => (
  <div
    style={{
      width,
      height,
      background: BRAND.bg,
      fontFamily: BRAND.fontFamily,
      display: "flex",
      alignItems: "center",
      position: "relative",
      overflow: "hidden",
    }}
  >
    {/* Radial glow centred on the right half */}
    <div
      style={{
        position: "absolute",
        top: "50%",
        left: "60%",
        transform: "translate(-50%, -50%)",
        width: height * 1.4,
        height: height * 1.4,
        borderRadius: "50%",
        background: `radial-gradient(circle, rgba(253,182,35,0.08) 0%, transparent 60%)`,
        pointerEvents: "none",
      }}
    />

    {/* Decorative arcs — top-right corner */}
    {[380, 260, 160].map((r, i) => (
      <div
        key={r}
        style={{
          position: "absolute",
          top: -r * 0.4,
          right: -r * 0.4,
          width: r * 1.4,
          height: r * 1.4,
          borderRadius: "50%",
          border: `1px solid rgba(253,182,35,${0.07 - i * 0.02})`,
          pointerEvents: "none",
        }}
      />
    ))}

    {/* Left text block */}
    <div
      style={{
        flex: "0 0 auto",
        width: width * 0.42,
        paddingLeft: width * 0.06,
        paddingRight: width * 0.03,
        zIndex: 2,
        display: "flex",
        flexDirection: "column",
        gap: 0,
      }}
    >
      {/* Badge */}
      <div
        style={{
          display: "inline-flex",
          alignItems: "center",
          background: BRAND.primary,
          borderRadius: height * 0.012,
          padding: `${height * 0.008}px ${height * 0.022}px`,
          marginBottom: height * 0.03,
          alignSelf: "flex-start",
        }}
      >
        <span
          style={{
            fontSize: height * 0.018,
            fontWeight: 700,
            color: "#1A1A1A",
            letterSpacing: 1.5,
            textTransform: "uppercase",
          }}
        >
          Free · Open Source
        </span>
      </div>

      {/* Headline */}
      <div
        style={{
          fontSize: height * 0.075,
          fontWeight: 800,
          color: BRAND.textPrimary,
          lineHeight: 1.05,
          letterSpacing: -1.5,
          whiteSpace: "pre-line",
        }}
      >
        {headline}
      </div>

      {/* Sub */}
      <div
        style={{
          fontSize: height * 0.032,
          color: BRAND.textMuted,
          marginTop: height * 0.025,
          lineHeight: 1.5,
        }}
      >
        {sub}
      </div>

      {/* Branding row */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: height * 0.022,
          marginTop: height * 0.05,
        }}
      >
        <Img
          src={staticFile("icon.png")}
          style={{
            width: height * 0.07,
            height: height * 0.07,
            borderRadius: height * 0.015,
            boxShadow: `0 4px 14px rgba(253,182,35,0.35)`,
          }}
        />
        <div>
          <div style={{ fontSize: height * 0.033, fontWeight: 700, color: BRAND.textPrimary }}>
            Scagen
          </div>
          <div style={{ fontSize: height * 0.02, color: BRAND.textMuted }}>
            Android & iOS
          </div>
        </div>
      </div>
    </div>

    {/* Right: phone(s) */}
    <div
      style={{
        flex: 1,
        height: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        position: "relative",
        zIndex: 2,
      }}
    >
      {secondaryChildren ? (
        // Two-phone layout
        <div
          style={{
            position: "relative",
            width: 390 * phoneScale * 1.25,
            height: height * 0.95,
          }}
        >
          {/* Back phone — rotated, behind */}
          <div
            style={{
              position: "absolute",
              top: height * 0.04,
              right: 0,
              transform: `rotate(5deg) scale(0.82)`,
              transformOrigin: "bottom right",
              filter: "drop-shadow(0 20px 50px rgba(0,0,0,0.6))",
              opacity: 0.82,
              zIndex: 1,
            }}
          >
            <PhoneFrame scale={phoneScale * 0.9}>
              {secondaryChildren}
            </PhoneFrame>
          </div>
          {/* Front phone */}
          <div
            style={{
              position: "absolute",
              bottom: height * 0.02,
              left: 0,
              filter: "drop-shadow(0 30px 70px rgba(0,0,0,0.7))",
              zIndex: 2,
            }}
          >
            <PhoneFrame scale={phoneScale}>{children}</PhoneFrame>
          </div>
        </div>
      ) : (
        // Single phone — centred
        <div style={{ filter: "drop-shadow(0 30px 80px rgba(0,0,0,0.7))" }}>
          <PhoneFrame scale={phoneScale}>{children}</PhoneFrame>
        </div>
      )}
    </div>
  </div>
);

// ── 7" tablet  1920×1200 ──────────────────────────────────────────────────────
const W7 = 1920;
const H7 = 1200;
const PHONE7 = 1.18; // 390*1.18=460px wide, 844*1.18=996px tall — fills 1200h nicely

export const T7_Scan: React.FC = () => (
  <TabletShell width={W7} height={H7} phoneScale={PHONE7}
    headline={"Scan Any\nQR Code"} sub={"Point. Tap. Done.\nURL, Wi-Fi, contacts & more"}>
    <ScanScreen scale={PHONE7} scanProgress={0.5} detected={false} />
  </TabletShell>
);

export const T7_Generate: React.FC = () => (
  <TabletShell width={W7} height={H7} phoneScale={PHONE7}
    headline={"Generate\n15+ Types"} sub={"Text, Wi-Fi, vCard, location\nand many more"}
    secondaryChildren={<GeneratedQRScreen scale={PHONE7 * 0.9} qrType="Website" qrData="https://scagen.app" />}>
    <GenerateScreen scale={PHONE7} highlightIndex={2} />
  </TabletShell>
);

export const T7_History: React.FC = () => (
  <TabletShell width={W7} height={H7} phoneScale={PHONE7}
    headline={"Full\nHistory"} sub={"Every scan & creation,\nsynced across devices"}>
    <HistoryScreen scale={PHONE7} visibleCount={5} activeTab="scan" />
  </TabletShell>
);

export const T7_Settings: React.FC = () => (
  <TabletShell width={W7} height={H7} phoneScale={PHONE7}
    headline={"Your App,\nYour Rules"} sub={"Language, privacy,\nnotifications & more"}>
    <SettingsScreen scale={PHONE7} />
  </TabletShell>
);

// ── 10" tablet  2560×1600 ────────────────────────────────────────────────────
const W10 = 2560;
const H10 = 1600;
const PHONE10 = 1.58; // 390*1.58=616px wide, 844*1.58=1333px tall — fills 1600h

export const T10_Scan: React.FC = () => (
  <TabletShell width={W10} height={H10} phoneScale={PHONE10}
    headline={"Scan Any\nQR Code"} sub={"Point. Tap. Done.\nURL, Wi-Fi, contacts & more"}>
    <ScanScreen scale={PHONE10} scanProgress={0.5} detected={false} />
  </TabletShell>
);

export const T10_Generate: React.FC = () => (
  <TabletShell width={W10} height={H10} phoneScale={PHONE10}
    headline={"Generate\n15+ Types"} sub={"Text, Wi-Fi, vCard, location\nand many more"}
    secondaryChildren={<GeneratedQRScreen scale={PHONE10 * 0.9} qrType="Website" qrData="https://scagen.app" />}>
    <GenerateScreen scale={PHONE10} highlightIndex={2} />
  </TabletShell>
);

export const T10_History: React.FC = () => (
  <TabletShell width={W10} height={H10} phoneScale={PHONE10}
    headline={"Full\nHistory"} sub={"Every scan & creation,\nsynced across devices"}>
    <HistoryScreen scale={PHONE10} visibleCount={5} activeTab="scan" />
  </TabletShell>
);

export const T10_Settings: React.FC = () => (
  <TabletShell width={W10} height={H10} phoneScale={PHONE10}
    headline={"Your App,\nYour Rules"} sub={"Language, privacy,\nnotifications & more"}>
    <SettingsScreen scale={PHONE10} />
  </TabletShell>
);
