local C = {}

C.convertdosunix = function()
  vim.cmd 'e ++ff=dos'
  vim.bo.fileformat = 'unix'
  print 'Line endings converted'
end

vim.api.nvim_create_user_command('DosToUnix', C.convertdosunix, {})

vim.keymap.set('n', '<leader>du', C.convertdosunix, { silent = true })

return C
