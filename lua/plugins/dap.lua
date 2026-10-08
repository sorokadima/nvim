local langgraph_app = "/Users/dmytro/projects/lucy/ticker_llm_tools/services/langgraph-app"

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      {
        "microsoft/vscode-js-debug",
        version = "1.*",
        build = "npm install --legacy-peer-deps && npx gulp dapDebugServer",
      },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
        desc = "Breakpoint (condition)",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / Start" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Re-run Last" },
      { "<leader>dx", function() require("dap").terminate() end, desc = "Stop/Detach" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Dap UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- dapDebugServer.js говорить звичайний DAP по TCP (на відміну від
      -- vsDebugServer.js з legacy-рев'юс-реквестами) — nvim-dap вміє
      -- "startDebugging" нативно, окремий плагін-адаптер не потрібен.
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "node",
          -- Третій аргумент — явний host: дефолтний "localhost" тут резолвиться
          -- в ::1 (IPv6-only), а конектимось ми на 127.0.0.1 → ECONNREFUSED.
          args = {
            vim.fn.stdpath("data") .. "/lazy/vscode-js-debug/dist/src/dapDebugServer.js",
            "${port}",
            "127.0.0.1",
          },
        },
      }

      for _, lang in ipairs({ "typescript", "javascript" }) do
        dap.configurations[lang] = {
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach: langgraph (Docker, port 9229)",
            address = "localhost",
            port = 9229,
            cwd = langgraph_app,
            localRoot = langgraph_app,
            remoteRoot = "/app",
            protocol = "inspector",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
        }
      end
    end,
  },
}
