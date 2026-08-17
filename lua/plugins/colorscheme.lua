return {
  -- Disable default LazyVim theme
  { "folke/tokyonight.nvim", enabled = false },

  -- Catppuccin лишається встановленим, але не активний
  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  -- Modus Vivendi (порт вбудованої emacs-теми) — чорний фон, мінімум синього
  { "miikanissi/modus-themes.nvim", priority = 1000, lazy = false },

  -- Set it as default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "modus_vivendi",
    },
  },
}
