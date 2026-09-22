return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  cmd = "Neogit",
  keys = {
    {
      "<leader>Gg",
      "<cmd>Neogit<cr>",
      desc = "Git Status",
    },
    {
      "<leader>Gl",
      "<cmd>Neogit log<cr>",
      desc = "Git Log",
    },
    {
      "<leader>Gc",
      "<cmd>Neogit commit<cr>",
      desc = "Git Commit",
    },
  },
  opts = {
    integrations = {
      diffview = true,
    },
  },
}
