--[[
:q
nvim-cmp setup
--]]

local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 3 },
    { name = 'path' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

--[[
lsp config
--]]
-- Install these buffer-local mappings after a language server attaches.
-- See `:help vim.lsp.*` for documentation on the functions below.
local lsp_attach_group = vim.api.nvim_create_augroup('dotfiles-lsp-attach', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_attach_group,
  callback = function(args)
    local bufnr = args.buf
    local client_id = args.data and args.data.client_id
    local client = client_id and vim.lsp.get_client_by_id(client_id)

    -- ty owns Python's semantic features; Ruff supplies linting, fixes, import
    -- organization, and formatting without competing for hover responses.
    if client and client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end

    -- Enable completion triggered by <c-x><c-o>
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  end,
})

-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Extend every server supplied by nvim-lspconfig with nvim-cmp's completion
-- capabilities, then let Neovim activate each server by file type.
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- Keep the previous single-file Lua behavior explicit in the modern API.
vim.lsp.config('lua_ls', {
  workspace_required = false,
})

-- ty already reports Python syntax errors, so keep Ruff focused on linting,
-- code actions, import organization, and formatting.
vim.lsp.config('ruff', {
  init_options = {
    settings = {
      showSyntaxErrors = false,
    },
  },
})

vim.lsp.enable({
  'clangd',
  'lua_ls',
  'ty',
  'ruff',
  'rust_analyzer',
  'texlab',
})

--[[
Mappings for using the diagnostic framework. See `:help vim.diagnostic.*` for
documentation on any of the below functions.
--]]
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
local function diagnostic_jump(count)
  vim.diagnostic.jump({
    count = count,
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      })
    end,
  })
end
vim.keymap.set('n', '[d', function() diagnostic_jump(-vim.v.count1) end, opts)
vim.keymap.set('n', ']d', function() diagnostic_jump(vim.v.count1) end, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
