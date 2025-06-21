vim.cmd([[
  augroup auto_save_on_focus_lost
    autocmd!
    autocmd FocusLost * :silent! write
  augroup END
]])

vim.api.nvim_create_user_command('RR', function()
    -- Reload init.lua or init.vim
    vim.cmd('source $MYVIMRC')
    print("Configuration reloaded!")
end, {})

vim.api.nvim_create_user_command('R', function()
    vim.cmd([[
        silent! %s/^\(.\)/\[\1\r\1
        silent! %s;^[^(]*(\([^)]*\)).*;\1;
        silent! %s;, ;\r;g
        silent! %s;=.*;;
        silent! %s;$; A;
        silent! %s/^\[.*\zs A.*$//
    ]])
end, {})

-- Netrw-specific mapping
vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.keymap.set("n", "<F10>", CopyNetrwPath, {
      buffer = true,
      desc = "Copy Netrw path to system clipboard"
    })
  end
})

-- Normal file buffers (non-netrw)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "netrw" then return end -- already handled above

    vim.keymap.set("n", "<F10>", function()
      require("xashlu.personal.tmux_sessions").open_tmux_sessions_in_nvim()
      end, {
      buffer = true,
      desc = "List tmux sessions"
    })
  end
})
