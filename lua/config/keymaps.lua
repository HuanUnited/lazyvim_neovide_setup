-- Disable arrow keys in normal mode
vim.keymap.set("n", "<Up>", '<cmd>echo "Use hjkl for movement"<CR>', { desc = "no up arrow" })
vim.keymap.set("n", "<Down>", '<cmd>echo "Use hjkl for movement"<CR>', { desc = "no down arrow" })
vim.keymap.set("n", "<Left>", '<cmd>echo "Use hjkl for movement"<CR>', { desc = "no left arrow" })
vim.keymap.set("n", "<Right>", '<cmd>echo "Use hjkl for movement"<CR>', { desc = "no right arrow" })

-- Disable arrow keys in insert mode (escape + message)
vim.keymap.set("i", "<Up>", '<Esc><cmd>echo "Use hjkl for movement"<CR>', { desc = "no up arrow" })
vim.keymap.set("i", "<Down>", '<Esc><cmd>echo "Use hjkl for movement"<CR>', { desc = "no down arrow" })
vim.keymap.set("i", "<Left>", '<Esc><cmd>echo "Use hjkl for movement"<CR>', { desc = "no left arrow" })
vim.keymap.set("i", "<Right>", '<Esc><cmd>echo "Use hjkl for movement"<CR>', { desc = "no right arrow" })

-- Alt+hjkl movement in insert mode
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "insert left" })
vim.keymap.set("i", "<A-j>", "<Down>", { desc = "insert down" })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "insert up" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "insert right" })
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- CMake keybindings (ct now free for CMake)
vim.keymap.set("n", "<leader>cr", ":CMakeRun<CR>", { desc = "CMake run" })
vim.keymap.set("n", "<leader>cd", ":CMakeDebug<CR>", { desc = "CMake debug" })
vim.keymap.set("n", "<leader>ct", ":CMakeSelectBuildType<CR>", { desc = "CMake select build type" })

-- C++: Interactive floating terminal
vim.keymap.set("n", "<leader>cB", function()
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r")
  local cmd = string.format("clear && g++ '%s' -std=c++20 -O2 -Wall -Wextra -o '%s' && '%s'\n", file, output, output)

  local term_win = vim.g.my_term_win
  local term_buf = vim.g.my_term_buf

  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    -- Create terminal buffer
    term_buf = vim.api.nvim_create_buf(false, true)

    -- Floating window
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })

    -- Start interactive shell (termopen is NOT deprecated)
    vim.api.nvim_set_current_buf(term_buf)
    local job_id = vim.fn.termopen(vim.o.shell, {
      cwd = vim.fn.expand("%:p:h"),
    })

    vim.g.my_term_buf = term_buf
    vim.g.my_term_win = term_win
    vim.b[term_buf].terminal_job_id = job_id

    -- Send command after shell ready
    vim.defer_fn(function()
      vim.api.nvim_chan_send(job_id, cmd)
      vim.cmd("startinsert")
    end, 200)
  else
    -- Reopen window
    if not vim.api.nvim_win_is_valid(term_win) then
      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.8)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      term_win = vim.api.nvim_open_win(term_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
      })
      vim.g.my_term_win = term_win
    else
      vim.api.nvim_set_current_win(term_win)
    end

    -- Send to existing shell
    local job_id = vim.b[term_buf].terminal_job_id
    vim.api.nvim_chan_send(job_id, cmd)
    vim.cmd("startinsert")
  end
end, { desc = "C++ in floating terminal" })

-- Python: Same approach
vim.keymap.set("n", "<leader>cp", function()
  local file = vim.fn.expand("%:p")
  local cmd = string.format("clear && python3 '%s'\n", file)

  local term_win = vim.g.my_term_win
  local term_buf = vim.g.my_term_buf

  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })

    vim.api.nvim_set_current_buf(term_buf)
    local job_id = vim.fn.termopen(vim.o.shell, {
      cwd = vim.fn.expand("%:p:h"),
    })

    vim.g.my_term_buf = term_buf
    vim.g.my_term_win = term_win
    vim.b[term_buf].terminal_job_id = job_id

    vim.defer_fn(function()
      vim.api.nvim_chan_send(job_id, cmd)
      vim.cmd("startinsert")
    end, 200)
  else
    if not vim.api.nvim_win_is_valid(term_win) then
      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.8)
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)

      term_win = vim.api.nvim_open_win(term_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
      })
      vim.g.my_term_win = term_win
    else
      vim.api.nvim_set_current_win(term_win)
    end

    local job_id = vim.b[term_buf].terminal_job_id
    vim.api.nvim_chan_send(job_id, cmd)
    vim.cmd("startinsert")
  end
end, { desc = "Python in floating terminal" })

-- Global: Escape exits ALL terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function(args)
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = args.buf })
  end,
})

-- Toggle floating terminal (no command)
vim.keymap.set("n", "<leader>tt", function()
  local term_win = vim.g.my_term_win
  local term_buf = vim.g.my_term_buf

  -- If window is open, close it
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, false)
    return
  end

  -- If buffer exists but window closed, reopen window
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })
    vim.g.my_term_win = term_win
    vim.cmd("startinsert")
    return
  end

  -- Create new terminal
  term_buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  term_win = vim.api.nvim_open_win(term_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_set_current_buf(term_buf)
  local job_id = vim.fn.termopen(vim.o.shell, {
    cwd = vim.fn.getcwd(),
  })

  -- Set keymaps
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = term_buf })
  vim.keymap.set("t", "<C-q>", function()
    vim.api.nvim_win_close(term_win, false)
  end, { buffer = term_buf })
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(term_win, false)
  end, { buffer = term_buf })

  vim.g.my_term_buf = term_buf
  vim.g.my_term_win = term_win
  vim.b[term_buf].terminal_job_id = job_id

  vim.cmd("startinsert")
end, { desc = "Toggle floating terminal" })

-- Kill persistent terminal completely
vim.keymap.set("n", "<leader>tk", function()
  local term_win = vim.g.my_term_win
  local term_buf = vim.g.my_term_buf

  -- Close window if open
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
  end

  -- Delete buffer (kills terminal session)
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.cmd("bdelete! " .. term_buf)
  end

  -- Clear globals
  vim.g.my_term_buf = nil
  vim.g.my_term_win = nil

  vim.notify("Terminal session closed", vim.log.levels.INFO)
end, { desc = "Kill persistent terminal" })
