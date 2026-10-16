vim.g.mapleader = " " -- Set leader key to space

vim.opt.exrc = true -- Support .nvim.lua files
vim.opt.number = true -- Show the current line number cursor is on instead of 0
vim.opt.relativenumber = true -- Show line numbers relative to cursor
vim.opt.colorcolumn = "100" -- Set column
vim.opt.listchars = "tab:» ,trail:·,nbsp:␣" -- shown when :set list; trailing whitespace is the useful one
vim.opt.signcolumn = "yes" -- Always show sign column to stop flickering
vim.opt.wrap = false -- disable wrap by default
vim.opt.swapfile = false -- Turn off the swapfile
vim.opt.backup = false -- Turn off the backup file
vim.opt.incsearch = true -- Want to show search while searching
vim.opt.tabstop = 2 -- Set default tab size to 2
vim.opt.shiftwidth = 2 -- Set default tab size to 2
vim.opt.expandtab = true -- Expand tabs to spaces by default
vim.opt.undofile = true -- Allow undoing a file even after closing vim
vim.opt.completeopt = "menuone,noselect,popup" -- Settings for the autocomplete popup
vim.opt.winborder = "rounded" -- Make floating windows have a rounded border
vim.opt.ignorecase = true -- Ignore casing when searching
vim.opt.smartcase = true -- Turn off Ignore case when a capital letter is detected
vim.opt.termguicolors = true -- turn on 24-bit colors

-- WSL (work machine): read and write the Windows clipboard through win32yank.exe, which install/deps.sh
-- puts in ~/.local/bin. Named explicitly so nvim does not pick xclip or wl-copy from WSLg first.
if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = "win32yank"
end


vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    { src = "https://github.com/nvim-mini/mini.statusline" },
    { src = "https://github.com/ibhagwan/fzf-lua" }, -- fuzzy pickers: files, grep, buffers, git
    { src = "https://github.com/folke/which-key.nvim" }, -- popup of available keys after a prefix
    { src = "https://github.com/lewis6991/gitsigns.nvim" }, -- git gutter, hunk navigation, stage/reset per hunk
    { src = "https://github.com/seblyng/roslyn.nvim" }, -- C#: drives the Roslyn language server (same one VS Code uses)
    -- Color Schemes
    { src = "https://github.com/vague-theme/vague.nvim" },
    { src = "https://github.com/dracula/vim.git" }
})

vim.cmd.colorscheme("dracula")

require("mini.statusline").setup()
vim.opt.showmode = false -- the statusline shows the mode; drop the -- INSERT -- line
vim.opt.laststatus = 3 -- one global statusline instead of one per split

local nvimts = require("nvim-treesitter")
-- WARN: neovim expects some of these to be installed
nvimts.install({ "c", "c_sharp", "go", "gomod", "gosum", "gowork", "lua", "markdown", "markdown_inline", "query", "vim", "vimdoc", "comment", "yaml" })

-- nvim-treesitter (main) only installs parsers; highlighting and indentation are opt-in per buffer.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if lang and pcall(vim.treesitter.start, args.buf, lang) then
            if vim.treesitter.query.get(lang, "indents") then
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end
    end,
})

-- === fzf-lua: fuzzy jumping around files ===
local fzf = require("fzf-lua")
fzf.setup({
    defaults = { file_icons = false, git_icons = true }, -- no Nerd Font dependency
    winopts = { preview = { layout = "vertical", vertical = "down:60%" } },
})
local map = vim.keymap.set
map("n", "<leader>ff", fzf.files, { desc = "Find files" })
map("n", "<leader>fg", fzf.live_grep, { desc = "Grep (rg)" })
map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>fo", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>fs", fzf.git_status, { desc = "Git status (changed files)" })
map("n", "<leader>fw", fzf.git_worktrees, { desc = "Git worktrees" })
map("n", "<leader>fr", fzf.resume, { desc = "Resume last picker" })
map("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps (search by description)" })

-- === which-key: press a prefix (space, g, z, ], ...) and pause to see what follows ===
local wk = require("which-key")
wk.setup({ delay = 300 }) -- ms before the popup; fast presses never see it
wk.add({
    { "<leader>f", group = "find" },
    { "<leader>c", group = "claude" },
    { "<leader>g", group = "git" },
    { "<leader>l", group = "lsp" },
})

-- === Claude Code: follow it into worktrees, see what it edited, send it files (lua/claude.lua) ===
-- Driven by the PostToolUse hook in config/claude/hooks/nvim-follow.sh; link.sh wires it into settings.json.
require("claude").setup()

-- === gitsigns: see what changed (e.g. what Claude just edited) and act on it per hunk ===
local gs = require("gitsigns")
gs.setup({
    on_attach = function(bufnr)
        local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        -- hunk navigation; falls back to normal ]c/[c inside a diff view
        bmap("n", "]c", function()
            if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
        end, "Next hunk")
        bmap("n", "[c", function()
            if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
        end, "Previous hunk")
        -- act on the hunk under the cursor
        bmap("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
        bmap("n", "<leader>gs", gs.stage_hunk, "Stage hunk (again to unstage)")
        bmap("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        bmap("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
        bmap("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
        bmap("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        bmap("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        -- whole-file views
        bmap("n", "<leader>gd", gs.diffthis, "Diff buffer against index")
        bmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        bmap("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
        -- what to diff against: index (default) or main, useful inside a worktree Claude has been committing in
        bmap("n", "<leader>gm", function() gs.change_base("main", true) end, "Gutter vs main")
        bmap("n", "<leader>gi", function() gs.change_base(nil, true) end, "Gutter vs index")
        -- hunk text object: vih / dah etc.
        bmap({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
    end,
})

-- === Pick up edits made outside nvim (e.g. by Claude in the other pane) ===
-- 'autoread' is on by default; this triggers the check when focus returns
-- (tmux focus-events on), a buffer is entered, or the cursor idles.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = vim.api.nvim_create_augroup("external-reload", { clear = true }),
    callback = function()
        if vim.fn.getcmdwintype() == "" then vim.cmd.checktime() end
    end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
    group = "external-reload",
    callback = function(ev)
        vim.notify("reloaded " .. vim.fn.fnamemodify(ev.file, ":~:."), vim.log.levels.INFO)
    end,
})

-- === Styling ===
-- find the cursor after switching panes
vim.opt.cursorline = true
vim.opt.scrolloff = 8 -- keep 8 lines of context above and below the cursor
vim.opt.sidescrolloff = 8

-- flash the yanked text so you know what you copied
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("yank-highlight", { clear = true }),
    callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- quieter UI
vim.opt.fillchars = { eob = " ", diff = "╱" } -- no ~ column past end of file; hatched deleted lines in diffs
vim.opt.shortmess:append("I") -- no intro screen
vim.opt.pumheight = 10 -- completion menu never taller than 10 rows
vim.opt.inccommand = "split" -- live preview of :s substitutions in a split
vim.opt.splitright = true -- new vertical splits open to the right
vim.opt.splitbelow = true

-- wrapped text, when wrap is turned on (e.g. markdown)
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "

-- diagnostics: a sign in the gutter, text at end of line, rounded float
vim.diagnostic.config({
    virtual_text = { prefix = "●" },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.INFO] = "●",
            [vim.diagnostic.severity.HINT] = "·",
        },
    },
    float = { border = "rounded" },
})

-- Esc clears search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- === LSP ===
-- Nvim 0.11+ has LSP client config built in (vim.lsp.config / vim.lsp.enable); no lspconfig needed for Roslyn.
-- Global dotnet tools live in ~/.dotnet/tools; make sure nvim can see them regardless of how it was launched.
local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
if not vim.env.PATH:find(dotnet_tools, 1, true) then
    vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end
-- mise installs .NET outside the default locations. Inside a mise project DOTNET_ROOT is already set;
-- elsewhere the tool launcher cannot find the runtime without it.
if not vim.env.DOTNET_ROOT then
    local root = vim.fn.expand("~/.local/share/mise/dotnet-root")
    if vim.fn.executable(root .. "/dotnet") == 1 then
        vim.env.DOTNET_ROOT = root
        vim.env.PATH = root .. ":" .. vim.env.PATH
    end
end

-- C# via roslyn.nvim: finds the .sln/.slnx/.csproj, starts `roslyn-language-server`, attaches to .cs buffers.
-- :Roslyn target picks a different solution if it guesses wrong.
require("roslyn").setup({})
vim.lsp.config("roslyn", {
    settings = {
        ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true, -- like VS Code: suggest types you haven't imported yet
            dotnet_show_name_completion_suggestions = true,
        },
        ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_variable_types = true, -- `var` shows the inferred type
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            dotnet_enable_inlay_hints_for_parameters = true, -- parameter names at call sites
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
        },
        ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
        },
    },
})

-- Go via gopls (installed with `go install`, exposed on PATH by mise shims). gopls formats and
-- organizes imports itself, and runs gofumpt and staticcheck internally when told to.
vim.lsp.config("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    settings = {
        gopls = {
            gofumpt = true, -- stricter gofmt
            staticcheck = true,
            usePlaceholders = true, -- completion fills in argument placeholders
            analyses = { unusedparams = true, unusedwrite = true },
            hints = { parameterNames = true, assignVariableTypes = true, compositeLiteralFields = true },
        },
    },
})
vim.lsp.enable("gopls")

-- Go: format and organize imports on save, like the VS Code Go extension does.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("go-format", { clear = true }),
    pattern = "*.go",
    callback = function(args)
        local client = vim.lsp.get_clients({ bufnr = args.buf, name = "gopls" })[1]
        if not client then return end
        local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
        params.context = { only = { "source.organizeImports" }, diagnostics = {} }
        local res = client:request_sync("textDocument/codeAction", params, 2000, args.buf)
        for _, action in ipairs(res and res.result or {}) do
            if action.edit then vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding) end
        end
        vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 2000 })
    end,
})

-- Completion and keymaps for any attached server. Nvim already binds grn (rename), gra (code action),
-- grr (references), gri (implementation), grt (type definition), gO (symbols), K (hover), <C-s> (signature, insert).
vim.opt.completeopt:append("fuzzy")
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local bufnr = args.buf
        local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- IntelliSense-style popup: built-in LSP completion, auto-triggered while typing identifiers
        -- (not only on the server's trigger characters such as "."). <C-y> accepts, <C-e> dismisses.
        if client:supports_method("textDocument/completion") then
            local chars = {}
            for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch(".") do chars[#chars + 1] = c end
            local provider = client.server_capabilities.completionProvider
            provider.triggerCharacters = vim.list_extend(provider.triggerCharacters or {}, chars)
            vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
        end

        bmap("n", "gd", fzf.lsp_definitions, "Go to definition")
        bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        bmap("n", "<leader>lr", fzf.lsp_references, "References")
        bmap("n", "<leader>ls", fzf.lsp_document_symbols, "Document symbols")
        bmap("n", "<leader>lS", fzf.lsp_live_workspace_symbols, "Workspace symbols")
        bmap("n", "<leader>ld", fzf.diagnostics_document, "Diagnostics (buffer)")
        bmap("n", "<leader>lD", fzf.diagnostics_workspace, "Diagnostics (workspace)")
        bmap("n", "<leader>la", fzf.lsp_code_actions, "Code actions")
        bmap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
        if client:supports_method("textDocument/inlayHint") then
            bmap("n", "<leader>lh", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
            end, "Toggle inlay hints")
        end
    end,
})
