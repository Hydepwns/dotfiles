-- Options
local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.laststatus = 3

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
opt.undofile = true
opt.swapfile = false

-- Completion
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10

-- Clipboard
opt.clipboard = "unnamedplus"

-- Scrolloff
opt.scrolloff = 8
opt.sidescrolloff = 8
