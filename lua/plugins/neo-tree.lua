return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    -- Відкрити/закрити neo-tree зліва
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer NeoTree (toggle)" },
    -- Відкрити neo-tree і сфокусуватись на поточному файлі
    { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Explorer NeoTree (reveal)" },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = true,
        hide_gitignored = true,
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true,
      },
      window = {
        mappings = {
          -- H перемикає показ dotfiles + gitignored разом
          ["H"] = "toggle_all_hidden",
        },
      },
      commands = {
        toggle_all_hidden = function(state)
          local fi = state.filtered_items
          local show_hidden = fi.hide_dotfiles

          fi.hide_dotfiles = not show_hidden
          fi.hide_gitignored = not show_hidden
          fi.visible = show_hidden

          require("neo-tree.sources.manager").refresh(state.name)
        end,
      },
    },
  },
}
