return {
  'akinsho/toggleterm.nvim',
  cond = not vim.g.vscode, -- Cursor owns the integrated terminal
  version = '*',
  config = true,
  opts = {
    open_mapping = [[<c-\>]]
  }
}
