local module_name = os.getenv("USER")
local status, err = pcall(require, module_name)
if not status then
  print("Failed to load module: " .. err)
end
