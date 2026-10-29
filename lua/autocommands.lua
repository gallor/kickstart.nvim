-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'FocusLost' }, {
  desc = 'Auto Save buffers when focus is moved',
  command = 'silent! wa',
})

vim.cmd [[autocmd ColorScheme * highlight LineNr guifg=#9da0b4]]

-- Quit Neovim when the last file buffer is closed and only Neo-tree is left.
-- :bdelete on the last buffer drops an empty [No Name] window next to Neo-tree
-- rather than making Neo-tree the last window, so neo-tree's own
-- `close_if_last_window` never fires. Trigger on BufDelete (not BufEnter) so this
-- only runs when a buffer was actually closed, never when opening the tree on a
-- fresh scratch session.
vim.api.nvim_create_autocmd('BufDelete', {
  desc = 'Quit when the last file buffer is closed and only Neo-tree remains',
  group = vim.api.nvim_create_augroup('kickstart-quit-with-neotree', { clear = true }),
  callback = function()
    vim.schedule(function()
      local file_bufs = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ''
      end, vim.api.nvim_list_bufs())
      if #file_bufs > 0 then
        return
      end
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'neo-tree' then
          vim.cmd 'qa'
          return
        end
      end
    end)
  end,
})
