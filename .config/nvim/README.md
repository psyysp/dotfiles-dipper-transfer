# Neovim — LazyVim hybrid

This is a standard LazyVim setup with a small compatibility layer for the
existing Vim workflow. It is intentionally kept in `~/.config/nvim`; the
original `~/.vimrc` and `~/.vim` remain available as a fallback with `vim`.

## Everyday keymaps

- `<leader>pv` — root-aware Snacks Explorer
- `<leader>ps` — root-aware live grep
- `<leader>ac` — open Codex in a root-aware terminal
- `<leader>aC` — open Claude in a root-aware terminal
- `<leader>p` in visual mode — paste without replacing the yank register
- `J` — join lines while keeping the cursor stable
- `<C-d>` / `<C-u>` — half-page scroll with the cursor centered
- `J` / `K` in visual mode — move the selection down/up

Formatting is manual (`<leader>cf` through LazyVim's default mapping) because
`vim.g.autoformat` is disabled. Use LazyVim's `:Lazy`, `:Mason`, and `:checkhealth`
when maintaining plugins and language tooling. Fugitive remains available on
demand with `:G` or `:Git`.

Dotdipper already includes `~/.config/**`; after reviewing the new files, use
`dotdipper status` and then your normal Dotdipper workflow to track them. Keep
the old Vim files until the Neovim setup has earned your trust.
