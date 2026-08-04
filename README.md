# mirror-rust-lang

OCX mirror for [mdBook](https://github.com/rust-lang/mdBook), the Markdown-to-
book static site generator behind the Rust documentation. One repository, one
spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [mdBook](https://github.com/rust-lang/mdBook) | [`mdbook/mirror.yml`](mdbook/mirror.yml) | `ghcr.io/ocx-contrib/rust-lang/mdbook` | [`ocx.sh/rust-lang/mdbook`](https://index.ocx.sh/rust-lang/mdbook) | `MPL-2.0` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> The upstream **repository** is spelled `mdBook` with a capital B; the crate,
> the binary and the subcommand are all lowercase `mdbook`, and index
> coordinates are lowercase always. So the capital lives only in
> `source.repo:` — everywhere else it is `rust-lang/mdbook`.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
mdbook/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`mdbook` publishes **five** platform entries: both Linux arches, both macOS
arches and `windows/amd64`.

**There is no `windows/arm64`, and none is planned.** Upstream has never
shipped an aarch64 Windows asset — v0.5.0 through v0.5.4 each publish exactly
six assets, of which the only Windows one is `x86_64-pc-windows-msvc.zip`.
Declaring the key anyway would boot a `windows-11-arm` runner that resolves no
asset and reports success having tested nothing.

**There is no `linux/arm64+libc.glibc` either, for the same reason**: upstream
ships `aarch64-unknown-linux-musl` and no aarch64 gnu build at all. arm64 is
musl-only upstream.

Both Linux keys are **bare** — no `+libc.*` suffix. That is a measurement, not
an inference: on v0.5.4 *and* on the v0.5.2 floor, on x86-64 and aarch64 alike,
the musl binaries have no `PT_INTERP` and no `DT_NEEDED` — musl is linked *in*,
not linked *against* — and none is UPX-packed (zero `^UPX` strings, section
headers present), which is the one thing that would make `file` say "statically
linked" about a dynamic binary. The x86_64 gnu binary by contrast names
`/lib64/ld-linux-x86-64.so.2`, needs `libc.so.6`, `libm.so.6` and
`libgcc_s.so.1`, and tops out at `GLIBC_2.34`, so it would require
`+libc.glibc`. `os.features` states what an artifact requires *of the host*,
and a static binary requires nothing — tagging it `+libc.musl` would be a false
requirement that hid the package from every glibc host it in fact runs on. The
second, gnu-keyed platform is not carried because the usual reason to ship one
does not apply: musl's resolver ignores `nsswitch.conf`, and mdBook never
resolves a hostname — it reads and writes local files, and `mdbook serve` binds
a local socket rather than dialling out. The `alpine:3.20` container leg in
`mirror-base.yml` is what turns the universality claim into evidence; the
measurement itself is recorded above the `assets:` block in `mdbook/mirror.yml`.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `mdbook/mirror.yml` | hand | yes — see below |
| `mdbook/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `mdbook/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec mdbook/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

`mdbook/metadata.json` declares `binaries: ["mdbook"]` by hand, and
`mdbook/mirror.yml` sets `bin_scan: "off"` — forced, not preferred. Every
upstream archive is **flat**: the tarballs hold a bare `mdbook` at the archive
root and the Windows zip a bare `mdbook.exe`, with no wrapper directory, no
`bin/`, and no bundled LICENSE or README. `strip_components: 0` is therefore
also forced — on a flat archive `strip_components: 1` would delete the only
entry and ship a bundle with no binary — and it leaves the content root with no
subdirectory for a scan to inspect, so `auto` and `verify` both fail spec load
at exit 65 rather than offer a hollow check. The hand-written list is what the
error message itself directs, and it is as short as a claim gets: one binary,
mode 0755 upstream, and nothing else in the archive.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md),
including the per-version Corresponding Source pointers that MPL-2.0 §3.2(a)
requires.
