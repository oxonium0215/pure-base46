local M = {}
local fn = vim.fn

M.load_config = function()
    local config_path = vim.fn.stdpath("config") .. "/lua/base46-config.lua"
    if vim.fn.filereadable(config_path) == 0 then
        -- define default config
        local default_config = [[
local options = {
  base46 = {
    theme = "onedark", -- default theme
    hl_add = {},
    hl_override = {},
    integrations = {},
    changed_themes = {},
    transparency = false,
    theme_toggle = { "onedark", "one_light" },
  },
  ui = {
    cmp = {
      icons = true,
      lspkind_text = true,
      style = "default", -- default/flat_light/flat_dark/atom/atom_colored
    },

    telescope = { style = "borderless" }, -- borderless / bordered

    statusline = {
      theme = "default", -- default/vscode/vscode_colored/minimal
      -- default/round/block/arrow separators work only for default statusline theme
      -- round and block will work for minimal theme only
      separator_style = "default",
      order = nil,
      modules = nil,
    },

    -- lazyload it when there are 1+ buffers
    tabufline = {
      enabled = true,
      lazyload = true,
      order = { "treeOffset", "buffers", "tabs", "btns" },
      modules = nil,
    },
  },
  lsp = { signature = true },
  mason = { cmd = true, pkgs = {} },
}
return options
]]
        local file = io.open(config_path, "w")
        if file then
            file:write(default_config)
            file:close()
            print("Created default base46-config.lua")
        else
            error("Failed to create base46-config.lua")
        end
    end

    local ok, config = pcall(require, "base46-config")
    if not ok then
        error("Failed to load base46-config: " .. config)
    end

    return config
end

M.list_themes = function()
  local default_themes = vim.fn.readdir(vim.fn.stdpath "data" .. "/lazy/base46/lua/base46/themes")
  local custom_themes = vim.loop.fs_stat(fn.stdpath "config" .. "/lua/themes")

  if custom_themes and custom_themes.type == "directory" then
    local themes_tb = fn.readdir(fn.stdpath "config" .. "/lua/themes")
    for _, value in ipairs(themes_tb) do
      table.insert(default_themes, value)
    end
  end

  for index, theme in ipairs(default_themes) do
    default_themes[index] = theme:match "(.+)%..+"
  end

  return default_themes
end

M.replace_word = function(old, new)
  local config_file = vim.fn.stdpath "config" .. "/lua/" .. "base46-config.lua"
  local file = io.open(config_file, "r")
  local added_pattern = string.gsub(old, "-", "%%-") -- add % before - if exists
  local new_content = file:read("*all"):gsub(added_pattern, new)

  file = io.open(config_file, "w")
  file:write(new_content)
  file:close()
end

M.set_cleanbuf_opts = function(ft)
  local opt = vim.opt_local

  opt.buflisted = false
  opt.modifiable = false
  opt.buftype = "nofile"
  opt.number = false
  opt.list = false
  opt.wrap = false
  opt.relativenumber = false
  opt.cursorline = false
  opt.colorcolumn = "0"
  opt.foldcolumn = "0"

  vim.opt_local.filetype = ft
  vim.g[ft .. "_displayed"] = true
end

M.setup_bufferline_icons = function()
  local colors = require("base46").get_theme_tb "base_30"
  local icon_ok, webDevicons = pcall(require, "nvim-web-devicons")
  if not icon_ok then
    return
  end
  local filename = vim.fn.expand("%:t")
  local ext = vim.fn.expand("%:e")
  local _, icon_name = webDevicons.get_icon(filename, ext, { default = true })
  local _, icon_color = webDevicons.get_icon_color(filename, ext, { default = true })
  if not icon_name then
    return
  end
  local iconSkeleton = {
    ["BufferLine" .. icon_name .. "Selected"] = {
      bg = colors.black,
      fg = icon_color,
    },
    ["BufferLine" .. icon_name] = {
      bg = colors.black2,
      fg = icon_color,
    },
    ["BufferLine" .. icon_name .. "Inactive"] = {
      bg = colors.black2,
      fg = icon_color,
    },
  }
  return iconSkeleton
end

return M
