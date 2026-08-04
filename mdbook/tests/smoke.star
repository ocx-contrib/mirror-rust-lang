# mdbook/tests/smoke.star — stable across upstream mdBook releases.
# Asserts the contract (exit codes, version shape, GENERATED FILE CONTENT),
# never help/version prose. See ocx.mirror testing-practices.md.
#
# mdBook is a static-site generator, so a fully hermetic end-to-end run is
# available and is what this test does: scaffold a book, overwrite its source
# with markdown written here, render it, and read the produced HTML back. That
# proves the renderer actually RAN — a truncated, wrong-arch or wrong-flavour
# archive that merely managed to exec would still fail every assertion below,
# because each one is about bytes mdBook had to compute from input this script
# controls.
#
# `mdbook test` is deliberately NOT used: it compiles the book's Rust code
# samples and therefore needs rustdoc, which no bundle here ships and no
# container leg installs. A verb that cannot run is not a check.
#
# No assertion below claims anything about STDOUT contents. `mdbook build`
# logs to stderr and was measured writing an empty stdout on every in-range
# version, but an empty-stdout assertion is the exact shape that reds a single
# darwin/amd64-under-Rosetta leg on an unsolicited banner. The generated files
# are the stronger evidence and are immune to it.
#
# Every flag used here was verified present and identically behaved on ALL
# THREE in-range versions — v0.5.2 (the floor), v0.5.3 and v0.5.4.

MDBOOK = "mdbook.exe" if ocx.target_platform.os == ocx.os.Windows else "mdbook"

# `env=` is an OVERLAY on the composed bundle env, not a replacement, so PATH
# still resolves the bundled binary. HOME is pointed at scratch defensively:
# container legs run with HOME unset or unwritable, and a tool that decides to
# persist anything under it exits non-zero for a reason that has nothing to do
# with the artifact.
ENV = {"HOME": ocx.scratch_root}

# Tier 1 + 2: liveness on the composed PATH + version SHAPE. Not the exact
# version and not the word "mdbook" — upstream prints "mdbook v0.5.4" today,
# and a rebrand or a banner tweak must not red the mirror. The digits in the
# documented shape are the contract.
r_version = ocx.run(MDBOOK, "--version", env=ENV)
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3a: the scaffolder. `--force` skips the confirmation prompt and
# `--ignore none` suppresses the VCS-ignore question — without both, `init`
# blocks on stdin and the leg hangs rather than fails. `bk` is created here;
# ocx.run's cwd IS the scratch root, so every path below is relative to it.
r_init = ocx.run(
    MDBOOK, "init", "--force", "--title", "OCXSMOKEBOOK", "--ignore", "none", "bk",
    env=ENV,
)
expect.ok(r_init)

# Hermetic input: the stub content `init` just wrote is overwritten wholesale,
# so every byte asserted further down is determined by this script and nothing
# else on the runner. Two chapters, because one chapter cannot show that the
# SUMMARY parser walked the book rather than rendering a single file.
ocx.write_file("bk/src/SUMMARY.md", "# Summary\n\n- [Alpha](./chapter_1.md)\n- [Bravo](./second.md)\n")
ocx.write_file("bk/src/chapter_1.md", "# Alpha\n\n**OCXBOLD**\n\n- one\n- two\n")
ocx.write_file("bk/src/second.md", "# Bravo\n\nOCXSECOND\n")

r_build = ocx.run(MDBOOK, "build", "bk", env=ENV)
expect.ok(r_build)

# Tier 3b: the markdown engine really ran. These are byte-exact HTML fragments
# mdBook had to SYNTHESISE from the markdown above — `**OCXBOLD**` became a
# `<strong>` element and `- one` became a `<li>`. A build that copied its input
# through, or shipped a stale/empty book directory, cannot produce either.
# Counts, not `contains`: each marker appears exactly once in its chapter, so a
# renderer that duplicated or dropped a block reds here.
ch1 = ocx.read_file("bk/book/chapter_1.html")
expect.eq(ch1.count("<strong>OCXBOLD</strong>"), 1)
expect.eq(ch1.count("<li>one</li>"), 1)

# Tier 3c: the SUMMARY drove the build, not the directory listing. The second
# chapter got its own output page, and the first chapter's navigation links to
# it. Presence rather than a count — the number of times a theme repeats a nav
# href is layout detail, while the link existing at all is the contract.
second = ocx.read_file("bk/book/second.html")
expect.eq(second.count("OCXSECOND"), 1)
expect.contains(ch1, "second.html")

# Tier 3d: book.toml was read and applied — the title passed to `init` reaches
# the rendered page. This is the only assertion that spans init → book.toml →
# build, so it is what catches a scaffolder that wrote a config the builder
# then ignored.
expect.contains(ch1, "OCXSMOKEBOOK")

# Tier 3e: the FIRST SUMMARY entry becomes the book's index page. Asserting the
# Alpha marker in index.html — not in chapter_1.html again — is what records
# that ordering, and it is the one check that would notice a build which
# rendered every chapter correctly but produced no landing page.
idx = ocx.read_file("bk/book/index.html")
expect.eq(idx.count("<strong>OCXBOLD</strong>"), 1)

# NEGATIVE CONTROL. Every assertion above is a "did it produce X" check, and a
# tool that succeeded unconditionally would pass all of them once the first
# build had run. `mdbook build` against a directory holding no book.toml must
# FAIL — measured exit 101 on v0.5.2, v0.5.3 and v0.5.4. Without this, nothing
# here proves red is reachable. The empty directory is a sibling of `bk`, never
# the scratch root itself, which by now contains a real book.
ocx.mkdir("nobook")
r_nobook = ocx.run(MDBOOK, "build", "nobook", env=ENV)
expect.ne(r_nobook.exit_code, 0)

# No Tier 4: metadata.json declares PATH only (proven by Tier 1 liveness).
