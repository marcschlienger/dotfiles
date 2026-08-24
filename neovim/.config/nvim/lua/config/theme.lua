local M = {}

local families = {
  ["ef-maris"] = {
    light = "ef-maris-light",
    dark = "ef-maris-dark",
    loader = "arete",
  },
  ["modus-tinted"] = {
    light = "modus-operandi-tinted",
    dark = "modus-vivendi-tinted",
    loader = "arete",
  },
  catppuccin = {
    light = "catppuccin-latte",
    dark = "catppuccin-macchiato",
    loader = "catppuccin",
  },
  solarized = {
    light = "solarized",
    dark = "solarized",
    loader = "solarized",
  },
}

-- Change this to select Neovim's family independently of Emacs and Kitty.
local default_family = "ef-maris"
local loading = false

local function current_family()
  return families[vim.g.theme_family] and vim.g.theme_family or default_family
end

function M.load()
  if loading then
    return
  end

  loading = true
  local family = current_family()
  local appearance = vim.o.background == "light" and "light" or "dark"
  local spec = families[family]
  local theme = spec[appearance]
  local ok, err = pcall(function()
    if spec.loader == "arete" then
      require("arete").load(theme, { force = true })
    elseif spec.loader == "catppuccin" then
      require("catppuccin").load(theme:match("^catppuccin%-(.+)$"))
    elseif spec.loader == "solarized" then
      require("solarized").load()
    else
      error("Unknown theme loader: " .. tostring(spec.loader))
    end
  end)
  loading = false

  if not ok then
    error(err)
  end

  -- Keep the wrapper as the active colorscheme. Neovim reloads it when its
  -- terminal background detection changes the 'background' option.
  vim.g.theme_variant = theme
  vim.g.colors_name = "theme-family"
end

function M.apply(family, appearance)
  if not families[family] then
    vim.notify("Unknown theme family: " .. family, vim.log.levels.ERROR)
    return
  end
  if appearance and appearance ~= "light" and appearance ~= "dark" then
    vim.notify("Unknown theme appearance: " .. appearance, vim.log.levels.ERROR)
    return
  end

  vim.g.theme_family = family
  if appearance and vim.o.background ~= appearance then
    -- Avoid reloading whichever scheme happens to be active. The wrapper is
    -- loaded explicitly once after the option has its final value.
    vim.g.colors_name = nil
    vim.o.background = appearance
  end
  vim.cmd.colorscheme("theme-family")
end

function M.setup()
  if not families[vim.g.theme_family] then
    vim.g.theme_family = default_family
  end

  local family_names = vim.tbl_keys(families)
  table.sort(family_names)

  vim.api.nvim_create_user_command("ThemeFamily", function(args)
    M.apply(args.args)
  end, {
    nargs = 1,
    complete = function()
      return family_names
    end,
    desc = "Select a light/dark theme family for this Neovim session",
  })

  vim.api.nvim_create_user_command("ThemeLight", function()
    M.apply(current_family(), "light")
  end, { desc = "Use the light theme from the selected family" })

  vim.api.nvim_create_user_command("ThemeDark", function()
    M.apply(current_family(), "dark")
  end, { desc = "Use the dark theme from the selected family" })

  vim.api.nvim_create_user_command("ThemeToggle", function()
    M.apply(current_family(), vim.o.background == "light" and "dark" or "light")
  end, { desc = "Toggle the selected theme family between light and dark" })

  vim.cmd.colorscheme("theme-family")
end

return M
