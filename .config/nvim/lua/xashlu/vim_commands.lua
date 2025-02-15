vim.cmd([[
  augroup auto_save_on_focus_lost
    autocmd!
    autocmd FocusLost * :silent! write
  augroup END
]])
