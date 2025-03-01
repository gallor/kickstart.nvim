-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Map semicolon to colon
vim.keymap.set('n', ';', ':', { desc = 'Map semicolon to colon' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Enable being able to move up and down in the same line
vim.keymap.set('n', 'k', 'gk', { desc = 'Move up within the same line of text' })
vim.keymap.set('n', 'j', 'gj', { desc = 'Move down within the same line of text' })

-- Map switching between buffers easier
vim.keymap.set('n', '<leader>h', '<silent> <cmd>bprevious<CR>', { desc = 'Open previous buffer' })
vim.keymap.set('n', '<leader>l', '<silent> <cmd>bnext<CR>', { desc = 'Open next buffer' })

-- Map end of line and beginning of line
vim.keymap.set('n', 'H', '^', { desc = 'Move to beginning of line' })
vim.keymap.set('n', 'L', '$', { desc = 'Move to end of line' })
