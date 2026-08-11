import { HoloPlayground } from "@/components/holo/HoloPlayground";

export default function Home() {
  return (
    <main className="mx-auto flex w-full max-w-[640px] flex-auto flex-col px-6 py-24 sm:px-4">
      <article className="flex min-w-0 flex-col gap-10 text-[15px] leading-[1.7]">
        <header className="flex items-center justify-between gap-4">
          <h1 className="font-semibold text-[var(--text-primary)]">Holo</h1>
        </header>

        <div className="flex min-w-0 flex-col gap-14">
          <p className="text-pretty text-[var(--text-primary)]">
            An identity card for me — tilt it and the foil catches the light,
            the hearts come up on the side you turned, and the photo flips its
            colours.
          </p>

          <HoloPlayground />

          <p className="text-[13px] text-[var(--text-secondary)]">
            Inspired by{" "}
            <a
              href="https://www.arlan.me/vault/holo"
              target="_blank"
              rel="noopener noreferrer"
              className="text-[var(--text-primary)] underline decoration-[var(--border-line)] underline-offset-4 transition-colors hover:decoration-[var(--text-secondary)]"
            >
              Arlan Marat
            </a>
          </p>
        </div>
      </article>
    </main>
  );
}
