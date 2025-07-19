-- LazyNvim utility functions
local M = {}

-- Check if a plugin is loaded
function M.has(plugin)
  return require("lazy.core.config").plugins[plugin] ~= nil
end

-- Toggle a boolean option
function M.toggle(name, levels)
  levels = levels or { true, false }
  local current = vim.opt[name]:get()
  for i, level in ipairs(levels) do
    if current == level then
      vim.opt[name] = levels[i % #levels + 1]
      break
    end
  end
end

-- Toggle diagnostics
function M.toggle_diagnostics()
  local diagnostics_active = true
  return function()
    diagnostics_active = not diagnostics_active
    if diagnostics_active then
      vim.diagnostic.show()
    else
      vim.diagnostic.hide()
    end
  end
end

-- Get root directory
function M.get_root()
  local fname = vim.api.nvim_buf_get_name(0)
  local root = vim.fn.fnamemodify(fname, ":p:h")
  ---@type string?
  for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
    local workspace = client.config.workspace_folders
    local paths = workspace and vim.tbl_map(function(ws)
      return vim.uri_to_fname(ws.uri)
    end, workspace) or client.config.root_dir and { client.config.root_dir } or {}
    for _, path in ipairs(paths) do
      path = vim.fn.expand(path)
      if root:find(path, 1, true) == 1 then
        return path
      end
    end
  end
  return root
end

-- Telescope wrapper
function M.telescope(builtin, opts)
  local params = { builtin = builtin, opts = opts }
  return function()
    builtin = params.builtin
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = M.get_root() }, opts or {})
    if builtin == "files" then
      opts = vim.tbl_deep_extend("force", opts, {
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
      })
    end
    require("telescope.builtin")[builtin](opts)
  end
end

-- Float terminal wrapper
function M.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    size = { width = 0.9, height = 0.9 },
  }, opts or {})
  require("lazy.util").float_term(cmd, opts)
end

-- LSP utilities
function M.lsp(on_attach, servers)
  local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities()
  )

  require("lspconfig").util.on_setup = require("lspconfig").util.add_hook_before(
    require("lspconfig").util.on_setup,
    function(config)
      config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities)
      if on_attach then
        config.on_attach = function(client, bufnr)
          on_attach(client, bufnr)
        end
      end
    end
  )

  for server, opts in pairs(servers) do
    opts = opts or {}
    require("lspconfig")[server].setup(opts)
  end
end

-- Format on save
function M.format_on_save()
  vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
      vim.lsp.buf.format()
    end,
  })
end

-- Auto commands
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin
function M.load(plugin, time)
  if plugin then
    time = time or 0
    if type(plugin) == "string" then
      require("lazy").load({ plugins = { plugin } }, { wait = time })
    else
      require("lazy").load(plugin, { wait = time })
    end
  end
end

-- Load plugin on filetype
function M.on_filetype(pattern, fn)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = pattern,
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on event
function M.on_event(event, fn)
  vim.api.nvim_create_autocmd(event, {
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on buffer
function M.on_buffer(fn)
  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert mode
function M.on_insert(fn)
  vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on visual mode
function M.on_visual(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:[vV\x16]*",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on operator pending mode
function M.on_operator(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:o",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on command mode
function M.on_command(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:c",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on terminal mode
function M.on_terminal(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:t",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on normal mode
function M.on_normal(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:n",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on replace mode
function M.on_replace(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:R",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on select mode
function M.on_select(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:s",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on virtual replace mode
function M.on_virtual_replace(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:Rv",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert normal mode
function M.on_insert_normal(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niI",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert visual mode
function M.on_insert_visual(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niV",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert select mode
function M.on_insert_select(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niS",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert replace mode
function M.on_insert_replace(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niR",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert virtual replace mode
function M.on_insert_virtual_replace(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niRv",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert operator pending mode
function M.on_insert_operator(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niO",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert command mode
function M.on_insert_command(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niC",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert terminal mode
function M.on_insert_terminal(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niT",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert insert mode
function M.on_insert_insert(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:nii",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert normal mode
function M.on_insert_normal(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niI",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert visual mode
function M.on_insert_visual(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niV",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert select mode
function M.on_insert_select(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niS",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert replace mode
function M.on_insert_replace(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niR",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert virtual replace mode
function M.on_insert_virtual_replace(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niRv",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert operator pending mode
function M.on_insert_operator(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niO",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert command mode
function M.on_insert_command(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niC",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert terminal mode
function M.on_insert_terminal(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:niT",
    callback = function()
      fn()
    end,
  })
end

-- Load plugin on insert insert mode
function M.on_insert_insert(fn)
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:nii",
    callback = function()
      fn()
    end,
  })
end

return M 