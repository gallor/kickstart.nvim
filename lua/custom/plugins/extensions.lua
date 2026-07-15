-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  -- Obsidian (maintained community fork; completion via in-process LSP,
  -- picked up automatically by blink.cmp's `lsp` source).
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*',
    lazy = true,
    event = {
      'BufReadPre ' .. vim.fn.expand '~' .. '/Documents/Vault/*.md',
      'BufNewFile ' .. vim.fn.expand '~' .. '/Documents/Vault/*.md',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      workspaces = {
        {
          name = 'Vault',
          path = '~/Documents/Vault',
        },
      },
      completion = {
        min_chars = 2,
      },
    },
  },

  {
    'rcarriga/nvim-notify',
    opts = {},
  },
}
