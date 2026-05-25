local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Move line up and down in NORMAL and VISUAL modes
-- Reference: https://vim.fandom.com/wiki/Moving_lines_up_or_down
map('n', '<C-j>', '<CMD>move .+1<CR>')
map('n', '<C-k>', '<CMD>move .-2<CR>')
map('x', '<C-j>', ":move '>+1<CR>gv=gv")
map('x', '<C-k>', ":move '<-2<CR>gv=gv")

-- Open and close folds
map('n', '<leader>z', 'za')

-- Toggle the use of list characters
map('n', '<leader>l', ':set list!<CR>')

-- Toggle between number and relativenumber
map('n', '<leader>n', ':set relativenumber!<CR>')

-- Make the current file executable
map('n', '<leader>x', ':w<CR>:!chmod 755 %<CR>:e<CR')

-- Move to the next/previous buffer
map('n', '<leader>]', '<CMD>bn<CR>')
map('n', '<leader>[', '<CMD>bp<CR>')

-- Switch between the current and the last buffer
map('n', '<leader><space>', '<C-^>')

-- Kill the current buffer
map('n', '<leader>w', '<CMD>bd<CR>')

-- Delete a line in insert mode
map('i', '<C-d>', '<ESC>ddi')

-- Convert the current word to uppercase in normal and insert mode
map('n', '<C-u>', 'viwU')
map('i', '<C-u>', '<ESC>viwUi')

-- Quickly save the current buffer or all buffers
map('n', '<leader>s', '<CMD>update<CR>')
map('n', '<leader>S', '<CMD>wall<CR>')

-- Insert a blank line below/above
map('n', '<leader>o', 'o<ESC>')
map('n', '<leader>O', 'O<ESC>')

-- Use operator pending mode to visually select the whole buffer
-- e.g. dA = delete buffer ALL, yA = copy whole buffer ALL
map('o', 'A', ':<C-U>normal! mzggVG<CR>`z')
map('x', 'A', ':<C-U>normal! ggVG<CR>')

-- Search
map('n', '<C-h>', '<CMD>noh<CR>')

-- Remap jk to escape in insert mode
map('i', 'jk', '<ESC>')

