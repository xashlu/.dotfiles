return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio"
    },
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')
        dapui.setup()
        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "-i", "dap" }
        }
        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "gdb",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.expand('%:p'), 'file')
                end,
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
        }
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
        vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, {})
        vim.keymap.set('n', '<Leader>dc', dap.continue, {})
        vim.keymap.set('n', '<Leader>cc', dapui.close, {})
    end
}
