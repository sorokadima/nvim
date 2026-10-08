-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.title = true
vim.opt.titlestring = "[%{fnamemodify(getcwd(), ':t')}] %t - NeoVim"

-- '100 (дефолт) = Projects picker (Snacks) бачить лише git-корені останніх
-- 100 відкритих файлів — замало, щоб у списку лишались старі проєкти.
vim.opt.shada:append("'1000")

-- Дозволяє нормальні/leader-команди (dd, yy, gg, <leader>e тощо) на
-- українській розкладці: кириличний символ трактується як латинська
-- літера з тієї ж фізичної позиції клавіші. Insert mode не зачіпає.
local ua_lower = "йцукенгшщзхїфівапролджєячсмить"
local en_lower = "qwertyuiop[]asdfghjkl;'zxcvbnm"

vim.opt.langmap = table.concat({
  ua_lower:upper() .. ";" .. en_lower:upper(),
  ua_lower .. ";" .. en_lower,
}, ",")
