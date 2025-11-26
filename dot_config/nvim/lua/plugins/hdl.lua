-- HDL (Verilog/VHDL) Support Configuration
return {
  -- Treesitter configuration for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Add verilog and vhdl to the list of parsers
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "verilog", "vhdl" })
      end
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Verible LSP for Verilog/SystemVerilog
        -- Provides linting, formatting, and go-to-definition
        verible = {
          cmd = { "verible-verilog-ls", "--rules_config_search" },
          filetypes = { "verilog", "systemverilog" },
          root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find({ ".git", "verible.filelist" }, { upward = true })[1])
          end,
        },
        -- svlangserver for Verilog/SystemVerilog
        -- Provides code suggestions and additional completion
        svlangserver = {
          filetypes = { "verilog", "systemverilog" },
          root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1])
          end,
        },
        -- VHDL Language Server
        -- Provides VHDL linting and analysis
        vhdl_ls = {
          filetypes = { "vhdl" },
          root_dir = function(fname)
            return vim.fs.dirname(vim.fs.find({ "vhdl_ls.toml", ".git" }, { upward = true })[1])
          end,
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
        "verible",      -- Verilog: linting + navigation
        "svlangserver", -- Verilog: code suggestions
        "rust_hdl",     -- VHDL language server (vhdl_ls)
      })
    end,
  },
}
