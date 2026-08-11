"use client";

import { useEffect, useRef } from "react";
import {
  FOILS,
  Follow,
  Kick,
  Orientation,
  applyFoil,
  applyFrame,
  fromPointer,
  type Foil,
  type Live,
} from "./engine";
import "./holo.css";

export function HoloBody({
  ref,
  className = "h-[76%]",
}: {
  ref: React.Ref<HTMLDivElement>;
  className?: string;
}) {
  return (
    <div
      ref={ref}
      className={`holo-card relative ${className}`}
      style={{ aspectRatio: "1.55" }}
    >
      <div className="holo-body" />
      <div className="holo-pattern" />
      <div className="holo-pattern--lit" />
      <div className="holo-foil" />
      <div className="holo-foil--b" />
      <div className="holo-foil--c" />
      <div className="holo-smear" />
      <div className="holo-spot" />
      <div className="holo-noise" />
      <div className="holo-glare" />
      <div className="holo-sheen" />

      <div className="holo-content">
        <div className="holo-text">
          <p className="holo-name">Imaad</p>
          <p className="holo-since">software engineer at IBM · Bengaluru</p>
        </div>

        <div className="holo-tile">
          <div className="holo-tile__photo" />
          <div className="holo-tile__photo--neg" />
          <div className="holo-tile__duo" />
          <div className="holo-tile__tone" />
          <div className="holo-tile__foil" />
          <div className="holo-tile__grain" />
          <div className="holo-tile__wear" />
          <div className="holo-tile__vignette" />
          <div className="holo-tile__gloss" />
        </div>
      </div>
    </div>
  );
}

export function useHoloDrive(
  hostRef: React.RefObject<HTMLElement | null>,
  cardRef: React.RefObject<HTMLElement | null>,
  opts: {
    foil: Foil;
    live: Live;
    /** When true, listens for deviceorientation (playground opt-in). */
    deviceTilt?: boolean;
  },
) {
  const foilRef = useRef(opts.foil);
  const liveRef = useRef(opts.live);
  foilRef.current = opts.foil;
  liveRef.current = opts.live;

  useEffect(() => {
    if (cardRef.current) applyFoil(cardRef.current, opts.foil);
  }, [cardRef, opts.foil]);

  useEffect(() => {
    const host = hostRef.current;
    const card = cardRef.current;
    if (!host || !card) return;
    const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    const tilt = new Follow(0.16);
    const sheet = new Follow(0.09);
    const kick = new Kick();
    const t0 = performance.now();

    let raf = 0;
    let running = false;
    let onScreen = false;
    let hidden = false;
    let idle = 0;
    let touched = false;
    let release = 1;
    let handoff = { x: 0, y: 0 };
    let grab = 1;
    let grabFrom = { x: 0, y: 0 };
    let aim = { x: 0, y: 0 };

    const frame = () => {
      raf = 0;

      if (!touched) {
        idle += 0.0042;
        const drift = {
          x: Math.sin(idle) * 0.28,
          y: Math.cos(idle * 0.73) * 0.2,
        };
        release = Math.min(1, release + 0.016);
        const k = release * release;
        tilt.target = {
          x: handoff.x + (drift.x - handoff.x) * k,
          y: handoff.y + (drift.y - handoff.y) * k,
        };
      }

      if (touched) {
        grab = Math.min(1, grab + 0.018);
        const k = grab * grab;
        tilt.target = {
          x: grabFrom.x + (aim.x - grabFrom.x) * k,
          y: grabFrom.y + (aim.y - grabFrom.y) * k,
        };
      }

      const k = kick.step();
      if (k.x || k.y) {
        tilt.target = { x: tilt.target.x + k.x, y: tilt.target.y + k.y };
      }

      tilt.step();
      sheet.target = tilt.value;
      sheet.step();

      const foil = foilRef.current;
      applyFrame(card, tilt.value, sheet.value, foil, liveRef.current, {
        speed: sheet.speed,
        velocity: sheet.velocity,
        time: (performance.now() - t0) / 1000,
      });

      if (
        running &&
        (!touched ||
          release < 1 ||
          grab < 1 ||
          kick.active ||
          !tilt.settled ||
          !sheet.settled)
      ) {
        raf = requestAnimationFrame(frame);
      }
    };

    const wake = () => {
      if (!running || raf) return;
      raf = requestAnimationFrame(frame);
    };

    const onPointer = (e: PointerEvent) => {
      if (reduced) return;
      aim = fromPointer(host.getBoundingClientRect(), e.clientX, e.clientY);
      if (!touched) {
        touched = true;
        grabFrom = { x: tilt.value.x, y: tilt.value.y };
        grab = 0;
      }
      release = 0;
      wake();
    };

    const onLeave = () => {
      touched = false;
      handoff = { x: tilt.value.x, y: tilt.value.y };
      release = 0;
      grab = 1;
      kick.fire(tilt.velocity);
      wake();
    };

    const sync = () => {
      const should = onScreen && !hidden && !reduced;
      if (should === running) return;
      running = should;
      if (should) wake();
      else if (raf) {
        cancelAnimationFrame(raf);
        raf = 0;
      }
    };

    const io = new IntersectionObserver(
      (es) => {
        onScreen = es.some((e) => e.isIntersecting);
        sync();
      },
      { rootMargin: "200px" },
    );
    io.observe(host);

    const onVis = () => {
      hidden = document.hidden;
      sync();
    };
    document.addEventListener("visibilitychange", onVis);

    const orient = new Orientation();
    const onOrient = (e: DeviceOrientationEvent) => {
      if (reduced || !opts.deviceTilt) return;
      const v = orient.read(e);
      if (!v) return;
      touched = true;
      aim = v;
      grab = 1;
      tilt.target = v;
      wake();
    };

    host.addEventListener("pointermove", onPointer);
    host.addEventListener("pointerleave", onLeave);
    if (opts.deviceTilt) {
      window.addEventListener("deviceorientation", onOrient);
    }

    return () => {
      running = false;
      if (raf) cancelAnimationFrame(raf);
      io.disconnect();
      document.removeEventListener("visibilitychange", onVis);
      host.removeEventListener("pointermove", onPointer);
      host.removeEventListener("pointerleave", onLeave);
      window.removeEventListener("deviceorientation", onOrient);
    };
  }, [hostRef, cardRef, opts.deviceTilt]);
}

/** Display card — one material, idle drift + pointer. */
export function HoloCard() {
  const hostRef = useRef<HTMLDivElement>(null);
  const cardRef = useRef<HTMLDivElement>(null);
  const foil = FOILS[0];

  useHoloDrive(hostRef, cardRef, {
    foil,
    live: { parallax: foil.parallax, bloom: foil.bloom },
  });

  return (
    <div
      ref={hostRef}
      role="img"
      aria-label="An identity card reading Imaad, software engineer at IBM in Bengaluru, with a holographic foil surface that tilts and catches the light as the pointer moves across it"
      data-holo-lite=""
      className="relative flex aspect-[1344/620] w-full select-none items-center justify-center overflow-hidden rounded-[12px] border border-[var(--border-line)] bg-[linear-gradient(180deg,#f6f7f9_0%,#eceef2_100%)]"
      style={{ perspective: "1100px" }}
    >
      <HoloBody ref={cardRef} />
    </div>
  );
}
