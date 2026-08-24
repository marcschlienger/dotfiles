-- init.lua --- Personal configuration file for neovim.
--
-- Copyright (C) 2022-2024 Marc Schlienger <marc.schlienger@psoteo.de>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software FOUNDATION, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Leaders must be defined before plugins create their mappings.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.lazy')
require('config.autocommands')
require('config.colors')
require('config.keymaps')
require('config.options')
require('plugins.lsp')
