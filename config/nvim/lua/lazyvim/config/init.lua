-- LazyNvim configuration
local Util = require("lazyvim.util")

-- Set leader key before lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable some builtin plugins
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- Set options
for name, value in pairs({
  backup = false,
  clipboard = "unnamedplus",
  cmdheight = 1,
  completeopt = { "menuone", "noselect" },
  conceallevel = 0,
  fileencoding = "utf-8",
  hlsearch = true,
  ignorecase = true,
  mouse = "a",
  pumheight = 10,
  showmode = false,
  showtabline = 2,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  termguicolors = true,
  timeoutlen = 300,
  undofile = true,
  updatetime = 300,
  writebackup = false,
  expandtab = true,
  shiftwidth = 2,
  tabstop = 2,
  cursorline = true,
  number = true,
  relativenumber = true,
  numberwidth = 4,
  signcolumn = "yes",
  wrap = false,
  scrolloff = 8,
  sidescrolloff = 8,
  guifont = "monospace:h17",
}) do
  vim.opt[name] = value
end

-- Set autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Set keymaps
local keymap = vim.keymap.set

-- General keymaps
keymap("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
keymap("n", "x", '"_x', { desc = "Delete single character without copying into register" })

-- Window management
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Make splits equal width" })
keymap("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })

-- Tab management
keymap("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
keymap("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab" })
keymap("n", "<leader>tn", ":tabn<CR>", { desc = "Go to next tab" })
keymap("n", "<leader>tp", ":tabp<CR>", { desc = "Go to previous tab" })

-- Plugin keymaps
keymap("n", "<leader>sm", ":Mason<CR>", { desc = "Open Mason" })
keymap("n", "<leader>mm", ":Mona<CR>", { desc = "Open Mona" })

-- Telescope keymaps
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
keymap("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
keymap("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Show open buffers" })
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help" })
keymap("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Show oldfiles" })
keymap("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in current buffer" })

-- LSP keymaps
keymap("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", { desc = "Show definition, references" })
keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "Go to declaration" })
keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { desc = "See definition and make edits in window" })
keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "See available code actions" })
keymap("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "Smart rename" })
keymap("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Show diagnostics for line" })
keymap("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { desc = "Show diagnostics for cursor" })
keymap("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Jump to previous diagnostic in buffer" })
keymap("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Jump to next diagnostic in buffer" })
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Show documentation for what is under cursor" })
keymap("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", { desc = "See outline on right hand side" })

-- Terminal keymaps
keymap("t", "<C-x>", "<C-\\><C-N>", { desc = "Exit terminal mode" })

-- Visual mode keymaps
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line / block of text in visual mode up" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line / block of text in visual mode down" })
keymap("v", "<", "<gv", { desc = "Better indentation" })
keymap("v", ">", ">gv", { desc = "Better indentation" })

-- Buffer keymaps
keymap("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Close buffer" })
keymap("n", "<leader>bn", "<cmd>bn<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", "<cmd>bp<CR>", { desc = "Previous buffer" })

-- Quick save
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap("n", "<leader>W", "<cmd>wa<CR>", { desc = "Save all files" })

-- Quick quit
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
keymap("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })

-- Clear search highlights
keymap("n", "<leader>nh", "<cmd>nohl<CR>", { desc = "Clear search highlights" })

-- Move between windows
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
keymap("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines up and down
keymap("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
keymap("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
keymap("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
keymap("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better paste
keymap("v", "p", '"_dP', { desc = "Better paste" })

-- Stay in indent mode
keymap("v", "<", "<gv", { desc = "Better indentation" })
keymap("v", ">", ">gv", { desc = "Better indentation" })

-- Quick fix list
keymap("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix" })
keymap("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })

-- Location list
keymap("n", "[l", "<cmd>lprev<CR>zz", { desc = "Previous location" })
keymap("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next location" })

-- Replace word under cursor
keymap("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Make current file executable
keymap("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make current file executable" })

-- Source current file
keymap("n", "<leader><CR>", "<cmd>so<CR>", { desc = "Source current file" })

-- Toggle options
keymap("n", "<leader>tw", function()
  Util.toggle("wrap")
end, { desc = "Toggle Word Wrap" })
keymap("n", "<leader>tl", function()
  Util.toggle("relativenumber", true)
  Util.toggle("number")
end, { desc = "Toggle Line Numbers" })
keymap("n", "<leader>td", function()
  Util.toggle_diagnostics()
end, { desc = "Toggle Diagnostics" })
keymap("n", "<leader>ts", function()
  Util.toggle("spell")
end, { desc = "Toggle Spelling" })
keymap("n", "<leader>tp", function()
  Util.toggle("paste")
end, { desc = "Toggle Paste Mode" })

-- lazygit
keymap("n", "<leader>gg", function()
  Util.float_term({ "lazygit" }, { cwd = Util.get_root(), esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazygit (root dir)" })
keymap("n", "<leader>gG", function()
  Util.float_term({ "lazygit" }, { esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazygit (cwd)" })

-- Quit
keymap("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Terminal Mappings
keymap("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
keymap("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
keymap("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Windows
keymap("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
keymap("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
keymap("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
keymap("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
keymap("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
keymap("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- Tabs
keymap("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Buffers
keymap("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Add these keymaps only if the corresponding plugin is loaded
local function add_if_loaded(plugin, keymap_table)
  if Util.has(plugin) then
    for mode, mappings in pairs(keymap_table) do
      for lhs, rhs in pairs(mappings) do
        vim.keymap.set(mode, lhs, rhs)
      end
    end
  end
end

-- Add keymaps for specific plugins
add_if_loaded("telescope.nvim", {
  n = {
    ["<leader>,"] = { "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", "Switch Buffer" },
    ["<leader>/"] = { Util.telescope("live_grep"), "Grep (root dir)" },
    ["<leader>:"] = { "<cmd>Telescope command_history<cr>", "Command History" },
    ["<leader><space>"] = { Util.telescope("files"), "Find Files (root dir)" },
    ["<leader>?"] = { Util.telescope("oldfiles"), "Recent" },
    ["<leader>B"] = { Util.telescope("git_branches"), "Checkout branch" },
    ["<leader>f<space>"] = { Util.telescope("files"), "Find Files (root dir)" },
    ["<leader>fb"] = { "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", "Buffers" },
    ["<leader>ff"] = { Util.telescope("files"), "Find Files (root dir)" },
    ["<leader>fF"] = { Util.telescope("files", { cwd = false }), "Find Files (cwd)" },
    ["<leader>fr"] = { "<cmd>Telescope oldfiles<cr>", "Recent" },
    ["<leader>fR"] = { Util.telescope("oldfiles", { cwd = vim.loop.cwd() }), "Recent (cwd)" },
    ["<leader>gc"] = { "<cmd>Telescope git_commits<CR>", "commits" },
    ["<leader>gs"] = { "<cmd>Telescope git_status<CR>", "status" },
    ["<leader>sa"] = { "<cmd>Telescope autocommands<cr>", "Auto Commands" },
    ["<leader>sb"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer" },
    ["<leader>sc"] = { "<cmd>Telescope command_history<cr>", "Command History" },
    ["<leader>sC"] = { "<cmd>Telescope commands<cr>", "Commands" },
    ["<leader>sd"] = { "<cmd>Telescope diagnostics bufnr=0<cr>", "Document diagnostics" },
    ["<leader>sD"] = { "<cmd>Telescope diagnostics<cr>", "Workspace diagnostics" },
    ["<leader>sg"] = { Util.telescope("live_grep"), "Grep (root dir)" },
    ["<leader>sG"] = { Util.telescope("live_grep", { cwd = false }), "Grep (cwd)" },
    ["<leader>sh"] = { "<cmd>Telescope help_tags<cr>", "Help Pages" },
    ["<leader>sH"] = { "<cmd>Telescope highlights<cr>", "Search Highlight Groups" },
    ["<leader>sk"] = { "<cmd>Telescope keymaps<cr>", "Key Maps" },
    ["<leader>sM"] = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
    ["<leader>sm"] = { "<cmd>Telescope marks<cr>", "Jump to Mark" },
    ["<leader>so"] = { "<cmd>Telescope vim_options<cr>", "Options" },
    ["<leader>sR"] = { "<cmd>Telescope resume<cr>", "Resume" },
    ["<leader>sw"] = { Util.telescope("grep_string", { word_match = "-w" }), "Word (root dir)" },
    ["<leader>sW"] = { Util.telescope("grep_string", { cwd = false, word_match = "-w" }), "Word (cwd)" },
    ["<leader>uC"] = { Util.telescope("colorscheme", { enable_preview = true }), "Colorscheme with preview" },
    ["<leader>ss"] = { Util.telescope("lsp_document_symbols", { symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Variable", "Property", "Field", "Struct", "Event", "Operator", "TypeParameter" } } }), "Goto Symbol" },
    ["<leader>sS"] = { Util.telescope("lsp_dynamic_workspace_symbols", { symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module", "Variable", "Property", "Field", "Struct", "Event", "Operator", "TypeParameter" } } }), "Goto Symbol (Workspace)" },
  },
})

add_if_loaded("nvim-tree.lua", {
  n = {
    ["<leader>e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
  },
})

add_if_loaded("trouble.nvim", {
  n = {
    ["<leader>xx"] = { "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)" },
    ["<leader>xX"] = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)" },
    ["<leader>cs"] = { "<cmd>Trouble symbols toggle focusable=false<cr>", "Symbols (Trouble)" },
    ["<leader>cl"] = { "<cmd>Trouble lsp toggle focusable=false<cr>", "LSP Definitions / references / ... (Trouble)" },
    ["<leader>xL"] = { "<cmd>Trouble loclist toggle<cr>", "Location List (Trouble)" },
    ["<leader>xQ"] = { "<cmd>Trouble qflist toggle<cr>", "Quickfix List (Trouble)" },
  },
})

add_if_loaded("todo-comments.nvim", {
  n = {
    ["<leader>xt"] = { "<cmd>TodoTrouble<cr>", "Todo (Trouble)" },
    ["<leader>xT"] = { "<cmd>TodoTrouble keywords=TODO,FIXME<cr>", "Todo/Fixme (Trouble)" },
    ["<leader>st"] = { "<cmd>TodoTelescope<cr>", "Todo" },
    ["<leader>sT"] = { "<cmd>TodoTelescope keywords=TODO,FIXME<cr>", "Todo/Fixme" },
  },
})

add_if_loaded("gitsigns.nvim", {
  n = {
    ["<leader>gj"] = { function() require("gitsigns").next_hunk() end, "Next Git Hunk" },
    ["<leader>gk"] = { function() require("gitsigns").prev_hunk() end, "Prev Git Hunk" },
    ["<leader>gl"] = { function() require("gitsigns").blame_line() end, "View Git Blame" },
    ["<leader>gL"] = { function() require("gitsigns").blame_line({ full = true }) end, "View Git Blame (Full)" },
    ["<leader>gp"] = { function() require("gitsigns").preview_hunk() end, "Preview Git Hunk" },
    ["<leader>gh"] = { function() require("gitsigns").reset_hunk() end, "Reset Git Hunk" },
    ["<leader>gr"] = { function() require("gitsigns").reset_buffer() end, "Reset Git Buffer" },
    ["<leader>gs"] = { function() require("gitsigns").stage_hunk() end, "Stage Git Hunk" },
    ["<leader>gS"] = { function() require("gitsigns").undo_stage_hunk() end, "Unstage Git Hunk" },
    ["<leader>gu"] = { function() require("gitsigns").reset_hunk() end, "Reset Git Hunk" },
    ["<leader>gU"] = { function() require("gitsigns").reset_buffer_index() end, "Reset Git Buffer Index" },
    ["<leader>gd"] = { function() require("gitsigns").diffthis() end, "View Git Diff" },
    ["<leader>gD"] = { function() require("gitsigns").diffthis("~") end, "View Git Diff (~)" },
    ["<leader>gtd"] = { function() require("gitsigns").toggle_deleted() end, "Toggle Git Deleted" },
  },
})

add_if_loaded("neotest", {
  n = {
    ["<leader>tt"] = { function() require("neotest").run.run(vim.loop.cwd()) end, "Run File" },
    ["<leader>tT"] = { function() require("neotest").run.run() end, "Run Nearest" },
    ["<leader>ta"] = { function() require("neotest").run.attach() end, "Attach" },
    ["<leader>tf"] = { function() require("neotest").run.run(vim.fn.expand("%")) end, "Run File" },
    ["<leader>tF"] = { function() require("neotest").run.run({ vim.fn.expand("%"), env = { ["PYTEST_ADDOPTS"] = "--tb=short -v" } }) end, "Run File (Verbose)" },
    ["<leader>tl"] = { function() require("neotest").run.run_last() end, "Run Last" },
    ["<leader>tL"] = { function() require("neotest").run.run_last({ env = { ["PYTEST_ADDOPTS"] = "--tb=short -v" } }) end, "Run Last (Verbose)" },
    ["<leader>to"] = { function() require("neotest").output.open({ enter = true, auto_close = true }) end, "Output" },
    ["<leader>tO"] = { function() require("neotest").output.open({ enter = true, auto_close = false }) end, "Output (No Auto Close)" },
    ["<leader>ts"] = { function() require("neotest").summary.toggle() end, "Summary" },
    ["<leader>tS"] = { function() require("neotest").summary.toggle() end, "Summary" },
  },
})

add_if_loaded("dap", {
  n = {
    ["<leader>dB"] = { function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, "Breakpoint Condition" },
    ["<leader>db"] = { function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint" },
    ["<leader>dc"] = { function() require("dap").continue() end, "Continue" },
    ["<leader>dC"] = { function() require("dap").run_to_cursor() end, "Run to Cursor" },
    ["<leader>dg"] = { function() require("dap").goto_() end, "Go to line (no execute)" },
    ["<leader>di"] = { function() require("dap").step_into() end, "Step Into" },
    ["<leader>dj"] = { function() require("dap").down() end, "Down" },
    ["<leader>dk"] = { function() require("dap").up() end, "Up" },
    ["<leader>dl"] = { function() require("dap").run_last() end, "Run Last" },
    ["<leader>do"] = { function() require("dap").step_out() end, "Step Out" },
    ["<leader>dO"] = { function() require("dap").step_over() end, "Step Over" },
    ["<leader>dp"] = { function() require("dap").pause() end, "Pause" },
    ["<leader>dr"] = { function() require("dap").repl.toggle() end, "Toggle REPL" },
    ["<leader>ds"] = { function() require("dap").session() end, "Session" },
    ["<leader>dt"] = { function() require("dap").terminate() end, "Terminate" },
    ["<leader>dw"] = { function() require("dap.ui.widgets").hover() end, "Widgets" },
  },
})

add_if_loaded("dap-python", {
  n = {
    ["<leader>dPt"] = { function() require('dap-python').test_method() end, "Debug Method" },
    ["<leader>dPc"] = { function() require('dap-python').test_class() end, "Debug Class" },
    ["<leader>dPs"] = { function() require('dap-python').debug_selection() end, "Debug Selection" },
  },
})

add_if_loaded("vim-dap-virtual-text", {
  n = {
    ["<leader>dV"] = { function() require("nvim-dap-virtual-text").toggle() end, "Toggle Virtual Text" },
  },
})

add_if_loaded("nvim-dap", {
  n = {
    ["<leader>dE"] = { function() require("dapui").eval(vim.fn.input "[Expression] > ") end, "Evaluate Input" },
    ["<leader>dU"] = { function() require("dapui").toggle() end, "Toggle Debugger UI" },
  },
})

add_if_loaded("dap", {
  n = {
    ["<leader>da"] = { function() require("debughelper").attach() end, "Attach to Process" },
    ["<leader>dA"] = { function() require("debughelper").attachToRemote() end, "Attach to Remote Process" },
  },
})

add_if_loaded("neotest", {
  n = {
    ["<leader>tw"] = { "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>", "Jest Watch" },
  },
})

-- Add keymaps for mona.nvim
add_if_loaded("mona.nvim", {
  n = {
    ["<leader>mf"] = { "<cmd>MonaPreview<cr>", "Font preview" },
    ["<leader>mi"] = { "<cmd>MonaInstall variable all<cr>", "Install fonts" },
    ["<leader>ms"] = { "<cmd>MonaStatus<cr>", "Font status" },
    ["<leader>mh"] = { "<cmd>MonaHealth<cr>", "Font health check" },
  },
})

-- Add keymaps for synthwave84
add_if_loaded("synthwave84.nvim", {
  n = {
    ["<leader>tg"] = { "<cmd>lua require('synthwave84').toggle_glow()<cr>", "Toggle glow effect" },
  },
}) 