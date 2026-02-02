-- Editor enhancements
return {
  -- File explorer
  {
    "echasnovski/mini.files",
    keys = {
      { "<leader>e", function() require("mini.files").open(vim.api.nvim_buf_get_name(0)) end, desc = "Explorer (file)" },
      { "<leader>E", function() require("mini.files").open(vim.uv.cwd()) end, desc = "Explorer (cwd)" },
    },
    opts = {
      windows = { preview = true, width_focus = 30, width_preview = 40 },
    },
  },

  -- Surround
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        update_n_lines = "sn",
      },
    },
  },

  -- Auto pairs
  { "echasnovski/mini.pairs", event = "InsertEnter", opts = {} },

  -- Comments
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },

  -- Flash (motion)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash" },
      { "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
    },
    opts = {},
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
        { "<leader>b", group = "buffer" },
        { "<leader>q", group = "quit" },
      },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format() end, desc = "Format" },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        elixir = { "mix" },
        go = { "gofmt" },
        rust = { "rustfmt" },
        python = { "black" },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  },

  -- Trouble (diagnostics)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
    },
    opts = {},
  },
}
