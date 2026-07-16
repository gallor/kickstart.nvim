return {
  'nvim-lualine/lualine.nvim',
  cond = not vim.g.vscode, -- Cursor/vscode-neovim owns the statusline
  dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/trouble.nvim' },
  config = function()
    local trouble = require 'trouble'
    local lualine = require 'lualine'

    local symbols = trouble.statusline {
      mode = 'lsp_document_symbols',
      groups = {},
      title = false,
      filter = { range = true },
      format = '{kind_icon}{symbol.name:Normal}',
      -- The following line is needed to fix the background color
      -- Set it to the lualine section you want to use
      hl_group = 'lualine_c_normal',
    }

    lualine.setup {
      options = {
        theme = vim.g.color_name,
        refresh = {
          statusline = 1000,
        },
      },
      sections = {
        lualine_c = {
          symbols.get,
        },
      },
      extensions = { 'trouble' },
    }
  end,
}
