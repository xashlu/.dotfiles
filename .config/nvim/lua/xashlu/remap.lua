vim.g.mapleader = " "

vim.keymap.set("n", "<leader>c", function()
  vim.cmd("normal! V")
  vim.cmd("normal! u")
  vim.cmd("s/ \\+/-/g")
  local current_line = vim.fn.getline(".")
  if current_line:match("[()&+]") then
    vim.cmd("s/[()&+]//g")
  end
  vim.cmd("s/\\(-\\)\\{2,\\}/-/g")
end)

vim.keymap.set('n', '<F3>',
    function()
        local p = vim.api.nvim_win_get_cursor(0); vim.api.nvim_win_set_cursor(0, { 1, 0 }); require('Comment.api')
            .toggle.linewise.current(); vim.api.nvim_win_set_cursor(0, p)
    end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>t", function()
    local current_dir = vim.fn.expand('%:p:h')
    if current_dir == "" then
        current_dir = vim.fn.getcwd()
    end

    local script_path = vim.fn.expand("$HOME/.local/bin/create-tmux-session-on-current-directory.sh")
    local wezterm_pid = vim.fn.system("pgrep -f 'wezterm' | head -n1"):gsub("\n", "")
    local wezterm_command = string.format("wezterm start --cwd %s bash -c 'bash %s %s'",
                                          vim.fn.shellescape(current_dir),
                                          vim.fn.shellescape(script_path),
                                          vim.fn.shellescape(current_dir))

    vim.fn.jobstart(wezterm_command, { detach = true })
    if wezterm_pid ~= "" then
        vim.fn.jobstart("kill -9 " .. wezterm_pid, { detach = true })
    end
end, { noremap = true, silent = true })


local function compile_and_run_cpp()
    local filepath = vim.fn.expand('%:p')
    local output_dir = vim.fn.fnamemodify(filepath, ':h') .. '/output'
    local output_executable = output_dir .. '/zzz'
    local temp_error_file = '/tmp/compile_errors.txt'

    os.execute('mkdir -p ' .. output_dir)

    local compile_command = 'g++ -std=c++20 ' .. filepath .. ' -o ' .. output_executable .. ' 2> ' .. temp_error_file
    local compile_result = os.execute(compile_command)

    if compile_result == 0 then
        print('Compiled successfully')
        vim.cmd('terminal ' .. output_executable)
    else
        print('Compilation failed. Check the errors:')
        vim.cmd('terminal cat ' .. temp_error_file)
    end
end

vim.keymap.set('n', '<BS>', compile_and_run_cpp)

vim.keymap.set({'n', 'i'}, '<C-x>', function()
    if vim.api.nvim_get_mode().mode == 'i' then
        vim.cmd('stopinsert')  -- Exit insert mode
    end
    vim.cmd('wq')
end, { desc = 'Save and quit the file with Ctrl-X' })

local function compile_and_run_java()
    local filepath = vim.fn.expand('%:p')

    local compile_command = 'javac ' .. filepath
    local compile_result = os.execute(compile_command)
    if compile_result == 0 then
        print('Compiled successfully')
        local class_name = vim.fn.fnamemodify(filepath, ':t:r')
        local run_command = 'java ' .. class_name
        local run_result = os.execute(run_command)

        if run_result == 0 then
            os.execute('rm *.class')
        else
            print('Error running the Java program')
            vim.cmd('terminal ' .. run_command)
        end
    else
        print('Compilation failed. Check the errors:')
        vim.cmd('terminal ' .. compile_command)
    end
end

vim.keymap.set('n', '<F4>', compile_and_run_java)
--vim.keymap.set("n", "<F4>", ":w<cr>:terminal lua % <CR>")
--vim.keymap.set("n", "<F2>", ":w<cr>:terminal gcc -std=gnu11 % -o zzc && ./zzc<CR>")
vim.keymap.set("n", "<F2>", ":w<cr>:terminal python % <CR>")
vim.keymap.set("x", "<leader>e", [[:s/'/'\\''/g<CR>]], { noremap = true, silent = true })
vim.keymap.set("n", "-", "i<C-d>")

vim.keymap.set("n", "<leader><Tab>", function()
    local current_dir = vim.fn.expand('%:p:h')
    if current_dir == "" then
        current_dir = vim.fn.getcwd()
    end
    vim.fn.jobstart(string.format("wezterm start --cwd %s", vim.fn.shellescape(current_dir)), { detach = true })
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-p>", ":Ex<CR>")
vim.keymap.set("n", "\\", ":g/^/norm gqq<cr>gg")

vim.keymap.set("n", "=", function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd('%!clang-format')
    vim.fn.setpos(".", save_cursor)
end, { silent = true })

vim.keymap.set("v", "<leader>Y", "^y$")

vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")

vim.keymap.set("n", "<cr>", "O<esc><cr>_i<cr><Esc>--i")
vim.keymap.set("n", "<leader><leader>", ":w<cr>:Ex<cr>")

vim.keymap.set("n", "|", ":w<cr>:! $HOME/.local/bin/create-dirs-and-files.sh %<CR>")

vim.keymap.set("n", "Z", ":q!<cr>")
vim.keymap.set("n", "<C-\'>", ":wq<cr>")
vim.keymap.set('n', 'Y', '"ay0v$hydd', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>b", ":w | :bp | <enter>")
vim.keymap.set("n", "<leader>n", ":w | :bn | <enter>")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<F6>', "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<S-F6>',
    "<cmd>CompilerStop<cr>"
    .. "<cmd>CompilerRedo<cr>",
    { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<S-F7>', "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })

function ManualSyncNetrwWithPwd()
  local netrw_dir = vim.fn.expand('%:p:h')
  if vim.fn.isdirectory(netrw_dir) == 1 then
    vim.cmd("cd " .. netrw_dir)
  end
end
vim.keymap.set('n', '<leader>cd', ManualSyncNetrwWithPwd)
