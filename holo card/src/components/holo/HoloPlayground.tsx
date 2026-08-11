"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { FOILS, type Foil } from "./engine";
import { HoloBody, useHoloDrive } from "./HoloCard";

function Slider({
  label,
  min,
  max,
  step,
  value,
  onChange,
}: {
  label: string;
  min: number;
  max: number;
  step: number;
  value: number;
  onChange: (v: number) => void;
}) {
  const pct = ((value - min) / (max - min)) * 100;
  return (
    <label className="flex min-w-[9rem] flex-1 flex-col gap-1.5">
      <div className="flex items-center justify-between text-[12px]">
        <span className="text-[var(--text-secondary)]">{label}</span>
        <span className="tabular-nums text-[var(--text-primary)]">
          {value.toFixed(2)}
        </span>
      </div>
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        value={value}
        aria-label={label}
        onChange={(e) => onChange(Number(e.target.value))}
        className="holo-range w-full"
        style={{ "--pct": `${pct}%` } as React.CSSProperties}
      />
    </label>
  );
}

export function HoloPlayground() {
  const hostRef = useRef<HTMLDivElement>(null);
  const cardRef = useRef<HTMLDivElement>(null);
  const [foilKey, setFoilKey] = useState(FOILS[0].key);
  const foil = useMemo(
    () => FOILS.find((f) => f.key === foilKey) ?? FOILS[0],
    [foilKey],
  );
  const [parallax, setParallax] = useState(foil.parallax);
  const [bloom, setBloom] = useState(foil.bloom);
  const [deviceTilt, setDeviceTilt] = useState(false);
  const [tiltMsg, setTiltMsg] = useState<string | null>(null);

  useEffect(() => {
    setParallax(foil.parallax);
    setBloom(foil.bloom);
  }, [foil]);

  useHoloDrive(hostRef, cardRef, {
    foil,
    live: { parallax, bloom },
    deviceTilt,
  });

  const pick = useCallback((next: Foil) => {
    setFoilKey(next.key);
  }, []);

  const enableTilt = useCallback(async () => {
    type OrientRequest = {
      requestPermission?: () => Promise<"granted" | "denied" | "default">;
    };
    const DOE = DeviceOrientationEvent as unknown as OrientRequest;
    try {
      if (typeof DOE.requestPermission === "function") {
        const state = await DOE.requestPermission();
        if (state !== "granted") {
          setTiltMsg("Motion access denied");
          return;
        }
      }
      setDeviceTilt(true);
      setTiltMsg("Tilt your device");
    } catch {
      setTiltMsg("Motion not available");
    }
  }, []);

  const reset = useCallback(() => {
    setFoilKey(FOILS[0].key);
    setParallax(FOILS[0].parallax);
    setBloom(FOILS[0].bloom);
    setDeviceTilt(false);
    setTiltMsg(null);
  }, []);

  return (
    <section className="flex min-w-0 flex-col gap-4">
      <header className="flex items-center justify-between gap-3 border-b border-[var(--border-line)] pb-2">
        <h2 className="font-semibold text-[var(--text-primary)]">Playground</h2>
        <button
          type="button"
          onClick={reset}
          className="inline-flex h-7 shrink-0 items-center self-start rounded-lg border border-[var(--border-line)] bg-[var(--bg-surface)] px-3 text-[12px] font-medium text-[var(--text-secondary)] transition-colors hover:border-[var(--border-ring)] hover:bg-[var(--bg-hover)] hover:text-[var(--text-primary)] active:scale-[0.98]"
        >
          Remix
        </button>
      </header>

      <div className="flex min-w-0 flex-col">
        <div
          ref={hostRef}
          className="relative z-10 flex aspect-video items-center justify-center overflow-hidden rounded-xl border border-[var(--border-line)] bg-[var(--bg-hover)]"
          style={{ perspective: "1100px" }}
        >
          <HoloBody ref={cardRef} />
        </div>

        <div className="-mt-5 flex min-w-0 flex-col gap-4 rounded-b-xl border border-t-0 border-[var(--border-line)] bg-[var(--bg-surface)] p-4 pt-8">
          <div className="flex flex-col gap-2">
            <div className="flex h-8 w-full items-center rounded-lg border border-[var(--border-line)] bg-[var(--bg-page)] px-3 text-[12px] text-[var(--text-secondary)]">
              <span>Material</span>
              <span className="ml-auto text-[var(--text-primary)]">
                {foil.label}
              </span>
            </div>
            <div className="flex flex-wrap gap-1.5">
              {FOILS.map((f) => (
                <button
                  key={f.key}
                  type="button"
                  onClick={() => pick(f)}
                  className={`rounded-md border px-2.5 py-1 text-[11px] font-medium transition-colors ${
                    f.key === foilKey
                      ? "border-[var(--border-ring)] bg-[var(--bg-hover)] text-[var(--text-primary)]"
                      : "border-[var(--border-line)] bg-[var(--bg-page)] text-[var(--text-secondary)] hover:text-[var(--text-primary)]"
                  }`}
                >
                  {f.label}
                </button>
              ))}
            </div>
          </div>

          <div className="flex flex-col gap-3 sm:flex-row">
            <Slider
              label="Parallax"
              min={0}
              max={0.6}
              step={0.01}
              value={parallax}
              onChange={setParallax}
            />
            <Slider
              label="Bloom"
              min={0}
              max={1}
              step={0.01}
              value={bloom}
              onChange={setBloom}
            />
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <button
              type="button"
              onClick={enableTilt}
              disabled={deviceTilt}
              className="inline-flex h-8 items-center rounded-lg border border-[var(--border-line)] bg-[var(--bg-page)] px-3 text-[12px] font-medium text-[var(--text-secondary)] transition-colors hover:border-[var(--border-ring)] hover:text-[var(--text-primary)] disabled:opacity-60"
            >
              {deviceTilt ? "Device tilt on" : "Enable device tilt"}
            </button>
            {tiltMsg ? (
              <span className="text-[12px] text-[var(--text-secondary)]">
                {tiltMsg}
              </span>
            ) : null}
          </div>
        </div>
      </div>
    </section>
  );
}
