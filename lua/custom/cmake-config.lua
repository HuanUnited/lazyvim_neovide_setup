-- Custom CMake configuration and utilities for LazyVim
-- This module provides helper functions for CMake development

local M = {}

-- Table to store CMake project settings
M.settings = {
  build_dir = "build",
  build_type = "Debug",
  generator = "Unix Makefiles",
  cmake_args = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
}

-- Check if CMakeLists.txt exists in current directory
function M.has_cmake()
  return vim.fn.filereadable("CMakeLists.txt") == 1
end

-- Get the build directory path
function M.get_build_dir()
  return vim.fn.getcwd() .. "/" .. M.settings.build_dir
end

-- Check if build directory exists
function M.build_dir_exists()
  return vim.fn.isdirectory(M.get_build_dir()) == 1
end

-- Create build directory
function M.create_build_dir()
  local build_dir = M.get_build_dir()
  if not M.build_dir_exists() then
    vim.fn.mkdir(build_dir, "p")
    return true
  end
  return false
end

-- Initialize CMake project (generates build files)
function M.init_cmake()
  if not M.has_cmake() then
    vim.notify("CMakeLists.txt not found in current directory", vim.log.levels.ERROR)
    return false
  end
  
  M.create_build_dir()
  
  local build_dir = M.get_build_dir()
  local cmake_cmd = string.format(
    "cd '%s' && cmake -DCMAKE_BUILD_TYPE=%s -G '%s' %s ..",
    build_dir,
    M.settings.build_type,
    M.settings.generator,
    table.concat(M.settings.cmake_args, " ")
  )
  
  vim.notify("Running CMake init: " .. cmake_cmd, vim.log.levels.INFO)
  
  -- Run in floating terminal
  Snacks.terminal.open("bash -c \"" .. cmake_cmd .. "; read -p 'Press Enter...'\"", {
    id = 10,
    win = { style = "float" },
  })
end

-- Get executable path (tries common locations)
function M.find_executable(exe_name)
  local exe_name = exe_name or vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local build_dir = M.get_build_dir()
  
  local possible_paths = {
    build_dir .. "/" .. exe_name,
    build_dir .. "/Debug/" .. exe_name,
    build_dir .. "/Release/" .. exe_name,
    build_dir .. "/bin/" .. exe_name,
    build_dir .. "/Debug/bin/" .. exe_name,
  }
  
  for _, path in ipairs(possible_paths) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  
  return nil
end

-- Run executable with arguments
function M.run_executable(exe_name, args)
  local exe_path = M.find_executable(exe_name)
  
  if not exe_path then
    vim.notify("Executable not found: " .. (exe_name or "(unnamed)"), vim.log.levels.ERROR)
    return
  end
  
  local cmd = string.format("'%s' %s; read -p 'Press Enter...'", exe_path, args or "")
  
  Snacks.terminal.open(cmd, {
    id = 11,
    cwd = vim.fn.getcwd(),
    win = { style = "float" },
  })
end

-- Build with custom options
function M.build(target)
  if not M.has_cmake() then
    vim.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
    return
  end
  
  M.create_build_dir()
  
  local build_dir = M.get_build_dir()
  local target = target or "all"
  local cmd = string.format(
    "cd '%s' && cmake --build . --target %s --config %s; echo 'Build completed!'; read -p 'Press Enter...'",
    build_dir,
    target,
    M.settings.build_type
  )
  
  Snacks.terminal.open("bash -c \"" .. cmd .. "\"", {
    id = 12,
    cwd = vim.fn.getcwd(),
    win = { style = "float" },
  })
end

-- Set build type (Debug/Release)
function M.set_build_type(build_type)
  if build_type == "Debug" or build_type == "Release" then
    M.settings.build_type = build_type
    vim.notify("Build type set to: " .. build_type, vim.log.levels.INFO)
    return true
  else
    vim.notify("Invalid build type. Use 'Debug' or 'Release'", vim.log.levels.ERROR)
    return false
  end
end

-- Display current settings
function M.show_settings()
  local msg = string.format(
    "CMake Settings:\n- Build Dir: %s\n- Build Type: %s\n- Generator: %s\n- Args: %s",
    M.settings.build_dir,
    M.settings.build_type,
    M.settings.generator,
    table.concat(M.settings.cmake_args, ", ")
  )
  vim.notify(msg, vim.log.levels.INFO)
end

return M
