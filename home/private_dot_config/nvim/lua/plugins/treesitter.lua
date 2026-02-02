-- Treesitter - syntax highlighting
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "bash", "c", "css", "diff", "elixir", "erlang", "go", "heex",
      "html", "javascript", "json", "lua", "luadoc", "markdown",
      "markdown_inline", "python", "query", "regex", "rust", "toml",
      "tsx", "typescript", "vim", "vimdoc", "yaml",
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
