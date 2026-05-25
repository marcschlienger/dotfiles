local opt = vim.opt

-- ----------------------------------------------------------------------  
-- Basic settings
-- ----------------------------------------------------------------------  
opt.spelllang = 'de_de,en_us'		-- Set spell checking languages
opt.autowrite = true			-- Write files automatically
opt.autowriteall = true
opt.updatetime = 300
opt.signcolumn = 'yes:1' 		-- Always show signcolumns
opt.shortmess:append('c')
opt.completeopt = {'menu', 'menuone', 'noselect'}

-- ----------------------------------------------------------------------  
-- Configure Python and Node providers
-- ----------------------------------------------------------------------  
vim.g.python3_host_prog = '/usr/bin/python3'
--vim.g.node_host_prog = '/usr/bin/node'

-- ----------------------------------------------------------------------  
-- UI settings
-- ----------------------------------------------------------------------  
opt.number = true          		-- Show line numbers
opt.relativenumber = true		-- Show relative line numbers
opt.cmdheight = 2			-- Number of lines to use for the command-line
opt.lazyredraw = true			-- Redraw only when needed 
opt.cursorline = true			-- Highlight the cursor line
opt.cursorcolumn = false		-- Do not highlight the cursor column
opt.mousehide = true			-- Hide the mouse pointer while typing
opt.errorbells = false			-- Do not beep ...
opt.visualbell = true			-- ... but use the visual

-- Threshold for reporting number of lines changed. When the number of 
-- changed lines is more than 'report' a message will be given for most
-- " ":" commands.
opt.report = 0

-- Minimal number of screen lines to keep above and below the cursor
opt.scrolloff = 5

-- Show mode in status line
opt.showmode = true

-- Show matching bracket for matchtime * 0.1 seconds
opt.showmatch = true
opt.matchtime = 5

-- Use extended regular expressions
opt.magic = true

-- Set the window title: 'titlestring' (if it is not empty), or filename [+=-] (path) - VIM
opt.title = true

-- Open horizontal splits below and vertical splits right of the current window
opt.splitbelow = true
opt.splitright = true

-- Use the system clipboard
opt.clipboard = unnamedplus

-- ----------------------------------------------------------------------  
-- Tabs and spaces
-- ----------------------------------------------------------------------  
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true
opt.cindent = true
opt.smarttab = true

-- ----------------------------------------------------------------------  
-- Folding
-- ----------------------------------------------------------------------  
opt.foldenable = true
opt.foldmethod = 'indent'
opt.foldlevelstart = 99			-- open most folds by default

-- ----------------------------------------------------------------------  
-- Line wrapping
-- ----------------------------------------------------------------------  
opt.wrap = true
vim.g.showbreak = '… '
opt.linebreak = true
opt.breakindent = true

-- Display the color column
vim.cmd[[execute "set colorcolumn=+" . join(range(1,255), ',+')]]

-- Turn on list chars only when needed since it is not compatible with 
-- linebreak
opt.list = false
opt.listchars = {tab = '▸ ', eol = '¬', extends = '❯', precedes = '❮',nbsp = '_' ,trail = '.'}

-- ----------------------------------------------------------------------  
-- Search settings
-- ----------------------------------------------------------------------  
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.showmatch = true
opt.hlsearch = true
opt.wrapscan = true

-- ----------------------------------------------------------------------  
-- Undo settings
-- ----------------------------------------------------------------------  
opt.undofile = true
opt.undolevels = 1000
opt.undoreload = 10000

-- ----------------------------------------------------------------------  
-- Backup settings
-- ----------------------------------------------------------------------  
opt.backup = false
opt.writebackup = false

