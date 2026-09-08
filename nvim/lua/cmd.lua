-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Move selected lines while keeping the selection
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })

-- Build and quickfix
vim.keymap.set("n", "<leader>m", "<cmd>make<CR>", { desc = "Build with :make" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>", { desc = "Previous quickfix item" })

local function toggle_quickfix()
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 and win.loclist == 0 then
            vim.cmd.cclose()
            return
        end
    end

    vim.cmd.copen()
end

vim.keymap.set("n", "<leader>q", toggle_quickfix, { desc = "Toggle quickfix" })

-- Native terminal in a bottom split
local terminal_buf = nil

local function toggle_terminal()
    if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
        local terminal_win = vim.fn.bufwinid(terminal_buf)
        if terminal_win ~= -1 then
            vim.api.nvim_win_close(terminal_win, true)
            return
        end

        vim.cmd("botright split")
        vim.cmd("resize 12")
        vim.api.nvim_win_set_buf(0, terminal_buf)
        vim.cmd("startinsert")
        return
    end

    vim.cmd("botright 12split")
    vim.cmd("terminal")
    terminal_buf = vim.api.nvim_get_current_buf()
    vim.bo[terminal_buf].buflisted = false
    vim.cmd("startinsert")
end

vim.keymap.set({ "n", "t" }, "<leader>t", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Terminal normal mode" })

-- Show whitespace only while selecting text
local visual_list_group = vim.api.nvim_create_augroup("VisualListChars", { clear = true })

vim.api.nvim_create_autocmd("ModeChanged", {
    group = visual_list_group,
    pattern = "*:[vV\22]*",
    callback = function()
        vim.opt_local.list = true
    end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
    group = visual_list_group,
    pattern = "[vV\22]*:*",
    callback = function()
        vim.opt_local.list = false
    end,
})

vim.opt.listchars = {
    space = "·",
    tab = "» ",
    trail = "·",
}
