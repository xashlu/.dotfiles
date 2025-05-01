local M = {}

local target_path = vim.fn.expand("$HOME/input.txt")

local function prepend_date_to_file()
    -- Only operate on the explicit file
    if vim.fn.expand("%:p") ~= target_path then
        return
    end

    -- Save current cursor position
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Read full buffer content
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    -- Format: YYYY-MM-DD HH:MM
    local date_str = os.date("%Y-%m-%d %H:%M")
    -- If first line matches ISO date and time and second line is empty, remove both
    if lines[1] and lines[1]:match("^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d$") then
        table.remove(lines, 1)
        if lines[1] and lines[1] == "" then
            table.remove(lines, 1)
        end
    end
    -- Insert date string and newline at the top
    table.insert(lines, 1, "")        -- Add empty line first
    table.insert(lines, 1, date_str)  -- Add date before empty line
    -- Replace buffer lines
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

    -- Restore cursor position (move down by two due to date and newline if not at top)
    if row ~= 1 then
        vim.api.nvim_win_set_cursor(0, {row + 2, col})
    end
end

function M.setup()
    -- Create user command
    vim.api.nvim_create_user_command('UpdateTimelineDate', prepend_date_to_file, {})

    -- Create autocommands
    local group = vim.api.nvim_create_augroup("AutoDateTxt", { clear = true })
    -- Update on buffer read
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        pattern = target_path,
        callback = prepend_date_to_file,
        group = group,
    })

    -- Update when entering buffer
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = target_path,
        callback = prepend_date_to_file,
        group = group,
    })

    -- Optional: Update when saving buffer
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = target_path,
        callback = prepend_date_to_file,
        group = group,
    })
end

-- Autoload on require
M.setup()

return M
