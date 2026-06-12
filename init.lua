-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

  vim.keymap.set('n', '<leader>cp', function()
    local path = vim.fn.expand('%:p')  
    vim.fn.setreg('+', path)
    vim.notify('Copied: ' .. path)
  end, { noremap = true })

  vim.keymap.set('n', '<leader>cr', function()
    local path = vim.fn.expand('%')  -- відносний шлях
    vim.fn.setreg('+', path)
    vim.notify('Copied: ' .. path)
  end, { desc = "Copy relative file path" })

  vim.keymap.set('n', '<leader>cl', function()
    local path = vim.fn.expand('%') 
    local line = vim.fn.line('.')
    local result = path .. ':' .. line
    vim.fn.setreg('+', result) 
    vim.notify('Copied: ' .. result)
  end, { desc = "Copy file path with line number" })

