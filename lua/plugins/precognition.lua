return {
  "tris203/precognition.nvim",
  event = { "VeryLazy" },
  config = function()
    require("precognition").setup({
      show_labels = true,
      show_num = false,
      min_distance = 5,
      hints = {
        f = { suchthat = "is_not_line_end" },
        F = { suchthat = "is_not_line_start" },
        t = { suchthat = "is_not_line_end" },
        T = { suchthat = "is_not_line_start" },
      },
    })
  end,
}
