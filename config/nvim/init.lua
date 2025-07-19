-- Bootstrap LazyNvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure LazyNvim
require("lazy").setup({
  {
    "folke/lazy.nvim",
    version = "*",
  },
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
  },
  {
    "folke/neodev.nvim",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "javascript",
          "typescript",
          "python",
          "rust",
          "go",
          "elixir",
          "lua",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      local wk = require("which-key")
      
      wk.setup({
        plugins = {
          marks = true,     -- shows a list of your marks on ' and `
          registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
          spelling = {
            enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
          },
          -- the presets plugin, adds help for a bunch of default keybindings in Neovim
          -- No actual key bindings are created
          presets = {
            operators = false,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
            motions = false,      -- adds help for motions
            text_objects = false, -- help for text objects triggered after entering an operator
            windows = true,       -- default bindings on <c-w>
            nav = true,          -- misc bindings to work with windows
            z = true,            -- bindings for folds, spelling and others prefixed with z
            g = true,            -- bindings for prefixed with g
          },
        },
        -- add operators that will trigger motion and text object completion
        -- to enable all native operators, set the preset / operators plugin above
        operators = { gc = "Comments" },
        key_labels = {
          -- override the label used to display some keys. It doesn't effect WK in any other way.
          -- For example:
          -- ["<space>"] = "SPC",
          -- ["<cr>"] = "RET",
          -- ["<tab>"] = "TAB",
        },
        icons = {
          breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
          separator = "➜", -- symbol used between a key and it's label
          group = "+", -- symbol prepended to a group
        },
        popup_mappings = {
          scroll_down = "<c-d>", -- binding to scroll down inside the popup
          scroll_up = "<c-u>",   -- binding to scroll up inside the popup
        },
        window = {
          border = "rounded", -- none, single, double, shadow, rounded
          position = "bottom", -- bottom, top
          margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
          padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
          winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
          zindex = 1000, -- positive value to position WhichKey above other floating windows.
        },
        layout = {
          height = { min = 4, max = 25 }, -- min and max height of the columns
          width = { min = 20, max = 50 }, -- min and max width of the columns
          spacing = 3, -- spacing between columns
          align = "left", -- align columns left, center or right
        },
        ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
        hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
        show_help = true, -- show a help message in the command line for using WhichKey
        show_keys = true, -- show the currently pressed key and its label as a message in the command line
        triggers = "auto", -- automatically setup triggers
        -- triggers = {"<leader>"} -- or specify a list manually
        triggers_blacklist = {
          -- list of mode / prefixes that should never be hooked by WhichKey
          -- this is mostly relevant for key maps that do not live in a mode called "normal"
          -- for example :h <c-w> doesn't trigger which-key
          i = { "j", "k" },
          v = { "j", "k" },
        },
        disable = {
          buftypes = {},
          filetypes = { "TelescopePrompt" },
        },
      })

      -- Register key groups for better organization
      wk.register({
        ["<leader>"] = {
          f = { name = "Find" },
          g = { name = "Git" },
          l = { name = "LSP" },
          d = { name = "Diagnostics" },
          s = { name = "Split" },
          t = { name = "Tab" },
          b = { name = "Buffer" },
          w = { name = "Window" },
          o = { name = "Org/Outline" },
          m = { name = "Mona/Fonts" },
          S = { name = "Session" },
          n = { name = "Notifications" },
          ["<space>"] = { name = "Telescope" },
        },
        ["g"] = { name = "Go to" },
        ["]"] = { name = "Next" },
        ["["] = { name = "Previous" },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "numToStr/Comment.nvim",
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  {
    "lewis6991/gitsigns.nvim",
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "folke/neodev.nvim",
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = true,
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
      },
    },
  },
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
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "folke/neotest",
    optional = true,
    opts = {
      adapters = {
        ["neotest-elixir"] = {},
      },
    },
  },
  {
    "nvim-neotest/neotest-go",
  },
  {
    "nvim-neotest/neotest-python",
  },
  {
    "nvim-neotest/neotest-vim-test",
    dependencies = { "vim-test/vim-test" },
    opts = {
      ignore_file_types = { "python", "vim", "lua" },
    },
  },
  {
    "folke/twilight.nvim",
    opts = {
      dimming = {
        alpha = 0.25,
        disabled = false,
        inactive = true,
        term_bg = "#000000",
      },
      context = 10,
      treesitter = true,
      expand = {
        "function",
        "method",
        "table",
        "if_statement",
      },
      exclude = {},
    },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        backdrop = 0.95,
        width = 120,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = "0",
          list = false,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
        },
        twilight = { enabled = true },
        gitsigns = { enabled = false },
        tmux = { enabled = false },
        kitty = { enabled = false, font = "+2" },
      },
      on_open = function(win)
        require("lazy").show()
      end,
    },
  },
  {
    "nvim-orgmode/orgmode",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", lazy = true },
    },
    event = "VeryLazy",
    cmd = "OrgToc",
    keys = {
      { "<leader>o", "<cmd>OrgToc<cr>", desc = "Org TOC" },
    },
    opts = {
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
    },
  },
  {
    "nvim-neorg/neorg",
    dependencies = { { "nvim-lua/plenary.nvim" } },
    build = ":Neorg sync-parsers",
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.norg.concealer"] = {},
        ["core.norg.dirman"] = {
          config = {
            workspaces = {
              work = "~/notes/work",
              home = "~/notes/home",
            },
          },
        },
      },
    },
    keys = {
      { "<leader>or", "<cmd>Neorg workspace work<cr>", desc = "Open work workspace" },
      { "<leader>oh", "<cmd>Neorg workspace home<cr>", desc = "Open home workspace" },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Delete all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },
  {
    "echasnovski/mini.indentscope",
    version = false,
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>up",
        function()
          local Util = require("lazy.core.util")
          vim.g.minipairs_disable = not vim.g.minipairs_disable
          if vim.g.minipairs_disable then
            Util.warn("Disabled auto pairs", { title = "Option" })
          else
            Util.info("Enabled auto pairs", { title = "Option" })
          end
        end,
        desc = "Toggle auto pairs",
      },
    },
  },
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gza",
        delete = "gzd",
        find = "gzf",
        find_left = "gzF",
        highlight = "gzh",
        replace = "gzr",
        update_n_lines = "gzn",
      },
    },
  },
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then
              vim.cmd.write()
              bd(vim.fn.bufnr())
            elseif choice == 2 then
              bd(vim.fn.bufnr())
            end
          else
            bd(vim.fn.bufnr())
          end
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(vim.fn.bufnr(), true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },
  {
    "echasnovski/mini.move",
    keys = {
      { "<M-h>", mode = { "n", "x" } },
      { "<M-j>", mode = { "n", "x" } },
      { "<M-k>", mode = { "n", "x" } },
      { "<M-l>", mode = { "n", "x" } },
    },
    opts = {
      mappings = {
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_down = "<M-j>",
        line_up = "<M-k>",
      },
    },
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<(t)%w+", "</(t)%w+>" },
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      if require("lazy.core.config").spec.plugins["nvim-treesitter-textobjects"] then
        local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
        local ts_utils = require("nvim-treesitter.ts_utils")
        local ts_parsers = require("nvim-treesitter.parsers")
        ---@param direction string
        ---@param object string
        ---@param previous fun()
        local function repeat_move(direction, object, previous)
          local unpack = table.unpack or unpack
          local visibility_condition = require("nvim-treesitter.textobjects.repeatable_move").visibility_condition
          local include_surrounding_whitespace = require("nvim-treesitter.textobjects.repeatable_move").include_surrounding_whitespace
          local opts = require("nvim-treesitter.textobjects.repeatable_move").opts
          local start, stop, node = ts_repeat_move.repeatable_move_predicate(direction, object, "i", visibility_condition, include_surrounding_whitespace, opts)
          local result = ts_utils.get_at_path(node, object)
          if result ~= nil then
            local start_row, start_col = ts_parsers.get_node_range(result)
            vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), { start_row + 1, start_col })
          end
          return start ~= nil
        end
        local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(ts_repeat_move.goto_next, ts_repeat_move.goto_prev)
        local next_hunk_repeat_opts = { direction = "next", object = "hunk" }
        local prev_hunk_repeat_opts = { direction = "prev", object = "hunk" }
        repeat_move("next", "hunk", next_hunk_repeat)
        repeat_move("prev", "hunk", prev_hunk_repeat)
      end
    end,
  },
  {
    "echasnovski/mini.files",
    version = false,
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        use_as_default_explorer = false,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), false)
        end,
        desc = "Explorer (current file)",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.loop.cwd(), false)
        end,
        desc = "Explorer (cwd)",
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)
      local files = require("mini.files")
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
          end
          map("<CR>", files.go_in, "Go in")
          map("<BS>", files.go_out, "Go out")
          map("<Tab>", files.toggle_cwd, "Toggle CWD")
          map("a", files.create, "Create")
          map("d", files.trash, "Trash")
          map("r", files.rename, "Rename")
          map("R", files.rename, "Rename (recursive)")
          map("y", files.copy_path, "Copy path")
          map("Y", files.copy_path, "Copy path (recursive)")
          map("x", files.cut_path, "Cut path")
          map("X", files.cut_path, "Cut path (recursive)")
          map("p", files.paste, "Paste")
          map("c", files.copy, "Copy")
          map("m", files.move, "Move")
          map("q", files.close, "Close")
          map("g?", files.help, "Help")
        end,
      })
    end,
  },
  {
    "echasnovski/mini.splitjoin",
    keys = {
      {
        "gJ",
        function()
          require("mini.splitjoin").join()
        end,
        desc = "Join arguments",
      },
      {
        "gS",
        function()
          require("mini.splitjoin").split()
        end,
        desc = "Split arguments",
      },
    },
  },
  {
    "echasnovski/mini.operators",
    keys = {
      { "g=", desc = "Replace with register" },
      { "g?", desc = "Swap case" },
      { "g#", desc = "Eval expression" },
      { "g!", desc = "Filter through external program" },
      { "g&", desc = "Filter through Lua function" },
    },
    opts = {
      replace = {
        prompt_func = function()
          return require("dressing").input({
            prompt = "Replace with: ",
            default = vim.fn.getreg(""),
          })
        end,
      },
      eval = {
        prompt_func = function()
          return require("dressing").input({
            prompt = "Eval: ",
            default = "",
          })
        end,
      },
      filter = {
        prompt_func = function()
          return require("dressing").input({
            prompt = "Filter through: ",
            default = "",
          })
        end,
      },
    },
  },
  {
    "echasnovski/mini.misc",
    keys = {
      {
        "<leader>ul",
        function()
          local util = require("mini.misc")
          util.restore_winpos()
          util.restore_winpos()
        end,
        desc = "Restore last window positions",
      },
    },
    opts = {
      make_global = { "put", "put!", "vput", "vput!" },
    },
  },
  {
    "echasnovski/mini.bracketed",
    event = "BufReadPost",
    opts = {},
    config = function(_, opts)
      local bracketed = require("mini.bracketed")
      bracketed.setup(opts)
      local map = vim.keymap.set
      local function set_bracketed_keymap(name, key, direction, ...)
        map("n", key, function()
          bracketed[name](direction, ...)
        end, { desc = string.format("Go to %s %s", direction, name) })
      end
      set_bracketed_keymap("diagnostic", "[x", "previous")
      set_bracketed_keymap("diagnostic", "]x", "next")
      set_bracketed_keymap("file", "[f", "previous")
      set_bracketed_keymap("file", "]f", "next")
      set_bracketed_keymap("indent", "[I", "previous")
      set_bracketed_keymap("indent", "]I", "next")
      set_bracketed_keymap("jump", "[j", "previous")
      set_bracketed_keymap("jump", "]j", "next")
      set_bracketed_keymap("location", "[l", "previous")
      set_bracketed_keymap("location", "]l", "next")
      set_bracketed_keymap("oldfile", "[o", "previous")
      set_bracketed_keymap("oldfile", "]o", "next")
      set_bracketed_keymap("quickfix", "[q", "previous")
      set_bracketed_keymap("quickfix", "]q", "next")
      set_bracketed_keymap("treesitter", "[t", "previous")
      set_bracketed_keymap("treesitter", "]t", "next")
      set_bracketed_keymap("undo", "[u", "previous")
      set_bracketed_keymap("undo", "]u", "next")
      set_bracketed_keymap("window", "[w", "previous")
      set_bracketed_keymap("window", "]w", "next")
      set_bracketed_keymap("yank", "[y", "previous")
      set_bracketed_keymap("yank", "]y", "next")
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    opts = {
      highlighters = {
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
      },
    },
  },
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.scroll = {
        enable = true,
        timing = function(progress)
          return 1 - math.pow(1 - progress, 3)
        end,
      }
      opts.cursor = {
        enable = true,
        timing = function(progress)
          return 1 - math.pow(1 - progress, 3)
        end,
      }
      opts.resize = {
        enable = true,
        timing = function(progress)
          return 1 - math.pow(1 - progress, 3)
        end,
      }
      opts.open = {
        enable = true,
        timing = function(progress)
          return 1 - math.pow(1 - progress, 3)
        end,
      }
      opts.close = {
        enable = true,
        timing = function(progress)
          return 1 - math.pow(1 - progress, 3)
        end,
      }
    end,
  },
  {
    "gen740/SmoothCursor.nvim",
    event = "VeryLazy",
    opts = {
      cursor = "│",
      texthl = "SmoothCursor",
      linehl = nil,
      type = "default",
      fancy = {
        enable = true,
        head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
        body = {
          { cursor = "│", texthl = "SmoothCursor" },
        },
        tail = { cursor = nil, texthl = "SmoothCursor" },
      },
      flyin_effect = nil,
      speed = 25,
      intervals = 35,
      priority = 10,
      threshold = 3,
      timeout = 3000,
      threshold_ease = 0.45,
      disable_float_win = false,
      enabled_filetypes = nil,
      disabled_filetypes = { "TelescopePrompt", "NvimTree", "LazyGit", "mason", "lazy" },
    },
  },
  {
    "echasnovski/mini.cursorword",
    version = false,
    opts = {
      delay = 100,
    },
  },
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    opts = {
      highlighters = {
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
      },
    },
  },
  {
    "echasnovski/mini.align",
    event = "VeryLazy",
    opts = {
      modes = { pre_justify = { "\\(\\s*\\)" } },
    },
  },
  {
    "echasnovski/mini.extra",
    keys = {
      {
        "<leader>gO",
        function()
          require("mini.extra").pickers.highlights()
        end,
        desc = "Highlight Groups",
      },
      {
        "<leader>gD",
        function()
          require("mini.extra").pickers.diagnostic()
        end,
        desc = "Diagnostic",
      },
      {
        "<leader>gR",
        function()
          require("mini.extra").pickers.registers()
        end,
        desc = "Registers",
      },
      {
        "<leader>gs",
        function()
          require("mini.extra").pickers.spell()
        end,
        desc = "Spell Suggestions",
      },
    },
  },
  {
    "echasnovski/mini.visits",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>gV",
        function()
          require("mini.extra").pickers.visits()
        end,
        desc = "Visits",
      },
    },
  },
  {
    "echasnovski/mini.diff",
    version = false,
  },
  {
    "echasnovski/mini.trailspace",
    version = false,
  },
  {
    "echasnovski/mini.statusline",
    version = false,
    opts = {
      use_icons = vim.g.have_nerd_font,
      set_vim_settings = false,
    },
  },
  {
    "echasnovski/mini.tabline",
    version = false,
    opts = {
      use_icons = vim.g.have_nerd_font,
    },
  },
  {
    "echasnovski/mini.sessions",
    version = false,
    opts = {},
    keys = {
      { "<leader>Ss", "<cmd>lua MiniSessions.write()<cr>", desc = "Write session" },
      { "<leader>Sl", "<cmd>lua MiniSessions.read()<cr>", desc = "Read session" },
      { "<leader>Sd", "<cmd>lua MiniSessions.delete()<cr>", desc = "Delete session" },
    },
  },
  {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
      require("mini.nvim").setup()
    end,
  },
  {
    "hydepwns/mona.nvim",
    lazy = false,
    build = ":MonaInstall variable all",
    opts = {
      style_map = {
        bold = { Comment = true, ["@comment.documentation"] = true },
        italic = { ["@markup.link"] = true },
        bold_italic = { DiagnosticError = true, StatusLine = true },
      },
      font_features = {
        texture_healing = true,
        ligatures = { enable = true, stylistic_sets = { equals = true, arrows = true } },
        character_variants = { zero_style = 2 }
      },
      terminal_config = { auto_generate = true, terminals = { "alacritty", "kitty" } }
    },
    keys = {
      { "<leader>mf", "<cmd>MonaPreview<cr>", desc = "Font preview" },
      { "<leader>mi", "<cmd>MonaInstall variable all<cr>", desc = "Install fonts" },
      { "<leader>ms", "<cmd>MonaStatus<cr>", desc = "Font status" },
      { "<leader>mh", "<cmd>MonaHealth<cr>", desc = "Font health check" },
    },
  },
  {
    "m-demare/hlargs.nvim",
    event = "VeryLazy",
    opts = {
      color = "#ef9062",
      highlight = {},
      excluded_filetypes = {},
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
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
          operator = false,
          buffer_current_target = true,
          buffer_visible_target = true,
          buffer_inactive_target = true,
        }
      })
      vim.cmd[[colorscheme synthwave84]]
    end,
  },
})

-- Load LazyNvim configuration
require("lazy").setup("plugins") 