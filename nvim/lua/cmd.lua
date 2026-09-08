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

-- Swap the two sides of a visual selection around a chosen separator.
-- Examples: hello_world -> world_hello, a = b; -> b = a;
vim.keymap.set("x", "<leader>x", function()
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")

    if start_pos[2] ~= end_pos[2] then
        vim.notify("Swap by separator currently supports a single line", vim.log.levels.WARN)
        return
    end

    local row = start_pos[2] - 1
    local start_col = math.min(start_pos[3], end_pos[3]) - 1
    local end_col = math.max(start_pos[3], end_pos[3])
    local text = vim.api.nvim_buf_get_text(0, row, start_col, row, end_col, {})[1]

    local separator = vim.fn.getcharstr()
    if separator == "" or separator == "\27" then
        return
    end

    local separator_start, separator_end = text:find(separator, 1, true)
    if not separator_start then
        vim.notify("Separator '" .. separator .. "' not found in selection", vim.log.levels.WARN)
        return
    end

    local left = text:sub(1, separator_start - 1)
    local right = text:sub(separator_end + 1)

    local prefix = left:match("^%s*") or ""
    local left_space = left:match("%s*$") or ""
    local right_space = right:match("^%s*") or ""
    local suffix_space = right:match("%s*$") or ""

    local left_value = left:sub(#prefix + 1, #left - #left_space)
    local right_body = right:sub(#right_space + 1, #right - #suffix_space)

    -- Keep common statement punctuation at the end instead of swapping it.
    local punctuation = right_body:match("[;,]+$") or ""
    local right_value = right_body:sub(1, #right_body - #punctuation)

    local swapped = prefix
        .. right_value
        .. left_space
        .. separator
        .. right_space
        .. left_value
        .. punctuation
        .. suffix_space

    vim.api.nvim_buf_set_text(0, row, start_col, row, end_col, { swapped })
end, { desc = "Swap selection by separator" })

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
