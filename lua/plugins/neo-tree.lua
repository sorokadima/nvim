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
          -- gs — grep по вмісту файлів у папці під курсором
          ["gs"] = "grep_in_node",
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
        grep_in_node = function(state)
          local node = state.tree:get_node()
          if not node then
            return
          end

          -- Якщо це файл — шукаємо в його батьківській папці, якщо папка — в ній
          local path = node.type == "directory" and node.path or vim.fn.fnamemodify(node.path, ":h")

          local ok, picker = pcall(require, "snacks.picker")
          if ok then
            picker.grep({ dirs = { path } })
            return
          end

          -- Fallback на telescope, якщо раптом snacks не доступний
          ok, _ = pcall(require, "telescope.builtin")
          if ok then
            require("telescope.builtin").live_grep({ search_dirs = { path } })
            return
          end

          vim.notify("Не знайдено підтримуваний picker (snacks/telescope)", vim.log.levels.WARN)
        end,
      },
    },
  },
}
