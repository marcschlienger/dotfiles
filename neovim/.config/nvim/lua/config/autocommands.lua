local cmd = vim.cmd

-- Highlight on yank
cmd [[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank()
	augroup end
]]

-- Automatically cd into the directory that the current file is in
cmd([[
    augroup System
        autocmd!
        autocmd BufEnter * silent! lcd %:p:h
    augroup END
]])

-- Don't show the cursorline in insert mode
cmd([[
    augroup cline
        autocmd!
        autocmd InsertEnter * set nocursorline
        autocmd InsertLeave * set cursorline
    augroup END
]])

