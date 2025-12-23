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

local TERM_ID = 1

-- C++: Timestamp shows naturally in terminal output
vim.keymap.set("n", "<leader>cB", function()
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r")
  local timestamp = os.date("%H:%M:%S")

  -- Echo prints to terminal stdout (safe)
  local cmd = string.format(
    "echo '═══ Started %s ═══' && g++ '%s' -std=c++20 -O2 -Wall -Wextra -o '%s' && '%s'; read -p 'Press Enter...'",
    timestamp,
    file,
    output,
    output
  )

  Snacks.terminal.open('bash -c "' .. cmd .. '"', {
    id = 1,
    cwd = vim.fn.expand("%:p:h"),
    win = { style = "float" },
  })
end, { desc = "C++ Build and Run" })

-- Python: Explicit python invocation
vim.keymap.set("n", "<leader>cp", function()
  local file = vim.fn.expand("%:p")

  Snacks.terminal.open(string.format("python3 '%s'; read -p 'Press Enter to close...'", file), {
    id = TERM_ID,
    cwd = vim.fn.expand("%:p:h"),
    win = { style = "float" },
  })
end, { desc = "Python in float" })

-- Empty shell terminal
vim.keymap.set("n", "<leader>tt", function()
  Snacks.terminal.toggle(
    nil, -- No command = default shell
    {
      id = TERM_ID,
      cwd = vim.fn.getcwd(),
      win = { style = "float" },
    }
  )
end, { desc = "Toggle float shell" })
