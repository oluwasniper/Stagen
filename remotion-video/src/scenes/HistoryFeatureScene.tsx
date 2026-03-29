import React from "react";
import { useCurrentFrame, useVideoConfig, interpolate, spring } from "remotion";
import { BRAND } from "../brand";
import { PhoneFrame } from "../components/PhoneFrame";
import { HistoryScreen } from "../screens/HistoryScreen";

export const HistoryFeatureScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const phoneX = spring({ fps, frame, config: { damping: 20, stiffness: 70 }, from: -280, to: 0, delay: 5 });
  const textOpacity = interpolate(frame, [18, 42], [0, 1], { extrapolateRight: "clamp" });

  // Items appear one by one, staggered
  const visibleCount = Math.min(5, 1 + Math.floor((frame - 15) / 12));
  // Flip to "Create" tab after frame 80
  const activeTab = frame >= 82 ? "create" : "scan";

  const PHONE_SCALE = 0.84;

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        background: BRAND.bg,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: BRAND.fontFamily,
        overflow: "hidden",
      }}
    >
      {/* Phone */}
      <div style={{ transform: `translateX(${phoneX}px)`, flexShrink: 0 }}>
        <PhoneFrame scale={PHONE_SCALE}>
          <HistoryScreen scale={PHONE_SCALE} visibleCount={visibleCount} activeTab={activeTab} />
        </PhoneFrame>
      </div>

      {/* Copy */}
      <div style={{ marginLeft: 72, maxWidth: 480, opacity: textOpacity }}>
        <div style={{ fontSize: 12, fontWeight: 600, color: BRAND.primary, letterSpacing: 3, textTransform: "uppercase", marginBottom: 12 }}>
          Feature 03
        </div>
        <div style={{ fontSize: 56, fontWeight: 700, color: BRAND.textPrimary, lineHeight: 1.05, letterSpacing: -1 }}>
          History<br />Everywhere
        </div>
        <div style={{ fontSize: 17, color: BRAND.textMuted, marginTop: 18, lineHeight: 1.65 }}>
          Every scan and generated code is saved locally and synced to the cloud. Access your history offline — it's always there.
        </div>

        <div style={{ marginTop: 28, display: "flex", flexDirection: "column", gap: 18 }}>
          {[
            { icon: "📵", title: "Offline-first storage", desc: "Hive local DB keeps data available without internet" },
            { icon: "☁️", title: "Cloud sync", desc: "Seamlessly syncs to Appwrite when back online" },
            { icon: "📋", title: "Scan & Generate tabs", desc: "Separate tabs to browse scanned vs created QR codes" },
          ].map(({ icon, title, desc }, i) => {
            const op = interpolate(frame, [42 + i * 14, 60 + i * 14], [0, 1], { extrapolateRight: "clamp" });
            const y = interpolate(frame, [42 + i * 14, 60 + i * 14], [14, 0], { extrapolateRight: "clamp" });
            return (
              <div key={title} style={{ display: "flex", gap: 14, opacity: op, transform: `translateY(${y}px)` }}>
                <div
                  style={{
                    width: 40,
                    height: 40,
                    borderRadius: 11,
                    background: "rgba(253,182,35,0.1)",
                    border: "1px solid rgba(253,182,35,0.2)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 20,
                    flexShrink: 0,
                  }}
                >
                  {icon}
                </div>
                <div>
                  <div style={{ fontSize: 15, color: BRAND.textPrimary, fontWeight: 600 }}>{title}</div>
                  <div style={{ fontSize: 13, color: BRAND.textMuted, marginTop: 3, lineHeight: 1.4 }}>{desc}</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
