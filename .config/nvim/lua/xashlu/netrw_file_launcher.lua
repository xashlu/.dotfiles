-- Default configuration
local default_config = {
    mappings = {
        -- Image formats
        ['jpg']  = 'nsxiv',
        ['jpeg'] = 'nsxiv',
        ['png']  = 'nsxiv',
        ['gif']  = 'nsxiv',
        ['webp'] = 'nsxiv',
        -- Documents
        ['pdf']  = 'zathura',
        ['md']   = 'glow',
        -- Office formats
        ['doc']  = 'libreoffice',
        ['docx'] = 'libreoffice',
        ['odt']  = 'libreoffice',
        ['xls']  = 'libreoffice',
        ['xlsx'] = 'libreoffice',
        ['ppt']  = 'libreoffice',
        ['pptx'] = 'libreoffice',
        -- Video formats
        ['mp4']  = 'vlc',
        ['mkv']  = 'vlc',
        ['avi']  = 'vlc',
        ['mov']  = 'vlc',
        ['webm'] = 'vlc',
        ['flv']  = 'vlc',
        ['m4v']  = 'vlc',
        ['mpg']  = 'vlc',
        ['mpeg'] = 'vlc',
        ['wmv']  = 'vlc'
    },
    key = '<F7>',
    term_opener = {'wezterm', 'cli', 'spawn', '--cwd'},
    fallback_opener = 'xdg-open',
    verbose = true
}
local config = vim.deepcopy(default_config)

-- Helper function for logging
local function notify(msg, level)
    if config.verbose then
        vim.notify(msg, level)
    end
end

local function get_netrw_path()
    if vim.bo.filetype == 'netrw' then
        local line = vim.fn.getline('.')
        -- Extract filename from Netrw's listing format
        return line:match("%S+$") or line
    end
    return vim.fn.expand('<afile>')
end

local function resolve_full_path(path)
    -- Get base directory from Netrw or current buffer
    local base_dir = vim.b.netrw_curdir or vim.fn.expand('%:p:h')
    -- Handle absolute paths
    if path:sub(1, 1) == '/' then
        return path
    end
    -- Handle environment variables
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
            opener = {opener}
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
