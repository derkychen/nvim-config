local undotree_lazyload_group =
  vim.api.nvim_create_augroup("UndoTreeLazyLoad", { clear = true })

local function toggle_undotree()
  local current_buf = vim.api.nvim_get_current_buf()

  -- Close undo tree if it is open.
  local undotree_win = vim.b[current_buf].nvim_undotree
    or vim.b[current_buf].nvim_is_undotree

  if undotree_win and vim.api.nvim_win_is_valid(undotree_win) then
    vim.cmd.Undotree()
    return
  end

  local source_win = vim.api.nvim_get_current_win()
  local source_width = vim.api.nvim_win_get_width(source_win)
  local source_height = vim.api.nvim_win_get_height(source_win)

  local buf = vim.api.nvim_create_buf(false, true)

  -- Floating window at the bottom-left of the source window, slightly inset.
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = source_win,
    anchor = "SW",
    row = math.max(0, source_height - 1),
    col = 1,

    width = math.min(32, math.max(1, source_width - 2)),
    height = math.min(10, math.max(1, source_height - 2)),
    border = vim.o.winborder,
    title = "Undo tree",
    title_pos = "center",
  })

  require("undotree").open({
    winid = win,
  })

  vim.api.nvim_set_current_win(win)
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = vim.schedule_wrap(function()
    vim.cmd.packadd("nvim.undotree")

    vim.keymap.set(
      "n",
      "<leader>u",
      toggle_undotree,
      { desc = "Toggle undotree" }
    )
  end),
  group = undotree_lazyload_group,
  once = true,
})
