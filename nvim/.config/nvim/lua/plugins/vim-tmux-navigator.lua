return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", mode = { "n", "i", "t" }, desc = "Go to left window" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "i", "t" }, desc = "Go to lower window" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "i", "t" }, desc = "Go to upper window" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "i", "t" }, desc = "Go to right window" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", mode = { "n", "i", "t" }, desc = "Go to previous window" },
    },
  },
}
