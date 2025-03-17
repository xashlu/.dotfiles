-- Default configuration
local config = {
    mappings = {
        ['jpg']  = 'nsxiv',
        ['jpeg'] = 'nsxiv',
        ['png']  = 'nsxiv',
        ['pdf']  = 'zathura',
        ['doc']  = 'libreoffice',
        ['docx'] = 'libreoffice',
        ['odt']  = 'libreoffice',
    },
    key = '<F5>',
}

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

-- Function to open the file with the appropriate application
local function open_file()
    local path = vim.fn.expand('<cfile>')
    if path == '' then
        vim.notify("No file path under cursor", vim.log.levels.INFO)
        return
    end
    local transformed = transform_path(path)
    if not transformed then
        vim.notify("Failed to transform path: " .. path, vim.log.levels.ERROR)
        return
    end

    -- Extract file extension (lowercase)
    local ext = transformed:match('%.([^%.]+)$') or ''
    ext = ext:lower()

    -- Determine the application to use
    local app = config.mappings[ext] or 'xdg-open' -- Fallback to system default
    if not app then
        vim.notify("No application mapped for extension: " .. ext, vim.log.levels.WARN)
        return
    end

    -- Open the file
    vim.fn.jobstart({ app, transformed }, { detach = true })
end

-- Module setup function
local M = {}
M.setup = function(opts)
    config = vim.tbl_extend('force', config, opts or {})
    vim.keymap.set({'n', 'v'}, config.key, open_file)
end
M.open_file = open_file -- Expose for manual use

-- Default keymap if not using setup
vim.keymap.set({'n', 'v'}, config.key, open_file)

return M
