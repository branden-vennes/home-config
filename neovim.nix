{ vimPlugins, awesomeNeovimPlugins, lombok, ... }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with vimPlugins; [
    nvim-treesitter.withAllGrammars

    nvim-lspconfig

    nvim-jdtls

    mini-extra
    mini-icons
    mini-files
    mini-completion
    mini-cursorword
    mini-animate
    mini-statusline
    mini-tabline
    mini-git
    mini-surround
    mini-trailspace
    mini-pick
  ] ++ (
    with awesomeNeovimPlugins; [
      # themes
      token
      citruszest-nvim

      nvim-metals
    ]
  );

  initLua = #lua
    ''
      -- start  General Options
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      vim.opt.statuscolumn = "%=%l %s"
      vim.opt.number = true

      vim.opt.winborder = "rounded"

      vim.opt.colorcolumn = "121"

      vim.wo.wrap = true

      vim.opt.ignorecase = true

      vim.cmd("set tabstop=2")
      vim.cmd("set shiftwidth=2")
      vim.cmd("set expandtab")
      vim.cmd("set termguicolors")
      -- end    General Options

      local map = vim.keymap.set
      local lsp = vim.lsp.buf

      -- start  General Mappings
      map("n", "K", lsp.hover)
      map("n", "<leader>ca", lsp.code_action)
      map("n", "<leader>tp", function ()
        vim.cmd("tabprevious")
      end)
      map("n", "<leader>tt", function ()
        vim.cmd("tabnext")
      end)
      map("n", "<leader>tn", function ()
        vim.cmd("tabnew")
      end)
      map("n", "<leader>rv", function ()
        vim.cmd("vertical resize 120")
      end)

      map("n", "<leader>bd", function ()
        vim.cmd("bdelete")
      end)

      map("t", "<ESC>", "<C-\\><C-n>", { silent = true })


      -- end    General Mappings

      -- start  Mini Extra
      local MiniExtra = require("mini.extra")
      MiniExtra.setup({})

      map("n", "gR", function () MiniExtra.pickers.lsp({ scope = "references" }) end)
      map("n", "gD", function () MiniExtra.pickers.lsp({ scope = "definition" }) end)
      map("n", "gI", function () MiniExtra.pickers.lsp({ scope = "implementation" }) end)
      map("n", "<leader>fs", function () MiniExtra.pickers.lsp({ scope = "document_symbol" }) end)
      -- end    Mini Extra

      -- start  Mini Icons
      local MiniIcons = require("mini.icons")
      MiniIcons.setup({})
      -- end    Mini Icons

      -- start  Mini Files
      local MiniFiles = require('mini.files')
      MiniFiles.setup({})

      map(
        "n",
        "<leader>fe",
        function()
          MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
        end
      )

      map(
        "n",
        "<leader>re",
        function()
          MiniFiles.open()
        end
      )
      -- end    Mini Files

      -- start  Mini Cursorword
      local MiniCursorword = require('mini.cursorword')
      MiniCursorword.setup({});
      -- end    Mini Cursorword

      -- start  Mini Completion
      local MiniCompletion = require('mini.completion')
      MiniCompletion.setup({});
      -- end    Mini Completion

      -- start  Mini Animate
      local MiniAnimate = require('mini.animate')
      MiniAnimate.setup({});
      -- end    Mini Animate

      -- start  Mini Statusline
      local MiniStatusline = require('mini.statusline')
      MiniStatusline.setup({});
      -- end    Mini Statusline

      -- start  Mini Tabline
      local MiniTabline = require('mini.tabline')
      MiniTabline.setup({});
      -- end    Mini Tabline

      -- start  Mini Trailspace
      local MiniTrailspace = require("mini.trailspace")
      MiniTrailspace.setup({});
      -- end    Mini Trailspace


      -- start  Mini Git
      local MiniGit = require("mini.git")
      MiniGit.setup()

      map(
        { 'n', 'x' },
        '<Leader>gs',
        function ()
          MiniGit.show_at_cursor()
        end,
        { desc = 'Show at cursor' }
      )
      -- end    Mini Git

      -- start  Mini Surround
      local MiniSurround = require("mini.surround")
      MiniSurround.setup({
        custom_surroundings = {
          ['('] = { output = { left = '(', right = ')' } }
        }
      })
      -- end    Mini Surround

      -- start  Mini Pick
      local MiniPick = require("mini.pick")
      MiniPick.setup({})

      map("n", "<leader>ff", function () MiniPick.builtin.files({ tool = 'git' }) end)
      map("n", "<leader>ft", function () MiniPick.builtin.grep_live() end)
      map("n", "<leader>fb", function () MiniPick.builtin.buffers() end)
      -- end    Mini Pick

      -- start  Token
      local Token = require("token")
      Token.setup({})
      -- end    Token

      -- start  Citruszest
      local Citruszest = require("citruszest")
      Citruszest.setup({})
      -- end    Citruszest

      -- start  Colorscheme
      vim.o.background = "dark"
      vim.cmd("colorscheme token-meridian")
      -- end    Colorscheme

      -- start  LSP
      vim.lsp.enable("emmylua_ls")
      vim.lsp.enable("nil_ls")
      vim.lsp.enable("vue_ls")
      vim.lsp.enable("smithy_ls")
      vim.lsp.enable("clangd")

      local vue_language_server_path = os.getenv("VUE_LS_PATH")

      local globalVTSLSPlugins = {}

      local defaultTSFiletypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
      local vueTSFiletypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }

      local tsFiletypes = defaultTSFiletypes

      if vue_language_server_path ~= nil then
        tsFiletypes = vueTSFiletypes

        globalVTSLSPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vue_language_server_path,
            languages = { 'vue' },
            configNamespace = 'typescript',
          }
        }
      end

      vim.lsp.config("vtsls", {
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = globalVTSLSPlugins
            },
          },
        },
        filetypes = tsFiletypes
      })

      vim.lsp.enable("vtsls")
      -- end    LSP

      -- start  JDTLS
      local jdtlsConfig = {
        name = "jdtls",
        cmd = {
          "jdtls",
          "--jvm-arg=" .. "-javaagent:${lombok.outPath}/share/java/lombok.jar"
        },
        root_dir = vim.fs.root(0, {'gradlew', '.git', 'mvnw'}),
        settings = {
          java = {
          }
        },
        init_options = {
          bundles = {}
        },
      }

      local nvim_jdtls_group = vim.api.nvim_create_augroup("nvim-jdtls", { clear = true })
      local JDTLS = require("jdtls")
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = function()
          JDTLS.start_or_attach(jdtlsConfig)
        end,
        group = nvim_jdtls_group
      })
      -- end    JDTLS

      -- start  Metals
      local Metals = require("metals")

      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt" },
        callback = function()
          Metals.initialize_or_attach(Metals.bare_config())
        end,
        group = nvim_metals_group,
      })
      -- end    Metals
    '';
}
