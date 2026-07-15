return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      -- This function gets run when an LSP attaches to a particular buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = false,
      }

      -- Completion capabilities are contributed by blink.cmp, which registers
      -- them globally via `vim.lsp.config('*', ...)` on Neovim 0.11+. No manual
      -- capabilities wiring is needed here.

      -- Servers
      local servers = {
        -- example servers
        ruff = { init_options = { settings = {} } },
        rust_analyzer = {},
        bashls = {},
        eslint = {},
        cssls = {},
        yamlls = {},
        jsonls = {},
        ts_ls = {},
        helm_ls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = {
                disable = { 'missing-fields' },
                globals = { 'vim' },
              },
            },
          },
        },

        -- BasedPyright entry (robust): explicit cmd + python.analysis shape + micromamba handling
        pyright = (function()
          local mamba_root = os.getenv("MAMBA_ROOT_PREFIX") or ""
          local conda_env = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("MAMBA_DEFAULT_ENV") or ""
          local venv_path = (mamba_root ~= "" and (mamba_root .. "/envs")) or ""
          local python_path = ""
          if venv_path ~= "" and conda_env ~= "" then
            python_path = venv_path .. "/" .. conda_env .. "/bin/python"
          end

          return {
            -- If you want to run the built-in pyright binary, remove/replace the cmd line below.
            cmd = { "basedpyright-langserver", "--stdio" }, -- optional: override to use BasedPyright
            settings = {
              pyright = { disableOrganizeImports = true },
              python = {
                analysis = {
                  typeCheckingMode = "standard",
                  pythonVersion = "3.13",
                  autoSearchPaths = true,
                  useLibraryCodeForTypes = true,
                  diagnosticSeverityOverrides = { reportMissingTypeStubs = "none" },
                  venvPath = venv_path,
                  venv = conda_env,
                  pythonPath = (python_path ~= "" and python_path) or nil,
                },
              },
            },
          }
        end)(),
      }

      -- Disable hover from ruff to prefer pyright based hover
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client == nil then return end
          if client.name == 'ruff' then
            client.server_capabilities.hoverProvider = false
          end
        end,
        desc = 'LSP: Disable hover capability from Ruff',
      })

      -- Ensure installed via mason-tool-installer if desired
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Enable servers via Neovim's native LSP API (0.11+).
      --
      -- nvim-lspconfig is no longer the LSP driver: it now only ships the
      -- per-server `lsp/<name>.lua` definitions (default `cmd`, `filetypes`,
      -- `root_markers`) that `vim.lsp.enable` reads. `vim.lsp.config(name, ...)`
      -- deep-merges our overrides onto that definition (and onto blink.cmp's '*'
      -- capabilities); `vim.lsp.enable(name)` starts the server on matching buffers.
      --
      -- mason-lspconfig stays installed for its package-name mapping (used by
      -- mason-tool-installer, e.g. `lua_ls` -> `lua-language-server`), but its
      -- `setup`/`handlers` path is intentionally unused.
      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },
}
