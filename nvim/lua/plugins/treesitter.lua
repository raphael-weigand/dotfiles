return {
	"neovim-treesitter/nvim-treesitter",
    dependencies = { 'neovim-treesitter/treesitter-parser-registry' },
	build = ":TSUpdate",
    priority = 1000,
	lazy = false,
	config = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true, disable = {"c"} },
			ensure_installed = {"c", "lua", "javascript", "html", "css", "python"},
			fold = { enable = true, disable={"c"}},
		})

        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldlevel = 99
        vim.opt.foldenable = true
	end,
}
