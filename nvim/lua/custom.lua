local M = {}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feedkeys(keys, mode)
  vim.fn.feedkeys(termcodes(keys), mode or "n")
end

local function get_visual_selection()
  -- Yank visual selection into register "
  vim.cmd.normal({ args = { "y" }, bang = true })
  return vim.fn.getreg('"')
end

local function rg_prompt(initial)
  feedkeys(":Rg " .. initial, "n")
end

-- Delete all hidden, unmodified buffers
function M.delete_hidden_buffers()
  local visible = {}
  local closed = 0

  for tab = 1, vim.fn.tabpagenr("$") do
    for _, buf in ipairs(vim.fn.tabpagebuflist(tab)) do
      visible[buf] = true
    end
  end

  for buf = 1, vim.fn.bufnr("$") do
    if vim.fn.bufexists(buf) == 1 and not visible[buf] and not vim.bo[buf].modified then
      vim.cmd("silent bwipeout " .. buf)
      closed = closed + 1
    end
  end

  vim.notify("Closed " .. closed .. " hidden buffers")
end

-- Open all unique files from the quickfix list
function M.quickfix_open_all()
  local qflist = vim.fn.getqflist()
  if vim.tbl_isempty(qflist) then
    return
  end

  local seen = {}

  for _, item in ipairs(qflist) do
    local bufnr = item.bufnr
    if bufnr and bufnr > 0 then
      local name = vim.fn.bufname(bufnr)
      if name ~= "" and not seen[name] then
        seen[name] = true
        vim.cmd("edit " .. vim.fn.fnameescape(name))
      end
    end
  end
end

-- Convert inline yaml into proper yaml for human editing, e.g. for kubectl edit
function M.convert_yaml_keys(keys)
  local parts = {}

  for _, key in ipairs(keys) do
    table.insert(parts, string.format('.data["%s"] = (.data["%s"] | from_yaml)', key, key))
  end

  local expr = table.concat(parts, " | ")
  local input = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local cmd = { "yq", "eval", "-I2", "-P", expr, "-" }
  local result = vim.fn.system(cmd, input)

  if vim.v.shell_error ~= 0 then
    vim.notify("yq failed", vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(result, "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

-- Find and replace word under cursor
function M.substitute_cword()
  feedkeys(":%s/\\<<C-r><C-w>\\>//<Left>", "n")
end

function M.substitute_visual()
  vim.cmd.normal({ args = { "y" }, bang = true })
  feedkeys(':%s/\\<<C-r>"\\>//<Left>', "n")
end

-- Ripgrep mappings
function M.rg_prompt_empty()
  rg_prompt("")
end

function M.rg_prompt_cword()
  rg_prompt(vim.fn.expand("<cword>"))
end

function M.rg_visual()
  local text = get_visual_selection()
  if text == "" then
    return
  end

  rg_prompt(text)
  vim.api.nvim_feedkeys(termcodes("<CR>"), "n", false)
end

function M.rg_word_boundary_cword()
  vim.cmd("Rg \\b" .. vim.fn.expand("<cword>") .. "\\b")
end

function M.rg_word_boundary_visual()
  local text = get_visual_selection()
  if text == "" then
    return
  end

  vim.cmd("Rg \\b" .. text .. "\\b")
end

return M
