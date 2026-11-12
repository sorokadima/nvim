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

    -- LSP вішає свої gd/gr/K на LspAttach, тобто вже ПІСЛЯ VeryLazy. Дублюємо
    -- буферні кейбінди під українські клавіші самі: automapping тут не спрацьовує.
    local en_chars = vim.fn.split([[`qwertyuiop[]asdfghjkl;'zxcvbnm]], "\\zs")
    local uk_chars = vim.fn.split([['йцукенгшщзхїфівапролджєячсмить]], "\\zs")
    local EN_SHIFT = vim.fn.split([[~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM]], "\\zs")
    local UK_SHIFT = vim.fn.split([[₴ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄЯЧСМИТЬ]], "\\zs")

    local to_uk = {}
    for i, c in ipairs(en_chars) do
      to_uk[c] = uk_chars[i]
    end
    for i, c in ipairs(EN_SHIFT) do
      to_uk[c] = UK_SHIFT[i]
    end

    local function translate(lhs)
      if lhs:find("<") then
        return nil
      end
      local out, changed = {}, false
      for _, ch in ipairs(vim.fn.split(lhs, "\\zs")) do
        local mapped = to_uk[ch]
        if mapped then
          changed = true
        end
        table.insert(out, mapped or ch)
      end
      return changed and table.concat(out) or nil
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(args.buf) then
            return
          end
          for _, mode in ipairs({ "n", "v", "x" }) do
            for _, km in ipairs(vim.api.nvim_buf_get_keymap(args.buf, mode)) do
              local uk_lhs = translate(km.lhs)
              if uk_lhs then
                vim.keymap.set(mode, uk_lhs, km.callback or km.rhs, {
                  buffer = args.buf,
                  desc = km.desc,
                  silent = km.silent == 1,
                  noremap = km.noremap == 1,
                })
              end
            end
          end
        end)
      end,
    })
  end,
}
