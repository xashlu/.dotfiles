local M = {}

function M.set_colorscheme()
  vim.cmd[[colorscheme tokyonight]]
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return M
