-- Telescope - fuzzy finder
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
    { "<leader>fs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    { "<leader><space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
  },
  opts = {
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      layout_strategy = "horizontal",
      sorting_strategy = "ascending",
      layout_config = {
        horizontal = { prompt_position = "top", preview_width = 0.55 },
      },
    },
    pickers = {
      find_files = { hidden = true },
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
  end,
}
