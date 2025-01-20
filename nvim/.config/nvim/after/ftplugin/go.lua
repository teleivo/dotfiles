local width = 4
vim.opt_local.tabstop = width
vim.opt_local.shiftwidth = width
vim.opt_local.softtabstop = width
-- show the colorcolumn to double-check how gofumpt behaves with
-- https://github.com/mvdan/gofumpt/issues/2
-- honours the max column of 100
vim.opt_local.colorcolumn = '100'
