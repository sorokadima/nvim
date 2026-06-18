return {
  -- Disable default LazyVim theme
  { "folke/tokyonight.nvim", enabled = false },

  -- Install Catppuccin theme
  { "catppuccin/nvim", name = "catppuccin" },

  -- Set it as default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
