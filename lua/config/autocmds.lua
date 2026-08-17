-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  command = "silent! wall",
  desc = "Auto-save when focus is lost",
})

-- Автопідхоплення змін файлів з диска (напр. від AI-агента в термінал-спліті)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  desc = "checktime: підхопити зовнішні зміни файлу",
  command = "checktime",
})

-- Автоперемикання розкладки на англійську у вбудованих терміналах (lazygit тощо),
-- бо в термінальному режимі клавіші йдуть напряму в програму повз langmapper.
-- Потребує CLI `macism` (brew install macism).
if vim.fn.executable("macism") == 1 then
  local en = "com.apple.keylayout.ABC"
  local grp = vim.api.nvim_create_augroup("term_layout_switch", { clear = true })
  -- st.forced=true, поки ми "всередині" термінала (з можливою вкладеністю) —
  -- саме тому saved запам'ятовуємо лише один раз, при першому вході.
  local st = { saved = nil, forced = false }

  local function force_en()
    local current = vim.trim(vim.fn.system({ "macism" }))
    if not st.forced then
      st.saved = current
      st.forced = true
    end
    if current ~= en then
      vim.fn.jobstart({ "macism", en })
    end
  end

  local function restore()
    if st.forced then
      st.forced = false
      if st.saved and st.saved ~= "" and st.saved ~= en then
        vim.fn.jobstart({ "macism", st.saved })
      end
    end
  end

  vim.api.nvim_create_autocmd("TermEnter", {
    group = grp,
    desc = "Перемкнути розкладку на ABC при вході в термінал",
    callback = force_en,
  })

  vim.api.nvim_create_autocmd({ "TermLeave", "TermClose" }, {
    group = grp,
    desc = "Повернути попередню розкладку при виході з термінала",
    callback = restore,
  })

  -- TermEnter стріляє лише один раз, при вході в terminal-mode. Якщо
  -- користувач вручну змінив розкладку в macOS і повернув фокус на те саме
  -- вже відкрите вікно термінала (не виходячи з terminal-mode) — TermEnter
  -- вдруге не спрацює. Перестраховуємось через FocusGained/BufEnter/WinEnter.
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "WinEnter" }, {
    group = grp,
    desc = "Форсувати ABC при поверненні фокусу на вікно термінала",
    callback = function()
      if vim.bo.buftype == "terminal" then
        force_en()
      end
    end,
  })
end
