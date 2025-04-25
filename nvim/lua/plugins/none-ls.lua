return {
  "nvimtools/none-ls.nvim",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        -- LSPs: Defined in lsp-config.lua, install via :Mason

        -- Linters
        -- null_ls.builtins.diagnostics.eslint_d, -- Linter for JS
        null_ls.builtins.diagnostics.phpcs, -- Linter for PHP
        null_ls.builtins.diagnostics.pylint, -- Linter for Python 

        -- Formatters
        null_ls.builtins.formatting.stylua, -- Format lua files
        null_ls.builtins.formatting.prettier, -- Format JS files
        null_ls.builtins.formatting.black, -- Format Python files
        null_ls.builtins.formatting.isort, -- Organize Python imports
      },
    })

    vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
  end,
}
