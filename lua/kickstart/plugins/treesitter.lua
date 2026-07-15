-- Treesitter: highlighting, indentation, and parser management.
--
-- nvim-treesitter has two incompatible lines:
--   * `main`   -- the rewrite. Compiles parsers by shelling out to the
--                `tree-sitter` CLI, and highlighting is driven manually via
--                `vim.treesitter.start()`. There is no `configs.setup()`.
--   * `master` -- the legacy line. Compiles generated C with `cc`/`gcc` (no
--                CLI needed) and configures highlight/indent through
--                `require('nvim-treesitter.configs').setup(opts)`.
--
-- We pick at startup based on whether a *working* `tree-sitter` CLI exists.
-- A machine can have the binary on PATH but unusable (e.g. Mason's prebuilt
-- CLI needs a newer glibc than the OS provides), so we actually execute it
-- rather than trusting `executable()`. This lets one config serve both a
-- CLI-capable machine (uses `main`) and one that can only build with `cc`
-- (falls back to `master`).

-- Parsers to always keep installed (shared by both branches).
local PARSERS = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }

--- Return true if a `tree-sitter` CLI can actually be executed.
local function treesitter_cli_works()
  local candidates = {}
  -- Prefer Mason's CLI if present, then anything on PATH.
  local mason_cli = vim.fn.stdpath 'data' .. '/mason/bin/tree-sitter'
  if vim.fn.executable(mason_cli) == 1 then
    table.insert(candidates, mason_cli)
  end
  if vim.fn.executable 'tree-sitter' == 1 then
    table.insert(candidates, 'tree-sitter')
  end

  for _, bin in ipairs(candidates) do
    -- pcall guards a binary that fails to even start (bad interpreter/glibc).
    local ok, res = pcall(function()
      return vim.system({ bin, '--version' }, { text = true }):wait(2000)
    end)
    if ok and res and res.code == 0 then
      return true
    end
  end
  return false
end

if treesitter_cli_works() then
  -- ============================================================
  -- `main` branch: CLI builds parsers, manual per-buffer attach.
  -- ============================================================
  return {
    {
      'nvim-treesitter/nvim-treesitter',
      branch = 'main',
      lazy = false, -- load at startup so the FileType autocmd is registered early
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter').install(PARSERS)

        ---@param buf integer
        ---@param language string
        local function try_attach(buf, language)
          -- Load the parser; bail if none exists for this language.
          if not vim.treesitter.language.add(language) then
            return
          end

          -- Highlighting and other treesitter features.
          vim.treesitter.start(buf, language)

          -- Treesitter-based indentation, when an indents query exists.
          -- Without one, indentexpr falls back to Vim's built-in rules.
          if vim.treesitter.query.get(language, 'indents') ~= nil then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        local available_parsers = require('nvim-treesitter').get_available()

        local function attach(buf, filetype)
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          local installed = require('nvim-treesitter').get_installed 'parsers'
          if vim.tbl_contains(installed, language) then
            try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            -- Auto-install a known parser, then attach once it lands.
            require('nvim-treesitter').install(language):await(function()
              try_attach(buf, language)
            end)
          else
            -- Parser may exist outside nvim-treesitter's registry; try anyway.
            try_attach(buf, language)
          end
        end

        vim.api.nvim_create_autocmd('FileType', {
          group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
          callback = function(args)
            attach(args.buf, args.match)
          end,
        })

        -- Attach to buffers already open when this config runs (e.g. files
        -- passed on the command line, whose FileType fired before setup).
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) then
            attach(buf, vim.bo[buf].filetype)
          end
        end
      end,
    },
  }
end

-- ============================================================
-- `master` branch fallback: builds parsers with cc, configs.setup API.
-- Used when no working `tree-sitter` CLI is available.
-- ============================================================
return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = PARSERS,
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as
        -- Ruby) for indent rules. If you hit weird indenting, add the language
        -- to both this list and the indent `disable` list below.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby', 'python' } },
    },
  },
}
