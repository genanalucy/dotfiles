return {
  {
    "amitds1997/remote-nvim.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      progress_view = {
        type = "split",
      },
      offline_mode = {
        enabled = true,
        no_github = false,
      },
      remote = {
        copy_dirs = {
          data = {
            base = vim.fn.stdpath("data"),
            dirs = { "lazy" },
            compression = {
              enabled = true,
              additional_opts = { "--exclude-vcs" },
            },
          },
        },
      },
    },
  },
}
