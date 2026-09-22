-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Remove trailing whitespace before saving while preserving the cursor position.
local trim_whitespace_group = vim.api.nvim_create_augroup("trim-trailing-whitespace", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Remove trailing whitespace",
    group = trim_whitespace_group,
    pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc", "*.hh", "*.lua", "*.py", "*.php", "*.js", "*.ts", "*.json", "*.css", "*.scss", "*.html", "*.md", "*.yml", "*.yaml", "*.sh" },
    callback = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[silent! keepjumps keeppatterns %s/\s\+$//e]])
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
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

local function swap_text(text, separator, keep_prefix)
    local separator_start, separator_end = text:find(separator, 1, true)
    if not separator_start then
        return nil
    end

    local left = text:sub(1, separator_start - 1)
    local right = text:sub(separator_end + 1)
    local prefix = ""

    if keep_prefix then
        local before, operand = left:match("^(.-)([^%s]+)%s*$")
        if operand then
            prefix = before
            left = operand .. (left:match("%s*$") or "")
        end
    end

    local left_leading = left:match("^%s*") or ""
    local left_space = left:match("%s*$") or ""
    local right_space = right:match("^%s*") or ""
    local suffix_space = right:match("%s*$") or ""

    local left_value = left:sub(#left_leading + 1, #left - #left_space)
    local right_body = right:sub(#right_space + 1, #right - #suffix_space)
    local punctuation = right_body:match("[;,]+$") or ""
    local right_value = right_body:sub(1, #right_body - #punctuation)

    return prefix
        .. left_leading
        .. right_value
        .. left_space
        .. separator
        .. right_space
        .. left_value
        .. punctuation
        .. suffix_space
end

local function read_separator()
    local separator = vim.fn.getcharstr()
    if separator == "" or separator == "\27" then
        return nil
    end
    return separator
end

-- Normal mode: swap around a separator on the current expression/line.
-- `hello_world` + <leader>x_ -> `world_hello`
-- `unsigned long amount_fresh = 1;` + <leader>x= -> `unsigned long 1 = amount_fresh;`
vim.keymap.set("n", "<leader>x", function()
    local separator = read_separator()
    if not separator then
        return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    -- Prefer the WORD under the cursor when it already contains the separator.
    local word_start = col + 1
    while word_start > 1 and not line:sub(word_start - 1, word_start - 1):match("%s") do
        word_start = word_start - 1
    end

    local word_end = col + 1
    while word_end < #line and not line:sub(word_end + 1, word_end + 1):match("%s") do
        word_end = word_end + 1
    end

    local word = line:sub(word_start, word_end)
    if word:find(separator, 1, true) then
        local swapped = swap_text(word, separator, false)
        if swapped then
            vim.api.nvim_buf_set_text(0, row - 1, word_start - 1, row - 1, word_end, { swapped })
        end
        return
    end

    -- Otherwise swap the operand before the separator with the value after it,
    -- while preserving declarations/indentation before the left operand.
    local swapped = swap_text(line, separator, true)
    if not swapped then
        vim.notify("Separator '" .. separator .. "' not found on current line", vim.log.levels.WARN)
        return
    end

    vim.api.nvim_set_current_line(swapped)
end, { desc = "Swap around separator" })

-- Visual mode: swap the two sides of the selected text.
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
    local separator = read_separator()
    if not separator then
        return
    end

    local swapped = swap_text(text, separator, false)
    if not swapped then
        vim.notify("Separator '" .. separator .. "' not found in selection", vim.log.levels.WARN)
        return
    end

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

-- Buffers: same bindings as VsVim's previous/next document.
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Windows/splits: keep the same spatial navigation used in Visual Studio.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus window above" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus window right" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close split" })
vim.keymap.set("n", "<leader>sx", "<C-w>x", { desc = "Swap split" })

-- Documents: mirror the VsVim window/document workflow.
vim.keymap.set("n", "<leader>ws", "<cmd>write<CR>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>wa", "<cmd>wall<CR>", { desc = "Save all buffers" })
vim.keymap.set("n", "<leader>wc", "<cmd>bdelete<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>wo", "<cmd>only<CR>", { desc = "Close other windows" })

-- Build gets its own namespace; <leader>m remains reserved for multi-cursor.
local function find_makefile()
    local start_path = vim.api.nvim_buf_get_name(0)
    if start_path == "" then
        start_path = vim.fn.getcwd()
    else
        start_path = vim.fs.dirname(start_path)
    end

    return vim.fs.find({ "Makefile", "makefile", "GNUmakefile" }, {
        path = start_path,
        upward = true,
        type = "file",
    })[1]
end

local function make_target()
    local makefile = find_makefile()
    if not makefile then
        vim.notify("No Makefile found", vim.log.levels.WARN)
        return
    end

    local targets = {}
    local seen = {}

    for line in io.lines(makefile) do
        if not line:match("^%s") and not line:match("^#") then
            local colon = line:find(":", 1, true)
            if colon and line:sub(colon + 1, colon + 1) ~= "=" then
                local lhs = line:sub(1, colon - 1):match("^%s*(.-)%s*$")
                if lhs and lhs ~= "" then
                    for target in lhs:gmatch("%S+") do
                        if not target:match("^%.")
                            and not target:find("%%", 1, true)
                            and not target:find("$", 1, true)
                            and not seen[target]
                        then
                            seen[target] = true
                            table.insert(targets, target)
                        end
                    end
                end
            end
        end
    end

    if #targets == 0 then
        vim.notify("No Make targets found", vim.log.levels.WARN)
        return
    end

    table.sort(targets)

    vim.ui.select(targets, { prompt = "Make target:" }, function(target)
        if not target then
            return
        end

        local make_dir = vim.fs.dirname(makefile)
        vim.cmd("make -C " .. vim.fn.fnameescape(make_dir) .. " " .. vim.fn.fnameescape(target))
    end)
end

vim.keymap.set("n", "<leader>b", make_target, { desc = "Select Make target" })
vim.keymap.set("n", "<leader>bb", "<cmd>make<CR>", { desc = "Build with :make" })

-- Quickfix
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

-- CTRL-Backspace is like normal delete
vim.keymap.set("i", "<C-BS>", "<C-w>", {
  desc = "Delete previous word",
})
