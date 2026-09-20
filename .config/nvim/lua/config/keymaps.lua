-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Primeagen-inspired editing motions, with cursor/search position preserved.
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up centered" })

-- Move selected lines while keeping the selection active.
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("x", "<leader>p", [=["_dP]=], { desc = "Paste without replacing register" })

-- Keep familiar Vim-era picker mappings, but make them project-root aware.
map("n", "<leader>pv", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, { desc = "Explorer (Root Dir)" })
map("n", "<leader>ps", function()
  Snacks.picker.grep({ cwd = LazyVim.root() })
end, { desc = "Grep (Root Dir)" })

-- Launch coding agents in a root-aware terminal.
map("n", "<leader>ac", function()
  Snacks.terminal({ "codex" }, { cwd = LazyVim.root() })
end, { desc = "Codex (Root Dir)" })
map("n", "<leader>aC", function()
  Snacks.terminal({ "claude" }, { cwd = LazyVim.root() })
end, { desc = "Claude (Root Dir)" })
