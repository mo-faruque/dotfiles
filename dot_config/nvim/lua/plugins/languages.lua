-- Python, MATLAB, and C++ Language Support
return {
  -- Treesitter configuration for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "python", "cpp", "c" })
      end
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Python LSP (pyright)
        -- Provides type checking, auto-completion, and IntelliSense
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
              },
            },
          },
        },

        -- C/C++ LSP (clangd)
        -- Provides code completion, navigation, and diagnostics
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
          },
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        },

      },
    },
  },

  -- Mason configuration to install LSP servers
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright",    -- Python LSP
        "clangd",     -- C/C++ LSP
      })
    end,
  },
}
