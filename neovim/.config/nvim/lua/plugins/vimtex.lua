if vim.fn.has('macunix') == 1 then
  vim.g.vimtex_view_method = 'skim'
elseif vim.fn.has('unix') == 1 then
  vim.g.vimtex_view_method = 'zathura'
end
