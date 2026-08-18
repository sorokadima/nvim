return {
  -- Disable default LazyVim theme
  { "folke/tokyonight.nvim", enabled = false },

  -- Catppuccin лишається встановленим, але не активний
  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  -- Modus Vivendi (порт вбудованої emacs-теми) — чорний фон, мінімум синього
  {
    "miikanissi/modus-themes.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      -- Рамка на всіх плаваючих вікнах (LSP hover, which-key, термінал тощо)
      vim.o.winborder = "rounded"

      -- Плаваючі вікна (модалки) — той самий чорний фон, що й основний, з рамкою для відділення.
      -- modus_vivendi за замовчуванням дає float-у інший фон (bg_active, #303030) — робимо його чорним.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "modus_vivendi",
        desc = "Чорний фон для плаваючих вікон з контрастною рамкою",
        callback = function()
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000", fg = "#ffffff" })
          vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#000000", fg = "#C4C4C4" })
          vim.api.nvim_set_hl(0, "FloatTitle", { bg = "#000000", fg = "#C4C4C4", bold = true })
        end,
      })
    end,
  },

  -- Set it as default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "modus_vivendi",
    },
  },
}
