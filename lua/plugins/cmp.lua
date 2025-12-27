return {
  -- ... other plugin configurations
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Extend default mappings
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          -- Add checks for snippet navigation or falling back to actual tab
          -- elseif require("luasnip").expand_or_jumpable() then
          --   vim.fn.feedkeys(unpack(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true)))
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          -- Add checks for snippet navigation or falling back to actual tab
          -- elseif require("luasnip").jumpable(-1) then
          --   vim.fn.feedkeys(unpack(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true)))
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
