return {
  -- Autocomplete plugins
  { -- pypi packages
    'vrslev/cmp-pypi',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = 'toml',
  },

  { -- npm packages
    'David-Kunz/cmp-npm',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = 'json',
    opts = {},
    config = function()
      require('cmp-npm').setup {}
    end,
  },
  {
    {
      'tzachar/cmp-fuzzy-path',
      dependencies = { 'hrsh7th/nvim-cmp', 'tzachar/fuzzy.nvim' },
      config = function()
        local cmp = require 'cmp'
        cmp.setup {
          sources = cmp.config.sources {
            {
              name = 'fuzzy_path',
              option = {
                fd_cmd = { 'fdfind', '-d', '20', '-p' },
              },
            },
          },
        }
      end,
    },
  },
}
