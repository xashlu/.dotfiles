-- Default configuration
local default_config = {
    mappings = {
        -- Image formats (resolved dynamically)
        ['jpg']  = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['jpeg'] = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['png']  = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['gif']  = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        ['webp'] = os.getenv('IMAGE_VIEWER') or 'nsxiv',
        -- Documents (resolved dynamically)
        ['pdf']  = os.getenv('DOCUMENT_VIEWER') or 'zathura',
        ['md']   = 'glow', -- No fallback needed, glow is specific
        -- Use $EDITOR or fallback to xdg-open
        ['txt']  = os.getenv('EDITOR') or 'xdg-open',
        -- Office formats (resolved dynamically)
        ['doc']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['docx'] = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['odt']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['xls']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['xlsx'] = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['ppt']  = os.getenv('OFFICE_SUITE') or 'libreoffice',
        ['pptx'] = os.getenv('OFFICE_SUITE') or 'libreoffice',
        -- Video formats (resolved dynamically)
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
    key = '<F7>',
    term_opener = vim.split(os.getenv('TERMINAL') or 'wezterm cli spawn --cwd', '%s+'),
    fallback_opener = 'xdg-open',
    verbose = true
}
local config = vim.deepcopy(default_config)

-- Helper function for logging
local function notify(msg, level)
    if config.verbose then
        vim.notify(msg, level or vim.log.levels.INFO)
    end
end

-- Function to get path from Netrw or current buffer
local function get_netrw_path()
    if vim.bo.filetype == 'netrw' then
        local line = vim.fn.getline('.')
        -- Extract filename from Netrw's listing format
        return line:match("%S+$") or line
    end
    return vim.fn.expand('<afile>')
end

-- Function to resolve full path with environment variable handling
local function resolve_full_path(path)
    notify("Input path: " .. path, vim.log.levels.DEBUG)

    -- Handle absolute paths
    if path:sub(1, 1) == '/' then
        return path
    end

    -- Handle environment variables in the path
    if path:sub(1, 1) == '$' then
        local var_end = path:find('/') or (#path + 1)
        local var = path:sub(2, var_end - 1)
        local rest = path:sub(var_end + 1)
        local expanded = os.getenv(var:upper()) or os.getenv(var:lower())
        if not expanded then
            notify("Environment variable $" .. var .. " not found", vim.log.levels.WARN)
            return nil
        end
        path = expanded .. '/' .. rest
    end

    -- Construct full path
    local base_dir = vim.b.netrw_curdir or vim.fn.expand('%:p:h')
    local full_path = base_dir .. '/' .. path
    full_path = vim.fn.resolve(full_path)

    -- Validate existence
    if vim.fn.filereadable(full_path) == 1 or vim.fn.isdirectory(full_path) == 1 then
        return full_path
    end
    notify("Path not found: " .. full_path, vim.log.levels.ERROR)
    return nil
end

-- Module setup function
local M = {}

function M.open_file()
    local path = get_netrw_path()
    if not path or path == '' then
        notify("No file selected", vim.log.levels.INFO)
        return
    end

    notify("Raw path: " .. path, vim.log.levels.DEBUG)
    local full_path = resolve_full_path(path)
    if not full_path then return end

    if vim.fn.isdirectory(full_path) == 1 then
        notify("Opening directory: " .. full_path, vim.log.levels.INFO)
        local cmd = vim.list_extend({}, config.term_opener)
        table.insert(cmd, full_path)
        vim.fn.jobstart(cmd, { detach = true })
    else
        local ext = vim.fn.fnamemodify(full_path, ':e'):lower()
        local opener = config.mappings[ext] or config.fallback_opener
        if type(opener) == 'string' then
            opener = { opener }
        end

        notify("Opening with " .. table.concat(opener, ' ') .. ": " .. full_path, vim.log.levels.INFO)
        local cmd = vim.list_extend({}, opener)
        table.insert(cmd, full_path)
        vim.fn.jobstart(cmd, {
            detach = true,
            on_exit = function(_, code)
                if code ~= 0 then
                    notify("Failed to open: " .. full_path, vim.log.levels.ERROR)
                end
            end
        })
    end
end

function M.setup(user_config)
    config = vim.tbl_deep_extend('force', config, user_config or {})
    -- Normalize term_opener to list format
    if type(config.term_opener) == 'string' then
        config.term_opener = vim.split(config.term_opener, '%s+')
    end
    vim.keymap.set({'n', 'v'}, config.key, M.open_file, {
        desc = 'Open file/directory in external application'
    })
end

M.setup()

return M

