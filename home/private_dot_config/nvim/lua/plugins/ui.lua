-- UI enhancements
return {
  -- Statusline
  {
    "echasnovski/mini.statusline",
    lazy = false,
    opts = { use_icons = true },
  },

  -- Indent guides
  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPre", "BufNewFile" },
    opts = { symbol = "│" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "lazy", "mason", "neo-tree", "Trouble" },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },

  -- Better UI elements
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev todo" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Todo" },
    },
  },

  -- Font rendering
  {
    "hydepwns/mona.nvim",
    lazy = false,
    build = ":MonaInstall variable all",
    opts = {
      font_features = {
        texture_healing = true,
        ligatures = { enable = true },
      },
    },
  },
}
