---Configuration for improved built-in completion functionality.
---
---`mini.icons` must be set up before this configuration is sourced.
local utils = require('utils')
local icons = require('mini.icons')

local DOC_MAX_WIDTH = 60
local DOC_MAX_HEIGHT = 15

---Configure the documentation window.
---
---Prefers placing the documentation window to the right of the popup menu,
---aligned with the edge of the popup menu closest to the cursor.
---
---@param win integer Documentation window ID
local function configure_doc(win)
  local pum = vim.fn.pum_getpos()
  local config = vim.api.nvim_win_get_config(win)

  local pum_border_height, pum_border_width = utils.border_size(vim.o.pumborder)
  local doc_border_height, doc_border_width = utils.border_size(vim.o.winborder)

  local scrollbar_width = pum.scrollbar and 1 or 0

  -- Bounds of the popup menu.
  local pum_top = pum.row
  local pum_bottom = pum.row + pum.height + pum_border_height
  local pum_left = pum.col - (pum.col > 0 and 1 or 0)
  local pum_right = pum.col
    + pum.width
    + math.max(pum_border_width, scrollbar_width)

  -- Choose horizontal placement, preferring the right side of the popup menu.
  local width = math.min(config.width, DOC_MAX_WIDTH)
  local right_space = vim.o.columns - pum_right - doc_border_width
  local left_space = pum_left - doc_border_width

  local place_right = right_space >= width or right_space >= left_space

  width =
    math.min(width, math.max(1, place_right and right_space or left_space))

  local col = place_right and pum_right or pum_left - width - doc_border_width

  -- Apply the width in the window configuration to determine the height of the
  -- window arter wrapping.
  if width ~= config.width then
    vim.api.nvim_win_set_config(win, { width = width })
  end

  local height =
    math.min(vim.api.nvim_win_text_height(win, {}).all, DOC_MAX_HEIGHT)

  -- Choose vertical placement, preferring alignment with the edge of the popup
  -- menu closest to the cursor.
  local bottom_space = pum_bottom - doc_border_height
  local top_space = vim.o.lines - pum_top - doc_border_height
  local align_bottom = pum_bottom <= vim.fn.screenrow() - 1

  local preferred_space = align_bottom and bottom_space or top_space
  local fallback_space = align_bottom and top_space or bottom_space

  if preferred_space < height and fallback_space > preferred_space then
    align_bottom = not align_bottom
  end

  height =
    math.min(height, math.max(1, align_bottom and bottom_space or top_space))

  local row = align_bottom and pum_bottom - height - doc_border_height
    or pum_top

  vim.api.nvim_win_set_config(win, {
    relative = config.relative,
    border = vim.o.winborder,
    row = row,
    col = col,
    width = width,
    height = height,
  })
end

---Schedule configuration of the documentation window after it is updated.
---
---@param win? integer Documentation window ID
local schedule_configure_doc = vim.schedule_wrap(function(win)
  if vim.fn.pumvisible() == 0 then
    return
  end

  win = win or vim.fn.complete_info().preview_winid

  if win ~= 0 and vim.api.nvim_win_is_valid(win) then
    configure_doc(win)
  end
end)

-- Configure the documentation window when documentation for an existing
-- completion item is supplied at a later time, for example, through
-- completionItem/resolve.
local orig_complete_set = vim.api.nvim__complete_set

---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim__complete_set = function(...)
  local result = orig_complete_set(...)

  if result.winid then
    schedule_configure_doc(result.winid)
  end

  return result
end

-- Configure the documentation window when documentation is supplied with the
-- completion item.
vim.api.nvim_create_autocmd('CompleteChanged', {
  callback = function()
    local item = vim.v.event.completed_item or {}

    if (item.info or '') ~= '' then
      schedule_configure_doc()
    end
  end,
})

-- Automatically show completion in the command-line.
vim.api.nvim_create_autocmd('CmdlineChanged', {
  callback = function()
    vim.fn.wildtrigger()
  end,
})

-- Automatically show completion in LSP-enabled buffers.
local trigger_chars = {}

for i = 32, 126 do
  trigger_chars[#trigger_chars + 1] = string.char(i)
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method('textDocument/completion') then
      return
    end

    client.server_capabilities.completionProvider.triggerCharacters =
      trigger_chars

    vim.lsp.completion.enable(true, client.id, args.buf, {
      autotrigger = true,

      convert = function(item)
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
        local icon, hl = icons.get('lsp', kind)
        return {
          kind = icon .. ' ' .. kind,
          kind_hlgroup = hl,
        }
      end,
    })
  end,
})
