-- LSP Configuration
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = args.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", vim.lsp.buf.references, "References")
          map("gI", vim.lsp.buf.implementation, "Implementation")
          map("gy", vim.lsp.buf.type_definition, "Type definition")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>cf", vim.lsp.buf.format, "Format")
        end,
      })

      -- Setup servers
      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({ capabilities = capabilities })
        end,
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
        end,
        ["elixirls"] = function()
          lspconfig.elixirls.setup({
            capabilities = capabilities,
            settings = {
              elixirLS = {
                dialyzerEnabled = true,
                fetchDeps = false,
              },
            },
          })
        end,
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "stylua", "shfmt", "shellcheck",
        "lua-language-server", "elixir-ls",
        "typescript-language-server", "rust-analyzer",
        "gopls", "pyright",
      },
    },
    config = function(_, opts)
      require("mason").setup()
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then p:install() end
      end
    end,
  },
  { "williamboman/mason-lspconfig.nvim", opts = {} },
}
