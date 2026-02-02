-- Synthwave84 theme
return {
  "lunarvim/synthwave84.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("synthwave84").setup({
      glow = {
        error_msg = true,
        type2 = true,
        func = true,
        keyword = true,
      },
    })
    vim.cmd.colorscheme("synthwave84")
  end,
}
