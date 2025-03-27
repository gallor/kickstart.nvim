return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      theme = vim.g.colors_name,
      refresh = {
        statusline = 1000,
      },
    },
  },
}
