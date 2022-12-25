local api = vim.api

local modes = {
	["n"] = "NORMAL",
	["no"] = "NORMAL",
	["v"] = "VISUAL",
	["V"] = "VISUAL LINE",
	[""] = "VISUAL BLOCK",
	["s"] = "SELECT",
	["S"] = "SELECT LINE",
	[""] = "SELECT BLOCK",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["R"] = "REPLACE",
	["Rv"] = "VISUAL REPLACE",
	["c"] = "COMMAND",
	["cv"] = "VIM EX",
	["ce"] = "EX",
	["r"] = "PROMPT",
	["rm"] = "MOAR",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}

local left_sep = ''
local right_sep = ''

local black = 0
local green = 49
local purple = 105
local blue = 117
local red = 203
local yellow = 221

api.nvim_command("hi File ctermfg=15 ctermbg=0")
api.nvim_command("hi FileSep ctermfg=0 ctermbg=None")

api.nvim_command("hi NoErrors ctermfg=15 ctermbg=245")
api.nvim_command("hi NoErrorsSep ctermfg=245 ctermbg=None")

api.nvim_command("hi Errors ctermfg=15 ctermbg="..red)
api.nvim_command("hi ErrorsSep ctermfg="..red.."ctermbg=None")

api.nvim_command("hi Lines ctermfg=15 ctermbg=197")
api.nvim_command("hi LinesSep ctermfg=197 ctermbg=None")

local function get_mode()
	local mode = api.nvim_get_mode().mode
	local current_mode = modes[mode]:upper()
	local mode_fg = black
	local mode_bg = nil

	if mode == "n" or mode == "no" then
		mode_bg = blue
	elseif mode == "i" or mode == "ic" then
		mode_bg = green
	elseif mode == "c" then
		mode_bg = purple
	elseif mode == "v" or "V" or "^V" then
		mode_bg = yellow
	elseif mode == "t" then
		mode_bg = red
	else
		mode_bg = 15
	end

	api.nvim_command("hi Mode ctermfg="..mode_fg.." ctermbg="..mode_bg)
	api.nvim_command("hi ModeSep ctermfg="..mode_bg.." ctermbg=None")

	return "%#ModeSep#"..left_sep.."%#Mode# "..current_mode.." %#ModeSep#"..right_sep
end

local function diagnostic_status()
	local num_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local num_warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	
	diagnostics = string.format(" %d  %d", num_errors, num_warnings)
	
	
	if num_errors == 0 and num_warnings == 0 then
		return "%#NoErrorsSep#"..left_sep.."%#NoErrors# "..diagnostics.." %#NoErrorsSep#"..right_sep
	else
		return "%#ErrorsSep#"..left_sep.."%#Errors# "..diagnostics.." %#ErrorsSep#"..right_sep
	end
end

local function get_file_info()
		local filename = vim.fn.expand("%")
	local extension = vim.fn.expand("%:e")
	local icon, color = require('nvim-web-devicons').get_icon_cterm_color(filename, extension)

	local modified = api.nvim_exec("echo &modified", true)

	api.nvim_command("hi Icon ctermfg="..color.." ctermbg=0")
	api.nvim_command("hi Save ctermfg="..green.." ctermbg=0")

	if modified == "1" then
		return "%#FileSep#"..left_sep.."%#Icon# "..icon.."%#File# %F %#Save# %#FileSep#"..right_sep
	else
		return "%#FileSep#"..left_sep.."%#Icon# "..icon.."%#File# %F %#FileSep#"..right_sep
	end
end

local function get_lines()
	
	return "%#LinesSep#"..left_sep.."%#Lines# %l/%L %#LinesSep#"..right_sep
end

local function get_file_encoding()
	return "%#FileSep#"..left_sep.."%#File# %{toupper(&fenc)} %#FileSep#"..right_sep
end

local function get_file_status()
	local readonly = api.nvim_exec("echo &readonly", true)

	if readonly == "1" then
		return "%#ErrorsSep#"..left_sep.."%#Errors#  %#ErrorsSep#"..right_sep
	else
		return "%#FileSep#"..left_sep.."%#File#  %#FileSep#"..right_sep
	end
end

local module = {}

function module.get()
	local parts = {
		get_mode(),
		diagnostic_status(),
		"%=",
		get_file_info(),
		"%=",
		get_lines(),
		get_file_encoding(),
		get_file_status()
	}

	return table.concat(parts, " ")
end

return module
