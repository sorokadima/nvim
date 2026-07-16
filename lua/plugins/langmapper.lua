-- Робить кейбінди Neovim/LazyVim робочими на українській розкладці.
-- https://github.com/Wansmer/langmapper.nvim
return {
  "Wansmer/langmapper.nvim",
  lazy = false,
  priority = 1000, -- має вантажитись найпершим, щоб обгорнути функції keymap
  config = function()
    -- Розкладка: українська -> англійська (за фізичним розташуванням клавіш)
    local function escape(str)
      return vim.fn.escape(str, [[;,."|\]])
    end

    local en = [[`qwertyuiop[]asdfghjkl;'zxcvbnm]]
    local uk = [['йцукенгшщзхїфівапролджєячсмить]]
    local en_shift = [[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
    local uk_shift = [[₴ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄЯЧСМИТЬБЮ]]

    vim.opt.langmap = vim.fn.join({
      escape(uk_shift) .. ";" .. escape(en_shift),
      escape(uk) .. ";" .. escape(en),
    }, ",")

    -- langmapper.nvim за замовчуванням має fallback-layout лише для
    -- російської (`ru`) — без цього блоку hack_keymap створював би
    -- дубльовані <leader>-кейбінди тільки під російську розкладку,
    -- а не під українську, тому <leader>gg і подібні не спрацьовували б.
    require("langmapper").setup({
      hack_keymap = true, -- перекладає й ліниво-завантажені мапінги плагінів
      use_layouts = { "ua" },
      layouts = {
        ua = {
          id = "com.apple.keylayout.Ukrainian-PC",
          layout = "₴ЙЦУКЕНГШЩЗХЇ|ФІВАПРОЛДЖЄЯЧСМИТЬБЮ?'йцукенгшщзхїфівапролджєячсмитьбю/",
        },
      },
    })
    require("langmapper").hack_get_keymap()

    -- Перемапувати вже зареєстровані кейбінди після того, як LazyVim їх виставив
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        require("langmapper").automapping({ global = true, buffer = true })
      end,
    })
  end,
}
