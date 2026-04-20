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
			indent = { enable = true },
			ensure_installed = {"c", "lua", "javascript", "html", "css", "python"},
			fold = { enable = true },
		})

        -- Tree-sitter für bereits geöffnete Buffer erzwingen
        vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
            callback = function(args)
                local buf = args.buf
                if vim.bo[buf].filetype ~= "" then
                    pcall(vim.treesitter.start, buf)
                end
            end,
        })
	end,
}
