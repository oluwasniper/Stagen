import React from "react";
import { BRAND } from "../brand";
import { BottomNav } from "../components/BottomNav";

const ITEMS = [
  { icon: "🌐", label: "Website", data: "https://scagen.app", time: "2m ago", pending: false },
  { icon: "📶", label: "Wi-Fi", data: "HomeNetwork · WPA2", time: "1h ago", pending: false },
  { icon: "👤", label: "Contact", data: "John Doe", time: "3h ago", pending: true },
  { icon: "📍", label: "Location", data: "40.7128° N, 74.0060° W", time: "Yesterday", pending: false },
  { icon: "✉️", label: "Email", data: "hello@example.com", time: "2d ago", pending: false },
];

export const HistoryScreen: React.FC<{ scale?: number; visibleCount?: number; activeTab?: "scan" | "create" }> = ({
  scale = 1,
  visibleCount = 5,
  activeTab = "scan",
}) => (
  <div
    style={{
      width: "100%",
      height: "100%",
      background: BRAND.bg,
      display: "flex",
      flexDirection: "column",
      fontFamily: BRAND.fontFamily,
    }}
  >
    <div style={{ height: 60 * scale }} />

    {/* Header */}
    <div
      style={{
        padding: `0 ${20 * scale}px ${12 * scale}px`,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
      }}
    >
      <div style={{ fontSize: 22 * scale, fontWeight: 600, color: BRAND.textPrimary }}>History</div>
      <div style={{ color: BRAND.primary, fontSize: 13 * scale, fontWeight: 500 }}>↻ Sync Now</div>
    </div>

    {/* Tab bar */}
    <div style={{ padding: `0 ${20 * scale}px ${12 * scale}px` }}>
      <div
        style={{
          height: 52 * scale,
          background: "rgba(51,51,51,0.84)",
          borderRadius: 12 * scale,
          padding: 5 * scale,
          display: "flex",
          position: "relative",
        }}
      >
        {/* Active indicator */}
        <div
          style={{
            position: "absolute",
            top: 5 * scale,
            left: activeTab === "scan" ? 5 * scale : `calc(50% + ${5 * scale}px)`,
            width: `calc(50% - ${10 * scale}px)`,
            height: 42 * scale,
            background: BRAND.primary,
            borderRadius: 8 * scale,
            boxShadow: `0 0 ${8 * scale}px rgba(253,182,35,0.3)`,
            transition: "left 0.25s",
          }}
        />
        {["Scan", "Create"].map((tab, i) => (
          <div
            key={tab}
            style={{
              flex: 1,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              zIndex: 1,
              fontSize: 14 * scale,
              fontWeight: (activeTab === "scan" && i === 0) || (activeTab === "create" && i === 1) ? 600 : 400,
              color: (activeTab === "scan" && i === 0) || (activeTab === "create" && i === 1) ? "#1A1A1A" : "rgba(255,255,255,0.6)",
            }}
          >
            {tab}
          </div>
        ))}
      </div>
    </div>

    {/* List */}
    <div style={{ flex: 1, overflowY: "hidden", display: "flex", flexDirection: "column", gap: 8 * scale, padding: `0 ${20 * scale}px` }}>
      {ITEMS.slice(0, visibleCount).map((item, i) => (
        <div
          key={i}
          style={{
            height: 68 * scale,
            background: "rgba(51,51,51,0.84)",
            borderRadius: 12 * scale,
            boxShadow: `0 ${3 * scale}px ${6 * scale}px rgba(0,0,0,0.2)`,
            display: "flex",
            alignItems: "center",
            padding: `0 ${12 * scale}px`,
            gap: 0,
          }}
        >
          {/* QR icon area */}
          <div style={{ width: 40 * scale, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <span style={{ fontSize: 22 * scale, color: BRAND.primary }}>{item.icon}</span>
          </div>

          {/* Content */}
          <div style={{ flex: 1, padding: `${8 * scale}px ${14 * scale}px ${8 * scale}px ${8 * scale}px`, minWidth: 0 }}>
            <div style={{ fontSize: 14 * scale, fontWeight: 500, color: BRAND.textPrimary, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
              {item.label}
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: 4 * scale, marginTop: 2 * scale }}>
              <div style={{ fontSize: 11 * scale, color: BRAND.textMuted, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", flex: 1 }}>
                {item.time}
              </div>
              {item.pending && (
                <span style={{ fontSize: 12 * scale, color: `${BRAND.primary}B3` }}>☁</span>
              )}
            </div>
          </div>

          {/* Chevron */}
          <div style={{ color: "rgba(255,255,255,0.25)", fontSize: 16 * scale, paddingRight: 4 * scale }}>›</div>
        </div>
      ))}
    </div>

    <div style={{ height: 100 * scale }} />
    <BottomNav active="history" scale={scale} />
  </div>
);
