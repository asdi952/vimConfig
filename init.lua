
print("VimRC reloaded ...")

local CURWINDOW = vim.api.nvim_get_current_win()

function getDir(path)
    return path:match("(.*[/\\])")
end

DIRFILEPATH = getDir(vim.fn.expand("<sfile>:p"))

CONFIGFILES = {"init.lua", "myScript.lua", "asdasd"}

TMPPATH = DIRFILEPATH .. "tmp"
SCRIPTPATH = DIRFILEPATH .. "scripts"

os.execute("mkdir " .. TMPPATH)

-----------ENV--------------------------------------------------------------------------
vim.env.CONFIGDIR = DIRFILEPATH 
-----------------------------------------------------------------------------------

function SaveSource()
    vim.api.nvim_command("w")

    local curFile = vim.fn.expand("%:p")
    for i, file in pairs(CONFIGFILES) do
	local configFile = DIRFILEPATH .. file
        if  curFile == configFile then
            print("source ")
            vim.api.nvim_command("source %")
        end
    end
end

vim.api.nvim_set_keymap("n", "qw", ":lua SaveSource()<cr>", {noremap=true, silent = true})

-------------DOFILES------------------------------------------------------------------------
function myDoFile(path)
    local fPath = DIRFILEPATH .. path
    dofile(fPath)
end
myDoFile( "myScript.lua")



