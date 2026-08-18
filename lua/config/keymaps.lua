-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Подвійний Esc — швидкий вихід з термінал-режиму в Normal (скрол/копіювання).
-- Одинарний Esc і далі йде напряму у вкладену програму (lazygit, fzf, nested nvim тощо).
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Вийти з термінал-режиму" })

-- Надійний вихід з термінал-режиму, що не залежить від Esc.
-- Потрібен, бо Claude Code сам перехоплює Esc, і подвійний Esc до нього не завжди встигає.
vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { desc = "Вийти з термінал-режиму (Ctrl-q)" })

-- Корінь проєкту кешуємо при першому виклику, а не рахуємо щоразу.
-- LazyVim.root() залежить від поточного буфера — у різних вкладках з файлами
-- з різних підпапок монорепо він давав різний шлях, і Snacks (що ключує
-- термінал по cmd+cwd) через це відкривав НОВИЙ Claude/термінал на кожній
-- вкладці замість перевикористання того самого.
local project_root
local function root()
  project_root = project_root or LazyVim.root()
  return project_root
end

-- Snacks за замовчуванням малює терміналу рамку лише зверху ("top"),
-- через що вікно зливається з чорним фоном по боках і знизу. Просимо повну рамку.
local term_win = { position = "float", border = "rounded" }

-- Швидкий запуск Claude Code у плаваючому терміналі (toggle тим самим хоткеєм)
vim.keymap.set("n", "<leader>ac", function()
  Snacks.terminal("claude", { cwd = root(), win = term_win })
end, { desc = "Claude Code (float)" })

-- Той самий toggle, але для звичайного shell (без claude)
vim.keymap.set("n", "<leader>at", function()
  Snacks.terminal(nil, { cwd = root(), win = term_win })
end, { desc = "Terminal (float)" })
