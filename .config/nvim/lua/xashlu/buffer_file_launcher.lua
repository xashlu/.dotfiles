-- Default configuration
local config = {
    mappings = {
        -- Image formats
        ['jpg']  = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['jpeg'] = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['png']  = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['gif']  = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['webp'] = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        -- Documents
        ['pdf']  = os.getenv('DOCUMENT_VIEWER') or 'zathura',
        ['md']   = 'glow', -- No fallback needed, glow is specific
        -- Use $EDITOR or fallback to xdg-open
        ['txt']  = os.getenv('EDITOR') or 'xdg-open',
        -- Office formats
        ['doc']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['docx'] = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['odt']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['xls']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['xlsx'] = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['ppt']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['pptx'] = os.getenv('OFFICE_SUITE') or 'libreoffice',
        -- Video formats
        ['mp4']  = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['mkv']  = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['avi']  = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['mov']  = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['webm'] = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['flv']  = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['m4v']  = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['mpg']  = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['mpeg'] = os.getenv('VIDEO_PLAYER') or 'vlc',
        ['wmv']  = os.getenv('VIDEO_PLAYER') or 'vlc'
    },
    key = '<F5>',
}

-- Function to transform and resolve the path
local function transform_path(path)

    vim.notify("Input path: " .. path, vim.log.levels.INFO)
    local components = vim.split(path, '/', { plain = true })
    local current_path
    if components[1]:sub(1, 1) == '$' then
        local var = components[1]:sub(2)
        if var == var:lower() then
            var = var:upper()
        end
        local expanded = os.getenv(var)
        if not expanded then
            vim.notify("Warning: Environment variable $" .. var .. " not set", vim.log.levels.WARN)
            return nil
        end
        current_path = expanded
        table.remove(components, 1)
    else
        current_path = components[1]
        table.remove(components, 1)
    end
    vim.notify("After env var: " .. current_path, vim.log.levels.INFO)
    for i = 1, #components - 1 do
        local comp = components[i]
        local full_path = current_path .. '/' .. comp
        if vim.fn.isdirectory(full_path) == 1 then
            vim.notify("Found dir: " .. full_path, vim.log.levels.INFO)
        else
            local dirs = {}
            for _, dir in ipairs(vim.fn.glob(current_path .. '/*', 0, 1)) do
                if vim.fn.isdirectory(dir) == 1 then
                    table.insert(dirs, vim.fn.fnamemodify(dir, ':t'))
                end
            end
            local found = false
            for _, dir in ipairs(dirs) do
                if string.lower(dir) == string.lower(comp) then
                    comp = dir
                    found = true
                    break
                end
            end
            if not found then
                vim.notify("Warning: directory '" .. comp .. "' not found in " .. current_path, vim.log.levels.WARN)
            end
        end
        current_path = current_path .. '/' .. comp
        vim.notify("Current path: " .. current_path, vim.log.levels.INFO)
    end

    local filename = components[#components]
    local dir_path = current_path
    local files = vim.fn.glob(dir_path .. '/*', 0, 1)
    local final_filename = filename
    for _, file in ipairs(files) do
        local basename = vim.fn.fnamemodify(file, ':t')
        if string.lower(basename) == string.lower(filename) then
            final_filename = basename
            break
        end
    end
    local final_path = dir_path .. '/' .. final_filename
    vim.notify("Final path: " .. final_path, vim.log.levels.INFO)
    return final_path
end

-- Function to open the file or directory
local function open_file_or_directory()

    local path = vim.fn.expand('<cfile>')
    if path == '' then
        vim.notify("No file path under cursor", vim.log.levels.INFO)
        return
    end

    -- Get the current buffer's path
    local buffer_path = vim.fn.expand('%:p')
    if buffer_path == '' then
        vim.notify("Current buffer has no file path", vim.log.levels.WARN)
        return
    end

    -- Compute parent of the parent directory of the buffer's path
    local parent_parent = vim.fn.fnamemodify(buffer_path, ':h:h')

    -- Replace $j in the path with the computed directory
    path = path:gsub('%$j', parent_parent)

    -- Check if the path is a URL (starts with http:// or https://)
    if path:match('^https?://') then
        -- Resolve BROWSER environment variable
        local browser = os.getenv('BROWSER') or 'xdg-open'

        -- Log the resolved browser and URL
        vim.notify("Resolved browser: " .. browser, vim.log.levels.INFO)
        vim.notify("Opening URL with: " .. browser, vim.log.levels.INFO)

        -- Open the URL with the resolved browser
        vim.fn.jobstart({ browser, path })
        return
    end

    -- Transform and resolve the path
    local transformed = transform_path(path)
    if not transformed then
        vim.notify("Failed to transform path: " .. path, vim.log.levels.ERROR)
        return
    end

    -- Check if the path is a directory
    if vim.fn.isdirectory(transformed) == 1 then
        -- Resolve TERMINAL environment variable
        local terminal = os.getenv('TERMINAL') or 'wezterm'
        local terminal_command = { terminal, 'cli', 'spawn', '--cwd', transformed }

        -- Log the resolved terminal command
        vim.notify("Resolved terminal: " .. terminal, vim.log.levels.INFO)
        vim.notify("Opening directory in terminal: " .. transformed, vim.log.levels.INFO)

        -- Open directory in the terminal
        vim.fn.jobstart(terminal_command, { detach = true })
    else
        -- Extract file extension (lowercase)
        local ext = transformed:match('%.([^%.]+)$') or ''
        ext = ext:lower()

        -- Determine the application to use
        -- xdg-open: fallback to system default
        local app = config.mappings[ext] or 'xdg-open'
        if not app then
            vim.notify("No application mapped for extension: " .. ext, vim.log.levels.WARN)
            return
        end

        -- Resolve $EDITOR dynamically if needed
        if ext == 'txt' and app == os.getenv('EDITOR') then
            app = os.getenv('EDITOR') or 'xdg-open'
        end

        -- Log the resolved application and file path
        vim.notify("Resolved application: " .. app, vim.log.levels.INFO)
        vim.notify("File to open: " .. transformed, vim.log.levels.INFO)

        -- Handle .txt files in the current Neovim session
        if ext == 'txt' then
            vim.cmd('edit ' .. vim.fn.fnameescape(transformed))
            return
        end

        -- Open the file with the resolved application
        vim.notify("Opening file with: " .. app, vim.log.levels.INFO)
        vim.fn.jobstart({ app, transformed })
    end
end

-- Module setup function
local M = {}
M.setup = function(opts)
    config = vim.tbl_extend('force', config, opts or {})
    vim.keymap.set({'n', 'v'}, config.key, open_file_or_directory)
end
M.open_file_or_directory = open_file_or_directory -- Expose for manual use

-- Default keymap if not using setup
vim.keymap.set({'n', 'v'}, config.key, open_file_or_directory)

return M

