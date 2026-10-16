-- Claude Code <-> nvim glue for the tmux two-pane layout (nvim in one pane, `claude` in the other).
--
-- Inbound (driven by ~/.claude/hooks/nvim-follow.sh over `nvim --server <socket> --remote-expr`):
--   Claude.enter(path)   Claude entered a worktree: open a tab for it (same file as the current one if it exists there)
--   Claude.exit(path)    Claude left a worktree: go back to the tab for `path`, drop tabs whose directory is gone
--   Claude.edited(file)  Claude wrote a file: reload it if open, remember it for <leader>cl / <leader>ce
--
-- Outbound (keymaps): send a file reference or selection to the claude pane, jump to it.
--
-- nvim publishes its RPC socket as the tmux pane option @nvim_socket; the hook reads it from the panes in
-- Claude's window. Nothing is guessed from pids or $XDG_RUNTIME_DIR, so it works the same under WSL.

local M = {
    follow = true, -- auto-switch tabs on enter/exit; :ClaudeFollow or <leader>cf toggles
    recent = {}, -- files Claude edited, most recent first
}

local function tmux(args)
    if not vim.env.TMUX then return nil end
    local res = vim.system(vim.list_extend({ "tmux" }, args), { text = true }):wait()
    if res.code ~= 0 then return nil end
    return (res.stdout or ""):gsub("%s+$", "")
end

local function relative(path)
    return vim.fn.fnamemodify(path, ":~:.")
end

local function tab_for(path)
    path = vim.fs.normalize(path)
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if vim.fs.normalize(vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab))) == path then
            return tab
        end
    end
end

-- === inbound ===

function M.enter(path)
    if not M.follow then return "off" end
    local tab = tab_for(path)
    if tab then
        vim.api.nvim_set_current_tabpage(tab)
        vim.notify("claude → " .. relative(path), vim.log.levels.INFO)
        return "switched"
    end
    -- carry the file you are looking at over to the worktree when it exists there
    local same_file = nil
    local current = vim.api.nvim_buf_get_name(0)
    if current ~= "" and vim.bo.buftype == "" then
        local rel = vim.fn.fnamemodify(current, ":.")
        if not rel:match("^/") and vim.uv.fs_stat(path .. "/" .. rel) then
            same_file = { rel, vim.api.nvim_win_get_cursor(0)[1] }
        end
    end
    vim.cmd.tabnew()
    vim.cmd("tcd " .. vim.fn.fnameescape(path))
    if same_file then
        vim.cmd("edit " .. vim.fn.fnameescape(same_file[1]))
        pcall(vim.api.nvim_win_set_cursor, 0, { same_file[2], 0 })
    end
    vim.notify("claude → " .. relative(path) .. " (new tab)", vim.log.levels.INFO)
    return "opened"
end

function M.exit(path)
    if not M.follow then return "off" end
    local target = tab_for(path)
    if target then vim.api.nvim_set_current_tabpage(target) end
    -- a removed worktree leaves a tab pointing at nothing; close it unless it holds unsaved work
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local dir = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tab))
        if not vim.uv.fs_stat(dir) and #vim.api.nvim_list_tabpages() > 1 then
            local dirty = false
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
                if vim.bo[vim.api.nvim_win_get_buf(win)].modified then dirty = true end
            end
            if not dirty then pcall(vim.cmd.tabclose, vim.api.nvim_tabpage_get_number(tab)) end
        end
    end
    vim.notify("claude → " .. relative(path), vim.log.levels.INFO)
    return "exited"
end

function M.edited(file)
    file = vim.fs.normalize(file)
    for i, f in ipairs(M.recent) do
        if f == file then table.remove(M.recent, i) break end
    end
    table.insert(M.recent, 1, file)
    if #M.recent > 50 then table.remove(M.recent) end
    -- pick the change up now rather than on the next focus/cursor-hold; leave buffers with local edits alone
    local buf = vim.fn.bufnr(file)
    if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].modified then
        vim.cmd("silent! checktime " .. buf)
    end
    vim.notify("claude edited " .. relative(file), vim.log.levels.INFO)
    return "noted"
end

-- === outbound ===

-- The claude pane: marked by the hook (@claude_pane) or, before the first hook call, by its process name.
local function claude_pane()
    -- -t: the window holding this nvim; without it tmux answers for the window on screen, which may differ
    if not vim.env.TMUX_PANE then return nil end
    local out = tmux({ "list-panes", "-t", vim.env.TMUX_PANE, "-F", "#{pane_id} #{@claude_pane} #{pane_current_command}" })
    if not out then return nil end
    local by_mark, by_name
    for line in out:gmatch("[^\n]+") do
        local id, mark, cmd = line:match("^(%S+) (%S*) ?(%S*)$")
        if id and id ~= vim.env.TMUX_PANE then
            if mark == "1" then by_mark = by_mark or id end
            if cmd == "claude" then by_name = by_name or id end
        end
    end
    return by_mark or by_name
end

-- Type text into the claude prompt without submitting it, so you can keep writing.
function M.send(text)
    local pane = claude_pane()
    if not pane then
        vim.notify("no claude pane in this tmux window", vim.log.levels.WARN)
        return
    end
    tmux({ "send-keys", "-t", pane, "-l", text })
end

function M.send_file()
    M.send("@" .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.") .. " ")
end

function M.send_selection()
    local first, last = vim.fn.line("v"), vim.fn.line(".")
    if first > last then first, last = last, first end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    M.send(string.format("@%s L%d-L%d ", vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":."), first, last))
end

function M.focus()
    local pane = claude_pane()
    if pane then tmux({ "select-pane", "-t", pane }) end
end

function M.open_last()
    local file = M.recent[1]
    if not file then
        vim.notify("claude has not edited anything yet", vim.log.levels.INFO)
        return
    end
    vim.cmd("edit " .. vim.fn.fnameescape(file))
end

function M.pick_recent()
    if #M.recent == 0 then
        vim.notify("claude has not edited anything yet", vim.log.levels.INFO)
        return
    end
    local fzf = require("fzf-lua")
    fzf.fzf_exec(vim.tbl_map(relative, M.recent), {
        prompt = "claude edited> ",
        previewer = "builtin",
        actions = fzf.defaults.actions.files,
    })
end

function M.toggle_follow()
    M.follow = not M.follow
    vim.notify("claude follow " .. (M.follow and "on" or "off"), vim.log.levels.INFO)
end

-- === setup ===

function M.setup()
    _G.Claude = M -- the hook calls v:lua.Claude.<fn>()

    -- publish this instance's socket on its tmux pane; the hook looks for it in Claude's window
    local group = vim.api.nvim_create_augroup("claude-nvim", { clear = true })
    if vim.env.TMUX and vim.env.TMUX_PANE then
        vim.api.nvim_create_autocmd("VimEnter", {
            group = group,
            callback = function()
                if vim.v.servername ~= "" then
                    tmux({ "set", "-p", "-t", vim.env.TMUX_PANE, "@nvim_socket", vim.v.servername })
                end
            end,
        })
        vim.api.nvim_create_autocmd("VimLeavePre", {
            group = group,
            callback = function() tmux({ "set", "-p", "-u", "-t", vim.env.TMUX_PANE, "@nvim_socket" }) end,
        })
    end

    vim.api.nvim_create_user_command("ClaudeFollow", M.toggle_follow, { desc = "Toggle following Claude into worktrees" })

    local map = vim.keymap.set
    map("n", "<leader>cf", M.toggle_follow, { desc = "Toggle follow into worktrees" })
    map("n", "<leader>cl", M.open_last, { desc = "Open last file Claude edited" })
    map("n", "<leader>ce", M.pick_recent, { desc = "Pick a file Claude edited" })
    map("n", "<leader>cs", M.send_file, { desc = "Send @file to Claude" })
    map("x", "<leader>cs", M.send_selection, { desc = "Send @file L1-L2 to Claude" })
    map("n", "<leader>cc", M.focus, { desc = "Jump to the Claude pane" })
end

return M
