# kickstart.nvim (personal fork)

A personal fork of [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).
Upstream is a single monolithic `init.lua`; this fork splits it into modules
(`lua/options.lua`, `lua/keymaps.lua`, `lua/autocommands.lua`, `lua/lazy-plugins.lua`,
`lua/kickstart/plugins/*.lua`, `lua/custom/plugins/*.lua`).

## Relationship to Upstream

**This fork uses lazy.nvim, not `vim.pack`.** Upstream migrated its plugin
management to Neovim 0.12's built-in `vim.pack`. This fork deliberately stays on
lazy.nvim. When porting an upstream change, translate `vim.pack.add {...}` +
imperative `require('x').setup{}` into a Lazy spec (`{ 'owner/repo', opts = {} }`
or a `config` function). Do not migrate to `vim.pack`.

Intentional divergences from upstream (do not "fix" to match upstream): leader
key is `,`; options use `vim.opt` style; `vim.o.clipboard` is left commented out;
diagnostics use `virtual_text = false`; blink uses its default snippet source
(not `preset = 'luasnip'`); a curated mini.nvim module set; and custom plugins
upstream never had (bufferline, lualine, trouble, snacks, toggleterm, neo-tree,
obsidian, nvim-surround, DAP-python, etc.).

## Before You Refactor

**Why does `treesitter.lua` pick between the `main` and `master` branch at runtime?**

nvim-treesitter's `main` branch (the rewrite) compiles parsers by shelling out to
the `tree-sitter` **CLI**; the legacy `master` branch compiles generated C with
`cc`/`gcc` and needs no CLI. The spec detects a *working* CLI at startup and picks
`main` if present, else falls back to `master`. Detection **executes**
`tree-sitter --version` rather than trusting `vim.fn.executable()`, because a
machine can have the binary on PATH but unusable (Mason's prebuilt `tree-sitter-cli`
requires GLIBC 2.39; Ubuntu 22.04 ships 2.35, so every `tree-sitter build` fails).
This lets one config serve both a CLI-capable machine (uses `main`) and one that
can only build with `cc` (falls back to `master`). Do not simplify to a single
branch. Note: `master` is archived upstream but still builds; the conditional
auto-upgrades to `main` once the CLI works.

**Why is LSP driven by `vim.lsp.enable`, not `require('lspconfig')[name].setup()`?**

Neovim 0.11+ has a native LSP API. `lspconfig.lua` registers each server with
`vim.lsp.config(name, ...)` and starts it with `vim.lsp.enable(name)`. nvim-lspconfig
is still installed but is **no longer the runtime driver** — it only ships the
`lsp/<name>.lua` definitions (default `cmd`, `filetypes`, `root_markers`) that
`vim.lsp.enable` reads. mason-lspconfig is kept only for its package-name mapping
(used by mason-tool-installer, e.g. `lua_ls` -> `lua-language-server`); its
`setup`/`handlers` path is intentionally unused. Do not re-add the handler loop.

## Before You Add a Feature

**All plugins are disabled under vscode-neovim (Cursor) via one switch.**

This config also runs under vscode-neovim (Cursor), where Neovim is an embedded
engine and the editor owns the UI, LSP, completion, formatting, and linting (via
Cursor's own extensions). vscode-neovim sets `vim.g.vscode` (truthy). Running our
plugins on top fights Cursor over signatures, the command line, and its managed
buffers — mini.diff, for example, errored with "Buffer N is not enabled" on a
Cursor buffer. Rather than gate plugins individually, `lazy-plugins.lua` sets
`defaults = { cond = not vim.g.vscode }` in the Lazy config, so **every** spec is
disabled under Cursor in one place. Editing still works via Cursor plus
vscode-neovim's built-in vim motions. Do not add per-plugin `cond` for the vscode
case; the global default already covers new plugins. (If you ever need a specific
plugin to load under Cursor, give that one spec an explicit `cond` to override.)

**Why is blink.cmp the only completion engine (no nvim-cmp)?**

nvim-cmp was fully removed in favor of blink.cmp. Do not re-add `cmp-nvim-lsp` or
a manual `capabilities` table in `lspconfig.lua`: **blink.cmp auto-registers its
completion capabilities globally via `vim.lsp.config('*', ...)` on Neovim 0.11+**,
so servers pick them up with no wiring. Completion auto-brackets come from blink's
`completion.accept.auto_brackets` (not an nvim-autopairs `confirm_done` hook —
autopairs only handles typed-bracket pairing now). The `lazydev` completion source
lives in blink's `sources.providers` (`module = 'lazydev.integrations.blink'`,
`score_offset = 100`), not in a cmp source list.

**Why does obsidian.nvim use the `obsidian-nvim` org and no completion plugin dependency?**

`epwalsh/obsidian.nvim` is unmaintained and only supported completion through
nvim-cmp. This fork uses the maintained community fork `obsidian-nvim/obsidian.nvim`,
which provides completion via **in-process LSP** — blink's built-in `lsp` source
picks it up automatically for `[[` links, `#` tags, etc. No completion plugin needs
to be a dependency, and there is no `completion.nvim_cmp`/`completion.blink` opt.

**Plugin org renames (keep current):** mason repos are `mason-org/mason.nvim` and
`mason-org/mason-lspconfig.nvim` (was `williamboman/*`); mini is `nvim-mini/mini.nvim`
(was `echasnovski/mini.nvim`). Old paths still redirect on GitHub, but a rename must
be applied in **all** files at once (e.g. mason is referenced in both `lspconfig.lua`
and `debug.lua`) or Lazy sees duplicate specs.

**Indent auto-detection is `guess-indent.nvim`, not `vim-sleuth`.** Matches upstream.
Only one indent-blankline spec should exist (`kickstart/plugins/indent_line.lua`);
a duplicate previously lived in `custom/plugins/` and was loaded twice via the
`custom.plugins` import.
