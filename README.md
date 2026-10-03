# c31.io

Install `nix` and `direnv`.

Install `pnpm` via the flake dev shell (`nix develop`).

## Development

```sh
nix develop
pnpm install
pnpm dev
```

Run `pnpm check` for Svelte/JavaScript type checking and `pnpm build` to generate the static site in `public`.

## Background

The shared layout mounts `src/lib/BoidsBackground.svelte` once across page navigation. It renders 160 small, monochrome triangles behind the content; the decorative canvas is hidden from assistive technology and never intercepts pointer input.

`src/lib/boids.wgsl` runs separation, alignment, and cohesion on the GPU, with wraparound screen edges. Rendering targets 30 fps, caps pixel density at 2×, and follows the system light/dark preference.

Reduced-motion preferences hide the flock and stop animation; an initial reduced-motion preference skips GPU initialization entirely. Hidden documents pause animation. GPU resources are released on component teardown or device loss.

WebGPU requires a secure context (HTTPS or localhost) and a supported browser/GPU. Missing WebGPU, unavailable adapters, initialization failures, and device loss leave the existing plain background intact; there is no CPU animation fallback.
