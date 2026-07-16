return {
  {
    'nvim-mini/mini.nvim',
    version = false,
    dependencies = {
      'lewis6991/gitsigns.nvim',
    },
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup({ n_lines = 500 })

      -- Trigger Commenting
      require('mini.comment').setup({
        version = '*',
        -- mappings = {
        --   comment = '<leader>c<space>',
        --   comment_line = '<leader>c<space>',
        --   comment_visual = '<leader>c<space>',
        --   textobject = '',
        -- },
      })

      -- UI-oriented modules are skipped under vscode-neovim (Cursor), which
      -- owns the statusline, minimap, and git diff/hunk display. mini.diff in
      -- particular only attaches to normal file buffers, so its hunk actions
      -- error ("Buffer N is not enabled") on Cursor-managed buffers.
      local ui_enabled = not vim.g.vscode

      -- Git diff and hunk comparison.
      if ui_enabled then
        -- Belt-and-suspenders: even when setup runs (e.g. if the vscode gate
        -- above ever fails to catch), disable mini.diff's operator/textobject
        -- mappings. The "Buffer N is not enabled" crash only reaches us through
        -- these (`gh`/`gH` apply/reset/textobject, `[h`/`]h` goto), which assume
        -- an enabled buffer. gitsigns already provides hunk staging/navigation,
        -- so nothing is lost; mini.diff keeps its visual signs/overlay.
        require('mini.diff').setup {
          mappings = {
            apply = '',
            reset = '',
            textobject = '',
            goto_first = '',
            goto_prev = '',
            goto_next = '',
            goto_last = '',
          },
        }
      end

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      -- require('mini.surround').setup({
      --   mappings = {
      --     add = 'dsa', -- Add surrounding in Normal and Visual modes
      --     delete = 'dsd', -- Delete surrounding
      --     find = 'dsf', -- Find surrounding (to the right)
      --     find_left = 'dsF', -- Find surrounding (to the left)
      --     highlight = 'dsh', -- Highlight surrounding
      --     replace = 'dsr', -- Replace surrounding
      --
      --     suffix_last = 'l', -- Suffix to search with "prev" method
      --     suffix_next = 'n', -- Suffix to search with "next" method
      --   },
      -- })

      if ui_enabled then
        local MiniMap = require 'mini.map'
        MiniMap.setup({
          integrations = {
            MiniMap.gen_integration.gitsigns(),
            MiniMap.gen_integration.builtin_search()
          },
          symbols = {
            encode = MiniMap.gen_encode_symbols.dot("4x2"),
          },
        })

        vim.keymap.set('n', '<leader>mc', MiniMap.close, { desc = "Close MiniMap" })
        vim.keymap.set('n', '<leader>mf', MiniMap.toggle_focus, { desc = "Toggle and Focus MiniMap" })
        vim.keymap.set('n', '<leader>mo', MiniMap.open, { desc = "Open MiniMap" })
        vim.keymap.set('n', '<leader>mr', MiniMap.refresh, { desc = "Refresh MiniMap" })
        vim.keymap.set('n', '<leader>ms', MiniMap.toggle_side, { desc = "Toggle MiniMap Side" })
        vim.keymap.set('n', '<leader>mt', MiniMap.toggle, { desc = "Toggle MiniMap" })

        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        local statusline = require 'mini.statusline'
        -- set use_icons to true if you have a Nerd Font
        statusline.setup({ use_icons = vim.g.have_nerd_font })

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
          return '%2l:%-2v'
        end
      end

      -- ... and there is more!
      --  Check out: https://github.com/nvim-mini/mini.nvim
    end,
  },
}
