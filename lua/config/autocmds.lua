-- Autocmds are automatically loaded on the VeryLazy event
-- C++ makeprg
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.bo.makeprg = "g++ % -std=c++20 -O2 -Wall -Wextra -o main"
  end,
})

-- Python makeprg
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.makeprg = "python3 %"
  end,
})
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Auto go into terminal (insert) mode
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
--

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.o.signcolumn = "no"

    local msg = "Terminal opened at " .. os.date("%H:%M:%S")
    vim.api.nvim_echo({ { msg, "ModeMsg" } }, false, {})

    vim.cmd("startinsert")
  end,
})
