-- We need to just put this here before we remap 'n'
-- map k and K to search next and search previous
vim.keymap.set('n', 'k', function()
  if vim.fn.getreg '/' == '' then
    return 'k' -- fallback to normal up movement
  else
    return 'n' -- jump to next search match
  end
end, { expr = true, noremap = true, silent = true })

vim.keymap.set('n', 'K', function()
  if vim.fn.getreg '/' == '' then
    return 'K' -- fallback to default "move up 12 lines" behavior
  else
    return 'N' -- jump to previous search match
  end
end, { expr = true, noremap = true, silent = true })
--
-- n, v, i, t = mode names

local map_list = {
  -- Direction keys
  ['h'] = 'h',
  ['n'] = 'j',
  ['e'] = 'k',
  ['i'] = 'l',

  -- Insert in place at at next char
  ['s'] = 'i',
  ['t'] = 'a',
  ['T'] = 'A',

  -- Home and end
  ['H'] = '<Home>',
  ['I'] = '<End>',

  -- Up and Down
  ['N'] = '<C-d> zz',
  ['E'] = '<C-u> zz',

  ['<C-Bslash>'] = ':let @/ = ""<CR>',

  ['<PageUp>'] = '<Nop>',
  ['<PageDown>'] = '<Nop>',

  -- Telescope mappings
  ['<space>fb'] = ':Telescope file_browser path=%:p:h select_buffer=true<CR>',

  -- Insert one character while remaining in insert mode
  ['<C-s>'] = 's_<Esc>r',
  ['<C-t>'] = 't_<Esc>r',

  -- Quickly copy entire file without losing place
  ['<leader>yy'] = '<cmd>%y+<CR>',
}

local i_map_list = {
  ['<PageUp>'] = '<Nop>',
  ['<PageDown>'] = '<Nop>',
}

-- Insert mode keymap
local keymap = vim.keymap.set

for key, binding in pairs(map_list) do
  keymap('n', key, binding, { noremap = true, silent = true })
end

for key, binding in pairs(i_map_list) do
  keymap('i', key, binding, { noremap = true, silent = true })
end
