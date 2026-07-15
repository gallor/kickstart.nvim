-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Handles pairing of brackets/quotes as you type. Completion auto-brackets
  -- (adding `(` after accepting a function) are handled by blink.cmp's
  -- `completion.accept.auto_brackets`, so no completion-engine hook is needed.
  opts = {},
}
