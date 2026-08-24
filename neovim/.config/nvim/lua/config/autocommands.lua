local cmd = vim.cmd

-- Highlight on yank
cmd [[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank()
	augroup end
]]

-- Don't show the cursorline in insert mode
cmd([[
    augroup cline
        autocmd!
        autocmd InsertEnter * set nocursorline
        autocmd InsertLeave * set cursorline
    augroup END
]])
