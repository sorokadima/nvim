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
-- Стиль "minimal" (дефолт для плаваючих вікон Snacks) вимикає номери рядків —
-- вмикаємо назад, щоб у Normal-режимі термінала можна було переходити по номеру (:42, 42G).
local term_win = { position = "float", border = "rounded", wo = { number = true } }

-- Ховає всі відкриті плаваючі термінали, крім вказаного — щоб при перемиканні
-- вони не стекались одне на одному (Claude і shell — різні snacks-термінали).
local function hide_other_terminals(except)
  for _, t in ipairs(Snacks.terminal.list()) do
    if t ~= except and t:win_valid() then
      t:hide()
    end
  end
end

-- Перемикач на конкретний термінал: якщо він і так єдиний видимий (у фокусі) — toggle
-- (сховати), інакше сховати інший термінал і показати/сфокусувати цей.
local function switch_terminal(cmd)
  return function()
    local term, created = Snacks.terminal.get(cmd, { cwd = root(), win = term_win })
    if not created and term:win_valid() and vim.api.nvim_get_current_buf() == term.buf then
      term:hide()
      return
    end
    hide_other_terminals(term)
    term:show()
    term:focus()
  end
end

local switch_to_claude = switch_terminal("claude")
local switch_to_shell = switch_terminal(nil)

-- Швидкий запуск Claude Code у плаваючому терміналі (toggle тим самим хоткеєм)
vim.keymap.set("n", "<leader>ac", switch_to_claude, { desc = "Claude Code (float)" })

-- Той самий toggle, але для звичайного shell (без claude)
vim.keymap.set("n", "<leader>at", switch_to_shell, { desc = "Terminal (float)" })

-- Швидке перемикання між Claude і звичайним терміналом прямо з термінал-режиму,
-- без потреби спершу виходити в Normal через Ctrl-q: Ctrl-q c / Ctrl-q t.
-- Сам одинарний Ctrl-q (без продовження) далі працює як вихід у Normal (мапінг вище).
vim.keymap.set("t", "<C-q>c", switch_to_claude, { desc = "Перемкнутись на Claude Code" })
vim.keymap.set("t", "<C-q>t", switch_to_shell, { desc = "Перемкнутись на звичайний термінал" })
