-- Показує поточну розкладку клавіатури (EN/UA) у статуслайні lualine.
-- Опитує розкладку асинхронно через `macism`, тому ловить і ручні перемикання (Cmd+Space).
return {
  "nvim-lualine/lualine.nvim",
  optional = true,
  opts = function(_, opts)
    local names = {
      ["com.apple.keylayout.ABC"] = "EN",
      ["com.apple.keylayout.Ukrainian-PC"] = "UA",
    }

    -- Стан живе в _G, щоб не плодити таймери при перезавантаженні конфігу.
    local st = _G.__kbd_layout or { layout = "?" }
    _G.__kbd_layout = st

    if vim.fn.executable("macism") == 1 then
      if st.timer then
        pcall(function()
          st.timer:stop()
          st.timer:close()
        end)
      end
      st.timer = vim.uv.new_timer()
      st.timer:start(
        0,
        1000,
        vim.schedule_wrap(function()
          vim.system({ "macism" }, { text = true }, function(res)
            if res.code ~= 0 then
              return
            end
            local id = vim.trim(res.stdout or "")
            local label = names[id] or id:match("([^.]+)$") or "?"
            if label ~= st.layout then
              st.layout = label
              vim.schedule(function()
                vim.cmd("redrawstatus")
              end)
            end
          end)
        end)
      )
    end

    local component = {
      function()
        return "⌨ " .. st.layout
      end,
      cond = function()
        return vim.fn.executable("macism") == 1
      end,
      color = function()
        -- Українська підсвічується червоним, щоб було помітно.
        return { fg = st.layout == "UA" and "#f38ba8" or "#a6e3a1", gui = "bold" }
      end,
    }

    opts.sections = opts.sections or {}
    opts.sections.lualine_x = opts.sections.lualine_x or {}
    table.insert(opts.sections.lualine_x, 1, component)
  end,
}
