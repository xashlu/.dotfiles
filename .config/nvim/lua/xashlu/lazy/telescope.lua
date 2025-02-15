return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "plenary",
        config = function()
            require("telescope").load_extension("fzf")
        end,
    },

    config = function()
        local telescope = require('telescope')
        local builtin = require('telescope.builtin')
        telescope.setup {
            defaults = {
                layout_config = { height = 0.5, width = 0.8, preview_cutoff = 2},
            },
            pickers = {
                git_branches = {
                    mappings = {
                        i = {
                            ["<cr>"] = require('telescope.actions').git_switch_branch,
                        },
                        n = {
                            ["<cr>"] = require('telescope.actions').git_switch_branch,
                        },
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                }
            }
        }
        local function save_changes_and_find_files()
            local current_buffer = vim.fn.bufname('%')
            if current_buffer ~= '' and vim.fn.isdirectory(current_buffer) == 0 then
                vim.cmd(':w!')
            end
            builtin.find_files({
                hidden = true,
                find_command = {
                    'fd',
                    '--type', 'file',
                    '--hidden',
                    '--no-ignore',
                    '--no-ignore-vcs',
                    '--exclude', '.git',
                    '--exclude', 'node_modules',
                    '--max-depth', '10',
                    '--threads', '12',
                    '--exclude', 'GAMES',
                    '--exclude', 'OTHER',
                    '--exclude', 'venv',
                }
            })
        end

        local function live_grep_with_hidden()
            builtin.live_grep({
                additional_args = function()
                    return { "--hidden", "--no-ignore", "--no-ignore-vcs" }
                end
            })
        end

        vim.keymap.set('n', '<Tab>', save_changes_and_find_files, {})
        vim.keymap.set('n', 'fj', live_grep_with_hidden, {})
        vim.keymap.set('n', 'fk', function()
            builtin.grep_string({ search = "" })
        end)
        vim.keymap.set('n', 'fh', builtin.help_tags, {})
    end
}
