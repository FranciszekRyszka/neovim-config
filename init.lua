-- Wymagania: Neovim 0.11+, gcc (parsery Treesitter), git, curl, unzip, npm (bashls/yamlls/pyright)

-- 1. Skróty klawiszowe i klawisz Leader (ładowane przed wtyczkami)
require("keymaps")

-- 2. Opcje edytora
local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false             -- Bez zawijania linii (przełączanie: <leader>tw)

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.signcolumn = "yes"

opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
opt.undofile = true          -- Historia cofania przetrwa zamknięcie pliku

opt.list = true              -- Pokazuj białe znaki (tab/spacje na końcu) – ważne w YAML
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.updatetime = 250         -- Szybsze odświeżanie znaczników git / diagnostyki
opt.timeoutlen = 300         -- Szybsze pojawianie się okna which-key

-- 3. Automatyczna instalacja lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 4. Wtyczki
require("lazy").setup({

  -- Motyw (lazy=false + priority=1000, żeby załadował się przed resztą wtyczek)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = { flavour = "mocha" }, -- latte / frappe / macchiato / mocha
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Ściągawka ze skrótów + nazwy grup dla <leader>
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "Szukaj" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>t", group = "Przełącz" },
        { "<leader>b", group = "Bufory" },
      },
    },
  },

  -- Pasek statusu (bez opts= lazy nie wywołuje setup() i pasek się nie pokazuje)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Pliki" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Tekst w plikach" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Otwarte bufory" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Ostatnie pliki" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Pomoc" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostyka" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Symbole w pliku" },
    },
  },

  -- Drzewo plików
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      filesystem = {
        filtered_items = { visible = true },
        follow_current_file = { enabled = true },
      },
    },
  },

  -- Treesitter (gałąź master: zamrożona, ale wymaga tylko gcc; main potrzebuje dodatkowo tree-sitter CLI)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "python", "bash", "json", "yaml",
          "dockerfile", "toml", "markdown", "markdown_inline", "ini",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Znaczniki git w signcolumn (skróty w keymaps.lua)
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- Pionowe linie wcięć
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- Zmiana nawiasów/cudzysłowów wokół tekstu: cs"' , ds( , ysiw)
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- Automatyczne domykanie nawiasów
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Uzupełnianie
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "enter" }, -- Enter akceptuje, <C-n>/<C-p> lub Tab/S-Tab nawigują
      -- fuzzy = { implementation = "lua" }, -- odkomentuj, jeśli nie pobierze binarki Rust
    },
  },

  -- LSP: mason pobiera serwery, mason-lspconfig włącza je automatycznie (vim.lsp.enable)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = { ensure_installed = { "bashls", "yamlls", "lua_ls", "pyright" } },
      },
      "saghen/blink.cmp",
    },
    config = function()
      -- Możliwości uzupełniania blink dla wszystkich serwerów
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      -- lua_ls: żeby nie krzyczał o nieznanym globalu `vim` w tej konfiguracji
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
          },
        },
      })

      -- Wygląd diagnostyki
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
      })
    end,
  },
})
