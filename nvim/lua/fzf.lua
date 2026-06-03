-- nvim/lua/fzf.lua
-- Minimal fzf integration + LSP pickers using only the `fzf` binary.
-- Replaces junegunn/fzf.vim + gfanto/fzf-lsp.nvim.
--
-- Public API:
--   M.files(), M.buffers(), M.windows(), M.command_history()
--   M.rg(query)
--   M.lsp_references(), M.lsp_document_symbols(), M.diagnostics_all()
--   M.setup() -- registers :Rg user command and keymaps
--
-- Implementation: each picker shells out to `fzf` running in a floating
-- terminal, with stdin coming from either an inline command or a tempfile,
-- and the selected line(s) written to another tempfile that we read on exit.

local M = {}

-- ----- internal helpers -----

local function shellescape(s)
  return vim.fn.shellescape(s)
end

local function open_float()
  local prev = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local w = math.floor(vim.o.columns * 0.9)
  local h = math.floor(vim.o.lines * 0.85)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
  })
  return prev, buf, win
end

local function items_to_source(items)
  -- Write items to a tempfile and return a shell command that streams them.
  -- Avoids ARG_MAX limits on big lists.
  local tmp = vim.fn.tempname()
  vim.fn.writefile(items, tmp)
  return "cat " .. shellescape(tmp)
end

-- Read tokyonight's fzf flags (--color=..., --highlight-line, ...) from
-- its extras/fzf/tokyonight_storm.sh, distributed with the colorscheme
-- repo. Computed once at module load; falls back to empty string if not
-- found (e.g. fresh nvim install before vim.pack has fetched the plugin).
local function tokyonight_fzf_args()
  -- Try common locations: vim.pack data dir first, then runtimepath.
  local candidates = {
    vim.fn.stdpath("data") .. "/site/pack/core/opt/tokyonight.nvim/extras/fzf/tokyonight_night.sh",
  }
  local rtp_hits = vim.api.nvim_get_runtime_file("extras/fzf/tokyonight_night.sh", false)
  for _, p in ipairs(rtp_hits) do
    table.insert(candidates, p)
  end
  local file
  for _, p in ipairs(candidates) do
    if vim.fn.filereadable(p) == 1 then
      file = p
      break
    end
  end
  if not file then
    return ""
  end
  local args = {}
  for _, line in ipairs(vim.fn.readfile(file)) do
    local flag = line:match("^%s*(%-%-%S+)")
    if flag then
      table.insert(args, flag)
    end
  end
  return table.concat(args, " ")
end

local TOKYONIGHT_FZF = tokyonight_fzf_args()

local PREVIEW_FILE_LINE = table.concat({
  "--preview",
  shellescape(
    "bat --color=always --style=numbers --highlight-line {2} -- {1} 2>/dev/null"
      .. " || sed -n '{2}p' {1} 2>/dev/null"
  ),
  "--preview-window=right,60%,+{2}/3",
}, " ")

-- Run fzf in a floating terminal.
--   source_cmd: shell command whose stdout becomes the fzf input. May be nil.
--   fzf_args:   extra fzf flags as one string.
--   on_select:  function(lines) called when user accepts (Enter).
function M.run(source_cmd, fzf_args, on_select)
  local out = vim.fn.tempname()
  fzf_args = fzf_args or ""
  -- Override --height/--layout from $FZF_DEFAULT_OPTS so fzf fills the
  -- entire floating window (user's shell may set e.g. '--height 30%' for
  -- terminal use, which would shrink fzf to a sliver of the float).
  -- TOKYONIGHT_FZF supplies --color=... matching the editor colorscheme.
  local base_args = "--height=100% --layout=reverse " .. TOKYONIGHT_FZF .. " "
  local cmd
  if source_cmd and source_cmd ~= "" then
    cmd = string.format("(%s) | fzf %s%s > %s", source_cmd, base_args, fzf_args, out)
  else
    cmd = string.format("fzf %s%s > %s", base_args, fzf_args, out)
  end

  local prev, _scratch_buf, win = open_float()

  -- Use :terminal rather than jobstart{term=true}: :terminal sizes the
  -- pty against the *current window*, which is the float we just entered,
  -- and survives subsequent resizes. jobstart{term=true} appears to
  -- snapshot 80x24 in some cases (observed: fzf rendering in only a
  -- corner of the float).
  -- Force 24-bit color in the pty so bat (used for previews) doesn't
  -- downgrade to 256-color and dither tokyonight RGB. Use 'export' (not
  -- a VAR=val command-prefix) because cmd starts with a subshell '(...)'.
  cmd = "export COLORTERM=truecolor; " .. cmd
  -- :terminal cmdline parsing expands % (current file) and # (alt file).
  -- Our cmd contains literal '%' (e.g. --preview-window=right,60%), so
  -- escape both before handing to ex-cmd.
  local term_arg = vim.fn.escape(shellescape(cmd), "%#")
  vim.cmd("terminal sh -c " .. term_arg)
  local term_buf = vim.api.nvim_get_current_buf()
  -- Don't pollute :ls / <leader>b with leftover term:// buffers.
  vim.bo[term_buf].buflisted = false
  vim.bo[term_buf].bufhidden = "wipe"
  -- vim-tmux-navigator checks ft=='fzf' to decide whether to pass C-j/k
  -- through to the terminal or navigate panes. Without this, C-j triggers
  -- TmuxNavigateDown instead of moving the fzf cursor.
  vim.bo[term_buf].filetype = "fzf"

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term_buf,
    once = true,
    callback = function()
      vim.schedule(function()
        pcall(vim.api.nvim_win_close, win, true)
        pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
        if vim.api.nvim_win_is_valid(prev) then
          vim.api.nvim_set_current_win(prev)
        end
        local lines = {}
        if vim.fn.filereadable(out) == 1 then
          lines = vim.fn.readfile(out)
          os.remove(out)
        end
        if #lines > 0 and on_select then
          on_select(lines)
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end

local function edit_at(filename, lnum, col)
  local cmd = lnum and string.format("edit +%d ", lnum) or "edit "
  vim.cmd(cmd .. vim.fn.fnameescape(filename))
  if lnum and col then
    pcall(vim.api.nvim_win_set_cursor, 0, { lnum, math.max(0, col - 1) })
  end
end

local function items_to_display(items)
  local lines = {}
  for _, it in ipairs(items) do
    local fname = vim.fn.fnamemodify(it.filename, ":~:.")
    table.insert(lines, string.format("%s:%d:%d:%s", fname, it.lnum, it.col, it.text or ""))
  end
  return lines
end

local function pick_locations(items, msg)
  if #items == 0 then
    vim.notify(msg or "No results", vim.log.levels.WARN)
    return
  end
  local lines = items_to_display(items)
  local args = "--delimiter=: " .. PREVIEW_FILE_LINE
  M.run(items_to_source(lines), args, function(selected)
    local file, lnum, col = selected[1]:match("^([^:]+):(%d+):(%d+):")
    if file then
      edit_at(file, tonumber(lnum), tonumber(col))
    end
  end)
end

-- ----- file/buffer pickers -----

function M.files()
  local src = "rg --files --hidden --glob '!.git/'"
  local args = "--multi "
    .. "--preview "
    .. shellescape("bat --color=always --style=numbers {} 2>/dev/null || cat {}")
    .. " --preview-window=right,60%"
  M.run(src, args, function(lines)
    for _, f in ipairs(lines) do
      edit_at(f)
    end
  end)
end

function M.buffers()
  local items = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
      local name = vim.api.nvim_buf_get_name(b)
      if name ~= "" then
        table.insert(items, string.format("%d\t%s", b, vim.fn.fnamemodify(name, ":~:.")))
      end
    end
  end
  if #items == 0 then
    vim.notify("No listed buffers", vim.log.levels.WARN)
    return
  end
  M.run(items_to_source(items), "--with-nth=2.. --delimiter='\t'", function(lines)
    local bufnr = tonumber(lines[1]:match("^(%d+)\t"))
    if bufnr then
      vim.cmd("buffer " .. bufnr)
    end
  end)
end

function M.windows()
  local items = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    local name = vim.api.nvim_buf_get_name(b)
    name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")
    table.insert(items, string.format("%d\t%s", w, name))
  end
  M.run(items_to_source(items), "--with-nth=2.. --delimiter='\t'", function(lines)
    local winid = tonumber(lines[1]:match("^(%d+)\t"))
    if winid and vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_set_current_win(winid)
    end
  end)
end

function M.command_history()
  local items = {}
  for i = vim.fn.histnr(":"), 1, -1 do
    local h = vim.fn.histget(":", i)
    if h ~= "" then
      table.insert(items, h)
    end
  end
  if #items == 0 then
    return
  end
  M.run(items_to_source(items), "", function(lines)
    vim.api.nvim_feedkeys(":" .. lines[1], "n", false)
  end)
end

function M.rg(query)
  if not query or query == "" then
    vim.notify("Rg requires a query", vim.log.levels.WARN)
    return
  end
  local rg = string.format(
    "rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/' -- %s",
    shellescape(query)
  )
  local args = "--multi --ansi --delimiter=: " .. PREVIEW_FILE_LINE
  M.run(rg, args, function(lines)
    if #lines == 1 then
      local file, lnum, col = lines[1]:match("^([^:]+):(%d+):(%d+):")
      if file then
        edit_at(file, tonumber(lnum), tonumber(col))
      end
      return
    end
    -- Multi-select: send all hits to the quickfix list and open it.
    local items = {}
    for _, line in ipairs(lines) do
      local file, lnum, col, text = line:match("^([^:]+):(%d+):(%d+):(.*)$")
      if file then
        table.insert(items, {
          filename = file,
          lnum = tonumber(lnum),
          col = tonumber(col),
          text = text,
        })
      end
    end
    if #items > 0 then
      vim.fn.setqflist({}, " ", { title = "Rg", items = items })
      vim.cmd("copen")
    end
  end)
end

-- ----- LSP pickers -----

local function flatten_document_symbols(symbols, bufnr, prefix, out)
  out = out or {}
  prefix = prefix or ""
  for _, sym in ipairs(symbols or {}) do
    local kind = vim.lsp.protocol.SymbolKind[sym.kind] or "?"
    local range = sym.selectionRange or sym.range or (sym.location and sym.location.range)
    local filename
    if sym.location then
      filename = vim.uri_to_fname(sym.location.uri)
    else
      filename = vim.api.nvim_buf_get_name(bufnr)
    end
    if range and filename then
      table.insert(out, {
        filename = filename,
        lnum = range.start.line + 1,
        col = range.start.character + 1,
        text = string.format("[%s] %s%s", kind, prefix, sym.name),
      })
    end
    if sym.children and #sym.children > 0 then
      flatten_document_symbols(sym.children, bufnr, prefix .. sym.name .. ".", out)
    end
  end
  return out
end

function M.lsp_references()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  params.context = { includeDeclaration = true }
  vim.lsp.buf_request_all(0, "textDocument/references", params, function(results)
    local locs = {}
    for _, r in pairs(results or {}) do
      if r.result then
        vim.list_extend(locs, r.result)
      end
    end
    local items = vim.lsp.util.locations_to_items(locs, "utf-8")
    vim.schedule(function()
      pick_locations(items, "No references")
    end)
  end)
end

function M.lsp_document_symbols()
  local params = { textDocument = vim.lsp.util.make_text_document_params(0) }
  local bufnr = vim.api.nvim_get_current_buf()
  vim.lsp.buf_request_all(bufnr, "textDocument/documentSymbol", params, function(results)
    local items = {}
    for _, r in pairs(results or {}) do
      if r.result then
        flatten_document_symbols(r.result, bufnr, "", items)
      end
    end
    vim.schedule(function()
      pick_locations(items, "No symbols")
    end)
  end)
end

local function diagnostics_to_items(diags)
  local items = {}
  for _, d in ipairs(diags) do
    local filename = vim.api.nvim_buf_get_name(d.bufnr)
    if filename ~= "" then
      local sev = ({ "ERROR", "WARN", "INFO", "HINT" })[d.severity] or "?"
      table.insert(items, {
        filename = filename,
        lnum = d.lnum + 1,
        col = d.col + 1,
        text = string.format("[%s] %s", sev, d.message:gsub("\n", " ")),
      })
    end
  end
  return items
end

function M.diagnostics_all()
  pick_locations(diagnostics_to_items(vim.diagnostic.get(nil)), "No diagnostics")
end

function M.diagnostics_buffer()
  pick_locations(diagnostics_to_items(vim.diagnostic.get(0)), "No diagnostics in buffer")
end

-- Generic location-list picker for textDocument/{definition,implementation,...}.
-- Auto-jumps when there's exactly one result, matching vim.lsp.buf.* behavior.
local function lsp_locations(method, no_results_msg)
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request_all(0, method, params, function(results)
    local locs = {}
    for _, r in pairs(results or {}) do
      if r.result then
        local list = vim.islist(r.result) and r.result or { r.result }
        vim.list_extend(locs, list)
      end
    end
    vim.schedule(function()
      if #locs == 0 then
        vim.notify(no_results_msg, vim.log.levels.WARN)
      elseif #locs == 1 then
        vim.lsp.util.show_document(locs[1], "utf-8", { focus = true })
      else
        pick_locations(vim.lsp.util.locations_to_items(locs, "utf-8"), no_results_msg)
      end
    end)
  end)
end

function M.lsp_definitions()
  lsp_locations("textDocument/definition", "No definitions")
end

function M.lsp_implementations()
  lsp_locations("textDocument/implementation", "No implementations")
end

function M.lsp_type_definitions()
  lsp_locations("textDocument/typeDefinition", "No type definitions")
end

function M.workspace_symbols(query)
  query = query or ""
  vim.lsp.buf_request_all(0, "workspace/symbol", { query = query }, function(results)
    local items = {}
    for _, r in pairs(results or {}) do
      if r.result then
        for _, sym in ipairs(r.result) do
          local kind = vim.lsp.protocol.SymbolKind[sym.kind] or "?"
          local loc = sym.location
          if loc then
            local fname = vim.uri_to_fname(loc.uri)
            local short = vim.fn.fnamemodify(fname, ":~:.")
            table.insert(items, {
              filename = fname,
              lnum = loc.range.start.line + 1,
              col = loc.range.start.character + 1,
              text = string.format("[%s] %s  %s", kind, sym.name, short),
            })
          end
        end
      end
    end
    vim.schedule(function()
      pick_locations(items, "No workspace symbols")
    end)
  end)
end

-- ----- mappings picker -----

function M.mappings()
  local items = {}
  local seen = {}
  local function add(m, scope)
    local key = m.lhs .. "\0" .. (m.buffer and "b" or "g")
    if seen[key] then return end
    seen[key] = true
    local desc = m.desc
      or (type(m.rhs) == "string" and m.rhs ~= "" and m.rhs)
      or (m.callback and "<lua callback>")
      or ""
    desc = desc:gsub("\n", " ")
    table.insert(items, string.format("%s\t%s\t%s", scope, m.lhs, desc))
  end
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
    add(m, "buf")
  end
  for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
    add(m, "glb")
  end
  if #items == 0 then
    vim.notify("No normal-mode mappings", vim.log.levels.WARN)
    return
  end
  M.run(items_to_source(items), "--delimiter='\\t' --with-nth=1,2,3", function(lines)
    local lhs = lines[1]:match("^[^\t]+\t([^\t]+)\t")
    if lhs then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, true, true), "m", false)
    end
  end)
end

-- ----- setup -----

function M.setup()
  local map = vim.keymap.set
  local ucmd = vim.api.nvim_create_user_command

  ucmd("Rg", function(opts) M.rg(opts.args) end, { nargs = "*", desc = "Ripgrep + fzf" })
  ucmd("Mappings", M.mappings, { desc = "fzf: normal-mode mappings" })
  ucmd("Symbols", function(opts) M.workspace_symbols(opts.args) end,
    { nargs = "*", desc = "fzf: LSP workspace symbols" })
  ucmd("Definitions", M.lsp_definitions, { desc = "fzf: LSP definitions" })
  ucmd("Implementations", M.lsp_implementations, { desc = "fzf: LSP implementations" })
  ucmd("TypeDefinitions", M.lsp_type_definitions, { desc = "fzf: LSP type definitions" })
  ucmd("Diagnostics", M.diagnostics_buffer, { desc = "fzf: diagnostics (current buffer)" })

  map("n", "<leader>f", M.files, { desc = "fzf: files" })
  map("n", "<leader>b", M.buffers, { desc = "fzf: buffers" })
  map("n", "<leader>w", M.windows, { desc = "fzf: windows" })
  map("n", "<leader>:", M.command_history, { desc = "fzf: command history" })
  map("n", "<leader>m", M.mappings, { desc = "fzf: mappings" })

  -- LSP family: only the ones where fzf adds value over built-in g*
  -- mappings (grr, gri, grt, gO, gd, gD, etc.).
  map("n", "<leader>lr", M.lsp_references, { desc = "fzf: LSP references" })
  map("n", "<leader>ls", M.lsp_document_symbols, { desc = "fzf: LSP document symbols" })
  map("n", "<leader>lS", function() M.workspace_symbols("") end, { desc = "fzf: LSP workspace symbols" })
  map("n", "<leader>ld", M.diagnostics_buffer, { desc = "fzf: diagnostics (current buffer)" })
  map("n", "<leader>lD", M.diagnostics_all, { desc = "fzf: diagnostics (all buffers)" })
end

return M
