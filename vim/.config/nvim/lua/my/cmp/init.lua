local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      menu = {
        nvim_lua = '[API]',
        nvim_lsp = '[LSP]',
        path = '[path]',
        luasnip = '[snip]',
        buffer = '[buf]',
      },
    }),
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm()
      else
        fallback()
      end
    end,
  },
  experimental = {
    ghost_text = true,
  },
  sources = {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 4 },
  },
})

cmp.setup.cmdline(':', {
  sources = {
    { name = 'cmdline' },
  },
})

vim.cmd([[
  " light red (dogrun Error)
  highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#dc6f79
  " pink
  highlight! CmpItemAbbrMatch guibg=NONE guifg=#b871b8
  highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#b871b8
  highlight! CmpItemKindInterface guibg=NONE guifg=#b871b8
  " grey (dogrun normal)
  highlight! CmpItemKindVariable guibg=NONE guifg=#9ea3c0
  highlight! CmpItemKindField guibg=NONE guifg=#9ea3c0
  highlight! CmpItemKindText guibg=NONE guifg=#9ea3c0
  " blue (dogrun Function)
  highlight! CmpItemKindFunction guibg=NONE guifg=#929be5
  highlight! CmpItemKindMethod guibg=NONE guifg=#929be5
  " light brown/orange?
  highlight! CmpItemKindKeyword guibg=NONE guifg=#ac8b83
  highlight! CmpItemKindProperty guibg=NONE guifg=#ac8b83
  highlight! CmpItemKindUnit guibg=NONE guifg=#ac8b83
  highlight! CmpItemKindStruct guibg=NONE guifg=#ac8b83
  " bright green
  highlight! CmpItemKindModule guibg=NONE guifg=#73c1a9
]])
