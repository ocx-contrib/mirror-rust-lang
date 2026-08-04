# NOTICE

This repository packages and redistributes upstream software published by the
[Rust project](https://github.com/rust-lang). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use except where a separate license is named. The marks remain
the property of their respective owners and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `mdbook` | `ghcr.io/ocx-contrib/rust-lang/mdbook` | `MPL-2.0` |

---

## `mdbook`

Upstream: <https://github.com/rust-lang/mdBook>
Published to `ghcr.io/ocx-contrib/rust-lang/mdbook`.

| Component | SPDX | Holder |
|---|---|---|
| mdBook (`mdbook`) | **MPL-2.0** | The Rust Project Developers and the mdBook contributors |

Weak (file-level) copyleft. MPL-2.0 §3.2 grants redistribution of the
Executable Form, and its share-alike duty attaches to **modified MPL-covered
source files** — of which this mirror has none: upstream's own release binaries
are republished unchanged, byte for byte. The terms are those of
<https://github.com/rust-lang/mdBook/blob/master/LICENSE>.

**Corresponding source, per version.** MPL-2.0 §3.2(a) requires that recipients
of the Executable Form be informed how to obtain the Source Code Form. Every
mirrored version corresponds to a GitHub release tag in the upstream
repository, so for any mirrored version `X.Y.Z` the source is at:

- `https://github.com/rust-lang/mdBook/releases/tag/vX.Y.Z` — the release tag
  whose CI built the exact binaries this package republishes
- <https://github.com/rust-lang/mdBook> — the canonical source tree

Concretely, for the versions in this mirror's range:

- <https://github.com/rust-lang/mdBook/releases/tag/v0.5.2>
- <https://github.com/rust-lang/mdBook/releases/tag/v0.5.3>
- <https://github.com/rust-lang/mdBook/releases/tag/v0.5.4>

The published binaries statically link third-party Rust crates under permissive
licenses, enumerated in upstream's `Cargo.lock`.

The mdBook name is used for catalog identification under nominative fair use.
The **logo** shipped with this package is not an OCX original: the glyph is
mdBook's own mark, taken verbatim from upstream's
`crates/mdbook-html/front-end/images/favicon.svg` and shipped inside every book
mdBook builds. Upstream records its provenance as *"Original image Copyright
Dave Gandy — CC BY 4.0 License"*, and it is reused here under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) with that attribution.
The artwork is adapted only in presentation — the path is unchanged, recoloured
white on a solid plate so the mark stays legible on light and dark catalog
backgrounds, where upstream's bare-black original would not.

`mdbook test` compiles a book's Rust code samples using `rustdoc`. No Rust
toolchain is contained in or redistributed by this package; that subcommand
requires one already present on the host.

---

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
