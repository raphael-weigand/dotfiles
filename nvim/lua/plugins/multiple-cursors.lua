return {
    {
        "brenton-leighton/multiple-cursors.nvim",
        version = "*",
        opts = {
            -- Add matches across the whole buffer, not only the visible window.
            match_visible_only = false,

            -- Completion popups and multi-cursor insert mode don't mix well.
            pre_hook = function()
                local ok, cmp = pcall(require, "cmp")
                if ok then
                    cmp.setup({ enabled = false })
                end
            end,
            post_hook = function()
                local ok, cmp = pcall(require, "cmp")
                if ok then
                    cmp.setup({ enabled = true })
                end
            end,
        },
        keys = {
            {
                "<leader>ma",
                "<cmd>MultipleCursorsAddMatches<CR>",
                mode = { "n", "x" },
                desc = "Multi-cursor: all matches",
            },
            {
                "<leader>mn",
                "<cmd>MultipleCursorsAddJumpNextMatch<CR>",
                mode = { "n", "x" },
                desc = "Multi-cursor: add next match",
            },
            {
                "<leader>mp",
                "<cmd>MultipleCursorsAddJumpPrevMatch<CR>",
                mode = { "n", "x" },
                desc = "Multi-cursor: add previous match",
            },
            {
                "<leader>ms",
                "<cmd>MultipleCursorsJumpNextMatch<CR>",
                mode = { "n", "x" },
                desc = "Multi-cursor: skip next match",
            },
            {
                "<leader>mS",
                "<cmd>MultipleCursorsJumpPrevMatch<CR>",
                mode = { "n", "x" },
                desc = "Multi-cursor: skip previous match",
            },
            {
                "<leader>md",
                "<cmd>MultipleCursorsAddDelete<CR>",
                mode = { "n", "x" },
                desc = "Multi-cursor: add/remove cursor",
            },
            {
                "<leader>mv",
                "<cmd>MultipleCursorsAddVisualArea<CR>",
                mode = "x",
                desc = "Multi-cursor: visual lines",
            },
            {
                "<leader>ml",
                "<cmd>MultipleCursorsLockToggle<CR>",
                mode = { "n", "x" },
                desc = "Multi-cursor: toggle lock",
            },
            {
                "<C-Up>",
                "<cmd>MultipleCursorsAddUp<CR>",
                mode = { "n", "i", "x" },
                desc = "Multi-cursor: add above",
            },
            {
                "<C-Down>",
                "<cmd>MultipleCursorsAddDown<CR>",
                mode = { "n", "i", "x" },
                desc = "Multi-cursor: add below",
            },
        },
    },
}
