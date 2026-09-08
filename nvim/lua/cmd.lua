-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Keep search highlighting while actively searching/navigating, but clear it
-- as soon as another Normal-mode command is used.
local search_keys = {
    ["/"] = true,
    ["?"] = true,
    ["*"] = true,
    ["#"] = true,
    ["n"] = true,
    ["N"] = true,
}

local search_highlight_ns = vim.api.nvim_create_namespace("auto-nohlsearch")
vim.on_key(function(key)
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" and vim.v.hlsearch == 1 and not search_keys[key] then
        vim.v.hlsearch = 0
    end
end, search_highlight_ns)

-- Toggle comments using Neovim's native, language-aware commenting.
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "<leader>/", "gc", { remap = true, desc = "Toggle comment selection" })

-- Replace the word under the cursor throughout the current buffer.
vim.keymap.set("n", "<leader>sr", function()
    local word = vim.fn.expand("<cword>")
    if word == "" then
        return
    end

    vim.ui.input({ prompt = "Replace '" .. word .. "' with: " }, function(replacement)
        if replacement == nil then
            return
        end

        local pattern = vim.fn.escape(word, [[\/]])
        local escaped_replacement = vim.fn.escape(replacement, [[\/&]])
        vim.cmd("%s/\\<" .. pattern .. "\\>/" .. escaped_replacement .. "/gc")
    end)
end, { desc = "Replace word under cursor" })

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
vim.keymap.set("t", "<C-g>", [[<C-\><C-n>]], { desc = "Terminal normal mode" })
vim.keymap.set("n", "<C-g>", function()
    if vim.bo.buftype == "terminal" then
        vim.cmd("startinsert")
    end
end, { desc = "Terminal input mode" })

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
