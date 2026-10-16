-- Markdown: open in "read mode" by default, toggle back to "code mode" with <leader>m

local function read_mode(bufnr)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- wrap at word boundaries, not mid-word
    vim.opt_local.breakindent = true -- keep list/quote indent on wrapped lines
    vim.opt_local.list = false -- hide the eol/space listchars
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.cursorline = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"

    -- move by screen line so j/k feel right inside wrapped paragraphs
    for _, key in ipairs({ "j", "k" }) do
        vim.keymap.set("n", key, "g" .. key, { buffer = bufnr, desc = "Move by display line" })
    end
    vim.keymap.set("n", "0", "g0", { buffer = bufnr })
    vim.keymap.set("n", "$", "g$", { buffer = bufnr })

    vim.b[bufnr].md_read_mode = true
end

-- every option read mode sets, back to the global value from init.lua
local read_mode_options = {
    "wrap", "linebreak", "breakindent", "list", "number", "relativenumber",
    "cursorline", "signcolumn", "conceallevel", "concealcursor", "spell", "spelllang",
}

local function code_mode(bufnr)
    for _, name in ipairs(read_mode_options) do
        vim.opt_local[name] = vim.go[name]
    end

    for _, key in ipairs({ "j", "k", "0", "$" }) do
        pcall(vim.keymap.del, "n", key, { buffer = bufnr })
    end

    vim.b[bufnr].md_read_mode = false
end

local bufnr = vim.api.nvim_get_current_buf()

read_mode(bufnr)

vim.keymap.set("n", "<leader>m", function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].md_read_mode then
        code_mode(buf)
        vim.notify("markdown: code mode", vim.log.levels.INFO)
    else
        read_mode(buf)
        vim.notify("markdown: read mode", vim.log.levels.INFO)
    end
end, { buffer = bufnr, desc = "Toggle [M]arkdown read/code mode" })
