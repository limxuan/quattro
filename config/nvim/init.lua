-- Basic settings
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = {
  tab = "▸ ",
  trail = "+",
  eol = "$",
}

-- Essential keymaps
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set({"n", "v"}, "gl", "$", { desc = "Go to end of line" })
vim.keymap.set("n", "<leader>va", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<leader>l", "<CMD>set list!<CR>", { desc = "Toggle invisible characters" })
vim.keymap.set({"n", "v", "i"}, "<C-q>", "<CMD>qa<CR>", { desc = "Quit Neovim" })

-- Clipboard keymaps
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set({"n", "v"}, "<leader>P", '"+P', { desc = "Paste before from system clipboard" })
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:.")
  if vim.bo.filetype == "oil" then
    local ok, oil = pcall(require, "oil")
    if ok then
      local entry = oil.get_cursor_entry()
      local dir = oil.get_current_dir()
      if dir and entry then
        path = vim.fn.fnamemodify(dir .. entry.name, ":.")
      elseif dir then
        path = vim.fn.fnamemodify(dir, ":.")
      end
    end
  end

  if path == "" then
    vim.notify("No file path for current buffer", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("+", path)
  vim.fn.setreg('"', path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy relative file path" })

-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
  -- Oil.nvim (file manager)
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        view_options = {
          show_hidden = true,
        },
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory in Oil" })
      vim.keymap.set("n", "<leader>o", "<CMD>Oil<CR>", { desc = "Open Oil" })
    end
  },

  -- Telescope.nvim (Find files and find words)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })

      vim.keymap.set("n", "<leader>ff", function() builtin.find_files({ hidden = true }) end, { desc = "Find files (including hidden)" })
      vim.keymap.set("n", "<leader>fh", function() builtin.find_files({ hidden = true }) end, { desc = "Find hidden files" })
      vim.keymap.set("n", "<leader>fa", function() builtin.find_files({ hidden = true, no_ignore = true }) end, { desc = "Find all files (hidden & ignored)" })
      vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "Find words" })
    end
  },

  -- Kanagawa color scheme
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme kanagawa-wave")
    end
  },

  -- Harpoon (quick file navigation)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
        },
      })

      vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
      end, { desc = "Harpoon add file" })

      vim.keymap.set("n", "<leader>e", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon edit menu" })

      for i = 1, 5 do
        vim.keymap.set("n", "<leader>" .. i, function()
          harpoon:list():select(i)
        end, { desc = "Harpoon file " .. i })
      end
    end
  }
})
