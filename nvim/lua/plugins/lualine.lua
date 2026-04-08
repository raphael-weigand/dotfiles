return {
    {
        'nvim-lualine/lualine.nvim',
        priority = 1010,
        config = function()
            require('lualine').setup({
                options = {
                     theme = 'auto'
                }
            })
        end
    }
}
