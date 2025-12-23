return {
  -- CMake integration for building and running C++ projects
  {
    "Civitasv/cmake-tools.nvim",
    lazy = true,
    ft = { "cmake" },
    config = function()
      require("cmake-tools").setup({
        cmake_command = "cmake",
        ctest_command = "ctest",
        cmake_build_directory = "build",
        cmake_build_type = "Debug",
        cmake_generate_options = {
          "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
        },
        cmake_console_size = 10,
        cmake_console_position = "belowright",
        cmake_show_console = "always",
        cmake_always_compile = true,
        on_launch_template = function(targets)
          return targets
        end,
      })
    end,
  },
}
