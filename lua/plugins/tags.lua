-- Навігація "провалитися в означення" БЕЗ мовних серверів.
--
-- Ідея: universal-ctags один раз проходить по файлах проєкту й пише індекс
-- (файл tags) — просто текстова табличка "ім'я -> файл + рядок". Це не
-- інтерпретація і не компіляція коду, тому воно не гріє ноут: індексація
-- йде у фоні окремим процесом, а сам Neovim під час стрибка лише читає
-- готовий файл. Одна утиліта покриває ~150 мов, тож нічого окремого під
-- кожну мову ставити не треба.
--
-- Ціна: переходи неточні. ctags не розуміє скоупи й типи, тому на однакові
-- імена дасть список кандидатів, а локальні змінні часто взагалі не бачить.
-- Це свідомий компроміс — див. smart_goto нижче, там є запасні варіанти.

-- Homebrew-версія ctags. У macOS в /usr/bin лежить древній BSD ctags, який
-- гутентаг не вміє готувати; фіксуємо шлях явно, бо GUI-запуск Neovim може
-- не побачити brew-шляхи у PATH.
local function ctags_bin()
  for _, p in ipairs({ "/opt/homebrew/bin/ctags", "/usr/local/bin/ctags" }) do
    if vim.fn.executable(p) == 1 then
      return p
    end
  end
  return "ctags"
end

-- Перехід до означення слова під курсором, від точного до грубого:
--   1) LSP, якщо для цього буфера він раптом є (lua тощо);
--   2) tags — функції, методи, класи, константи, поля;
--   3) вбудований gd — шукає локальне оголошення в межах поточної функції,
--      саме те, чого ctags не вміє;
--   4) grep по проєкту — коли нічого не знайшлося, показуємо всі згадки.
local function smart_goto()
  if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" }) > 0 then
    vim.lsp.buf.definition()
    return
  end

  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end

  -- taglist з іменем поточного файлу сортує так, щоб свій файл був вище.
  local pattern = "^" .. vim.fn.escape(word, [[\/.*$^~[]]) .. "$"
  local tags = vim.fn.taglist(pattern, vim.fn.expand("%:p"))
  if #tags > 0 then
    vim.cmd("normal! m'") -- щоб <C-o> повернув назад
    if #tags == 1 then
      -- Один збіг — стрибаємо мовчки (tjump ще й веде tag stack для <C-t>).
      if pcall(vim.cmd, { cmd = "tjump", args = { word } }) then
        return
      end
    else
      -- Кілька однакових імен: ctags не знає, яке з них наше, тому
      -- показуємо їх у picker'і з превʼю — вибираєш очима.
      if pcall(Snacks.picker.tags, { search = pattern }) then
        return
      end
    end
  end

  local before = vim.api.nvim_win_get_cursor(0)
  if pcall(vim.cmd, "normal! gd") and not vim.deep_equal(before, vim.api.nvim_win_get_cursor(0)) then
    return
  end

  Snacks.picker.grep_word()
end

return {
  {
    "ludovicchabant/vim-gutentags",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.gutentags_ctags_executable = ctags_bin()

      -- Індексуємо лише те, що схоже на корінь проєкту, інакше gutentags
      -- може взятися за $HOME і справді підвісити машину.
      vim.g.gutentags_add_default_project_roots = false
      vim.g.gutentags_project_root = {
        ".git",
        ".hg",
        ".svn",
        "package.json",
        "go.mod",
        "Cargo.toml",
        "pyproject.toml",
        "composer.json",
        "Gemfile",
        "pom.xml",
        "build.gradle",
        "Makefile",
      }

      -- Файли tags складаємо в кеш, а не в репозиторій — щоб не засмічувати
      -- робочі дерева й не ловити їх у git status.
      vim.g.gutentags_cache_dir = vim.fn.stdpath("cache") .. "/ctags"

      vim.g.gutentags_generate_on_new = true
      vim.g.gutentags_generate_on_missing = true
      vim.g.gutentags_generate_on_write = true
      vim.g.gutentags_generate_on_empty_buffer = false

      -- Список файлів беремо з ripgrep: він поважає .gitignore, тому
      -- node_modules/vendor/build відпадають самі й індекс лишається дрібним.
      vim.g.gutentags_file_list_command = {
        markers = {
          [".git"] = "rg --files --hidden --glob '!.git/*'",
        },
      }

      vim.g.gutentags_ctags_extra_args = {
        "--tag-relative=yes",
        "--fields=+ailmnS",
        "--extras=+q", -- ще й кваліфіковані імена: Class::method
      }

      -- Для проєктів без .git (там rg-команда не спрацює) відсікаємо сміття вручну.
      vim.g.gutentags_ctags_exclude = {
        ".git",
        "node_modules",
        "vendor",
        "dist",
        "build",
        "target",
        ".venv",
        "venv",
        "__pycache__",
        ".next",
        ".nuxt",
        "*.min.js",
        "*.min.css",
        "*.lock",
        "*.map",
      }
    end,
    keys = {
      { "gd", smart_goto, desc = "Перейти до означення (LSP/tags/grep)" },
      -- <leader>st у LazyVim уже зайнятий (Todo), тому символи вішаємо на sy.
      { "<leader>sy", function() Snacks.picker.tags() end, desc = "Символи проєкту (tags)" },
    },
  },
}
