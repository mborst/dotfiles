if vim.g.vscode then
  return
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.diagnostic.config({
  underline = false,
  virtual_text = true,
  update_in_insert = false,
})

-- Shared overrides for every server: cmp capabilities + verbose trace.
-- Per-server defaults (cmd, filetypes, root_markers, on_attach helpers)
-- come from nvim-lspconfig's lsp/<name>.lua files; vim.lsp.config below
-- only adds what's different from those defaults.
vim.lsp.config("*", {
  capabilities = capabilities,
  trace = "messages",
})

-- gopls: Datadog-internal wrapper instead of the upstream binary.
vim.lsp.config("gopls", { cmd = { "dd-gopls" } })

-- rust_analyzer: project preferences. Deep-merges with the lspconfig
-- defaults (which set rust-analyzer.lens.*).
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = { group = "module" },
        prefix = "self",
      },
      cargo = {
        buildScripts = { enable = false },
      },
      procMacro = { enable = true },
    },
  },
})

vim.lsp.enable({ "gopls", "pyright", "kotlin_language_server", "rust_analyzer" })

-- Buffer-local keymaps and behavior, attached once via LspAttach.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Disable LSP semantic tokens; rely on treesitter for highlighting.
    -- Avoids semantic tokens stomping on treesitter captures and reduces
    -- redraw cost on large buffers.
    client.server_capabilities.semanticTokensProvider = nil

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
    end

    map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
    map("n", "gd", vim.lsp.buf.definition, "LSP: definition")
    map("n", "K", vim.lsp.buf.hover, "LSP: hover")
    map("n", "gi", vim.lsp.buf.implementation, "LSP: implementation")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP: signature help")
    map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "LSP: add workspace folder")
    map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "LSP: remove workspace folder")
    map("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "LSP: list workspace folders")
    map("n", "<space>D", vim.lsp.buf.type_definition, "LSP: type definition")
    map("n", "<space>rn", vim.lsp.buf.rename, "LSP: rename")
    map("n", "gr", vim.lsp.buf.references, "LSP: references")
    map("n", "<space>e", vim.diagnostic.open_float, "Diagnostic: open float")
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Diagnostic: prev")
    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Diagnostic: next")
    map("n", "<space>q", vim.diagnostic.setqflist, "Diagnostic: send to quickfix")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")

    if client:supports_method("textDocument/formatting") then
      map("n", "<space>f", function()
        vim.lsp.buf.format({ async = true })
      end, "LSP: format")
    end

    if client:supports_method("textDocument/documentHighlight") then
      vim.cmd([[
        hi! LspReferenceRead  cterm=bold ctermbg=red guibg=LightYellow
        hi! LspReferenceText  cterm=bold ctermbg=red guibg=LightYellow
        hi! LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      ]])

      local highlight_group = vim.api.nvim_create_augroup("UserLspDocumentHighlight", { clear = false })
      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = highlight_group })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = highlight_group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = highlight_group,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
