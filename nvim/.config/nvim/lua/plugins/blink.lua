return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",

        -- Tab 超级键
        ["<Tab>"] = {
          "select_next",
          "snippet_forward",
          "fallback",
        },

        ["<S-Tab>"] = {
          "select_prev",
          "snippet_backward",
          "fallback",
        },

        ["<CR>"] = { "accept", "fallback" },
      },

      completion = {
        menu = {
          auto_show = true, -- 🔥 自动弹补全
        },
      },
    },
  },
}
