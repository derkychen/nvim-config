return {
  "derkychen/telescope-dirjump.nvim",
  config = function()
    require("telescope").load_extension("dirjump")

    vim.api.nvim_create_user_command("DirjumpThenReveal", function()
      vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("DirjumpThenReveal", { clear = true }),
        once = true,
        callback = function()
          vim.schedule(function()
            vim.cmd("Neotree filesystem reveal")
          end)
        end,
      })
      vim.cmd("Telescope dirjump")
    end, {})

    vim.keymap.set("n", "<Leader>fd", function()
      vim.cmd("DirjumpThenReveal")
    end, {})
  end,
}
