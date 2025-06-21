local M = {}

function M.open_tmux_sessions_in_nvim()
  -- Check if we are inside tmux
  local tmux_env = os.getenv("TMUX")
  if tmux_env == nil then
    print("Not running inside tmux.")
    return
  end

  -- Run tmux ls command
  local handle = io.popen("tmux ls | awk -F: '{print $1}' 2>/dev/null")
  if not handle then
    print("Not running inside tmux.")
    return
  end

  local sessions = handle:read("*a")
  handle:close()

  if sessions == "" then
    print("No tmux sessions found.")
    return
  end

  -- Create a temporary file
  local tmpfile = os.tmpname()
  local file = io.open(tmpfile, "w")
  if not file then
    print("Failed to create temporary file.")
    return
  end

  file:write(sessions)
  file:close()

  -- Open new Neovim instance in a new WezTerm tab
  local cmd = string.format("wezterm cli spawn nvim '%s' 2>/dev/null &", tmpfile)
  local ok = os.execute(cmd)
  if not ok then
    print("Failed to open new WezTerm tab.")
    return
  end
end

return M
