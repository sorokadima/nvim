-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Подвійний Esc — швидкий вихід з термінал-режиму в Normal (скрол/копіювання).
-- Одинарний Esc і далі йде напряму у вкладену програму (lazygit, fzf, nested nvim тощо).
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Вийти з термінал-режиму" })

-- Швидкий запуск Claude Code у плаваючому терміналі (toggle тим самим хоткеєм)
vim.keymap.set("n", "<leader>ac", function()
  Snacks.terminal("claude", { cwd = LazyVim.root(), win = { position = "float" } })
end, { desc = "Claude Code (float)" })
