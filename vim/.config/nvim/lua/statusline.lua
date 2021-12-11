local buffer_number = '[%n]'
local filename = ' %f %<'
local modified = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
local readonly = "%{&readonly ? '[RO] ' : ''}"
local filetype = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
local git = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
local sep = ' %= '
local position = ' %-12(%l : %c%V%) '
local percentage = ' %P'

local statusline = {
  buffer_number,
  filename,
  modified,
  readonly,
  filetype,
  git,
  sep,
  position,
  percentage,
}
vim.o.statusline = table.concat(statusline)
-- always show the statusline
vim.o.laststatus = 2
