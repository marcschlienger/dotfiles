-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require('lazy').setup({
  -- UI enhancements and colors
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
    config = function()
      require('plugins.nvim-lualine')
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('plugins.catppuccin')
    end,
  },
  {
    'sainnhe/everforest',
    priority = 1000,
  },
  { 
    'ellisonleao/gruvbox.nvim', 
    priority = 1000,
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('plugins.tokyonight')
    end,
  },
  {
    'mcchrish/zenbones.nvim',
    dependencies = { 'rktjmp/lush.nvim' },
    priority = 1000,
  },

  -- Semantic language support
  { 'neovim/nvim-lspconfig' },
  {
    'hrsh7th/nvim-cmp',          -- Autocompletion
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',    -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',      -- Buffer source for nvim-cmp
      'hrsh7th/cmp-path',        -- Path source for nvim-cmp
      'hrsh7th/cmp-cmdline',     -- Cmdline source for nvim-cmp
      'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
    },
  },
  { 'L3MON4D3/LuaSnip' },

  -- Syntactic language support
  {
    'lervag/vimtex',
    config = function()
      require('plugins.vimtex')
    end,
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('plugins.telescope')
    end,
  },
  {
    'notjedi/nvim-rooter.lua',
    config = function()
      require('plugins.nvim-rooter')
    end,
  },

  -- Git
  { 'tpope/vim-fugitive' },
  { 'airblade/vim-gitgutter' },

  -- Editor enhancements
  { 'tpope/vim-commentary' },
})
