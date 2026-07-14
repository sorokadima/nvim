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

-- Автоперемикання розкладки на англійську у вбудованих терміналах (lazygit тощо),
-- бо в термінальному режимі клавіші йдуть напряму в програму повз langmapper.
-- Потребує CLI `macism` (brew install macism).
if vim.fn.executable("macism") == 1 then
  local en = "com.apple.keylayout.ABC"
  local saved_layout = nil
  local grp = vim.api.nvim_create_augroup("term_layout_switch", { clear = true })

  vim.api.nvim_create_autocmd("TermEnter", {
    group = grp,
    desc = "Перемкнути розкладку на ABC при вході в термінал",
    callback = function()
      saved_layout = vim.trim(vim.fn.system({ "macism" }))
      if saved_layout ~= "" and saved_layout ~= en then
        vim.fn.jobstart({ "macism", en })
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "TermLeave", "TermClose" }, {
    group = grp,
    desc = "Повернути попередню розкладку при виході з термінала",
    callback = function()
      if saved_layout and saved_layout ~= "" and saved_layout ~= en then
        vim.fn.jobstart({ "macism", saved_layout })
      end
    end,
  })
end
