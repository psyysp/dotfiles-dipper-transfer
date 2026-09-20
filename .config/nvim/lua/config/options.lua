-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Keep LazyVim's sensible defaults while preserving the editing feel of the
-- existing Vim setup. Formatting stays explicit so saving never rewrites a
-- buffer unexpectedly.
vim.g.autoformat = false
vim.g.snacks_animate = false

-- Make Mason-managed language tools available during early startup too. This
-- lets health checks and nvim-treesitter find their CLIs before Mason loads.
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

local opt = vim.opt

opt.belloff = "all"
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.hlsearch = false
opt.incsearch = true
opt.scrolloff = 8
opt.colorcolumn = "80"
opt.backup = false
opt.writebackup = false
opt.undofile = true
