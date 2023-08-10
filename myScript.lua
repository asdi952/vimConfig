
local opt = vim.opt

local TAB_WIDTH = 4
opt.tabstop = TAB_WIDTH
opt.shiftwidth = TAB_WIDTH
opt.expandtab = true

opt.cursorline = true
opt.nu = true
opt.rnu = true
opt.cmdheight = 4
opt.formatoptions=cro

-- reserve keybord shortcuts
function cleanShortCuts( cmds)
    for _ , cmd in pairs(cmds) do
        for _ , second in pairs(cmd.second) do
            local key = cmd.first .. second
            local text = ":echo '" .. key .. " -- free' <cr>"
            vim.api.nvim_set_keymap(cmd.mode, key, text, {noremap=true, silent = true})
        end
    end
end 
vim.g.terminal_color_4 = 'red'
-----------------------------------------------------------------------------------
local cmdQs = {{mode="n", first = "q", second={"q","e","r","t","y","u","i","o","p","+"}}}
cleanShortCuts(cmdQs)

--     Personalized COmmand -----------
function GoToVimRC( index)
    local file = CONFIGFILES[tonumber(index)]
    if file == nil then
	    return 
    end
    vim.api.nvim_command("e " .. DIRFILEPATH .. file)	
end 
vim.api.nvim_set_keymap("n", "qy1", ":lua GoToVimRC('1')<cr>", {silent = true})
vim.api.nvim_set_keymap("n", "qy2", ":lua GoToVimRC('2')<cr>", {silent = true})
-----------------------------------------------------------------------------------

function randName()
    local name = ""
    for  i=0, 15, 1 do
        local state = math.random(0,2)    
        local ch = ""
        if state == 0 then
            ch = string.char(math.random(48,57))
        elseif state == 1 then
            ch = string.char(math.random(65,90))
        elseif state == 2 then
            ch = string.char(math.random(97, 122))
        end
        name = name .. ch
    end
    return name
end

function saveToTmp()
    vim.cmd(":write! " .. TMPPATH .. "/" .. randName())
end
forceQuit = false
function QuitWindow()
    if vim.bo.modified then
        if forceQuit then
            saveToTmp()
            vim.api.nvim_command(":quit!")
        else
            print("file not saved")
        end
    else
        vim.api.nvim_command(":quit")
    end
    forceQuit = true
end
    
vim.api.nvim_set_keymap("n", "qq", ":lua QuitWindow()<cr>", {noremap=true, silent = true})
-----------------------------------------------------------------------------------
function createFile() -- TODO need a prompt for user insert name
    file = io.open( vim.fn.expand(DIRFILEPATH) .. "test.txt", "w")
    if file then
       file:write("coconut")
       file:close()
    end
    print("file create")
end

vim.api.nvim_set_keymap("n", "qa", ":lua createFile()<cr>", {silent=true})
-----------------------------------------------------------------------------------
function InsertEnter()
    --vim.cmd("hi StatusLine ctermbg=1 ctermfg=15 guifg=red guibg=black")
    vim.cmd("hi StatusLine ctermfg=5 ctermbg=2 guifg=White guibg=Red")
end
vim.api.nvim_create_autocmd("InsertEnter *",{callback = InsertEnter})

---------------------------------------------------------------------------------

function ErrorHighLight( )
    vim.cmd("hi coco ctermfg=White ctermbg=Red guibg=red")
    local bb = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_add_highlight(bb, -1, 'coco', 87, 0,13)
end
vim.api.nvim_create_autocmd("BufWinEnter",{callback = ErrorHighLight})
-----------------------------------------------------------------------------------

function EnterCommentBackground()
    local curFile = vim.fn.expand("%:p")
    for i, file in pairs( CONFIGFILES)do
        local configFile = DIRFILEPATH .. file 
        if curFile == configFile then
            vim.cmd("hi CommentBackground guibg=green guifg=white ctermbg=gray ctermfg=white")
            vim.cmd("match CommentBackground /-\\{20}-*/")
            return 
        end
    end
end
vim.api.nvim_create_autocmd("BufWinEnter",{callback = EnterCommentBackground})
function LeaveCommentBackground()
    vim.cmd("hi clear CommentBackground ")
end
vim.api.nvim_create_autocmd("BufWinLeave",{callback = LeaveCommentBackground})

-----------------------------------------------------------------------------------
function SetTermToVimDir()
    local curDir = vim.fn.expand("%:h")
    print(curDir)
    local scriptPath = SCRIPTPATH .. "/changeTermDir.bat"
    print(scriptPath)
    local cmd = scriptPath .. " " .. curDir
    print(cmd)
    vim.fn.system(cmd)
    --vim.cmd(":terminal "  .. scriptPath .. " " .. curDir)
end
vim.api.nvim_set_keymap("n", "qo", ":lua SetTermToVimDir()<cr>", {silent=true})

-----------------------------------------------------------------------------------
function InsertEnter()
    vim.cmd("hi StatusLine guifg=blue guibg=white ctermbg=white ctermfg=green")
end
vim.api.nvim_create_autocmd("InsertEnter *", { callback = InsertEnter})
function InsertLeave()
    vim.cmd("hi StatusLine guifg=green guibg=black ctermbg=white ctermfg=blue")
end
vim.api.nvim_create_autocmd("InsertLeave *", { callback = InsertLeave})

-----------------------------------------------------------------------------------
function ErrorCallBack()
    print("error callback")
end
vim.api.nvim_create_autocmd("User", {callback = ErrorCallBack })

-----------------------------------------------------------------------------------

function HelpOnCursor()
    local word = vim.fn.expand("<cword>")
    vim.api.nvim_command("help " .. word)
end
vim.api.nvim_set_keymap("n", "qh", ":lua HelpOnCursor()<cr>", {silent=true})

-----------------------------------------------------------------------------------

function CmdCharInsert()
    print( vim.fn.expand("<afile>"))
end
vim.api.nvim_create_autocmd("CmdlineChanged", { callback = CmdCharInsert})
-----------------------------------------------------------------------------------
local keys = {
    {mode="n", setgroup="sys", key="qq" },
    {mode="n", getgroup="sys", key="qq", callback=function()print("quit")end}
}
local internalKeys= { incGroup= {}, groups={}, keys={}}

function setupKey(elm)
    elm.deps = {}
    elm.resolved = false

end

function insertKeys( elm)
    if #elm.key == 0 then return end
    if elm.resolved == false then return end

    local curKey

    if elm.getgroup ~= nil then
        local groupElm = _i.groups[elm.getgroup]
        curKey = groupElm.content.keys
    else
        curKey = internalKeys.keys
    end
    
    local contentkey
        
    keys:gsub(function(e) 
        contentKey = curKey[e]
        if contentKey == nil then
           contentKey = {key={}, elm = nil} 
           curKey[e] = contentKey 
        end
        curKey = contentKey.key
    end)    

    if elm.callback ~= nil then 
        contentKey.callback = callback
    end
    contentKey.elm = elm 
    elm.content = contentKey
end

function setKeybordShortcuts()
    local _i = internalKeys 
    for i, elm in pairs(keys) do
        setupKey(elm)
        if elm.getgroup ~= nil then 
            local groupElm = _i.groups[elm.getgroup]
            if groupElm == nil then
                local incGroup = _incGroup[elm.getgroup]
                if incGroup == nil then
                    _i.incGroupk[elm.getgroup] = {elm}
                else
                    incGroup:append(elm)
                end
            else
               groupElm.deps:append(elm) 
               elm.resolved = true
               insertKeys(elm)
            end
        else
            elm.resolved = true
           insertKeys(elm) 
        end

        if elm.setgroup ~= nil then
            _i.groups[elm.setgroup] = elm
            local incGroups = _i.incGroup[elm.setgroup]
            if incGroups ~= nil then
                for i, dep in pairs( incGroups) do
                    elm.deps:append(dep)
                end
                _i.incGroup[elm.setGroup] = {}
            end
        end
                

    end
end

-----------------------------------------------------------------------------------
Input = { cols=10, rows=1, posx=10, posy=10}
function Input:new()
    local o = {}
    setmetatable( o, self)
    self.__index = self

    o:init()
    return o
end
function Input:init()
    vim.api.nvim_set_keymap("n", "fr", ":lua Input:OpenWindow()<cr>",{silent=true,noremap=true})
    
end
function Input:OpenWindow()
    print("open window")
    self.buf = vim.api.nvim_create_buf(true, false) 
    vim.api.nvim_create_autocmd("BufLeave", { buffer=self.buf, callback = Input.CloseWindow})

    self.win = vim.api.nvim_open_win( self.buf, true, {
        relative = "editor",
        external,
        width = self.cols ,
        height =self.rows,
        row = self.posy,
        col = self.posx,
        style = "minimal",
        border = "solid",
    })
    vim.api.nvim_create_autocmd("WinLeave", { callback = Input.CloseWindow})
    print(self.win)
    vim.api.nvim_buf_set_lines( self.buf, 0, -1, false, {"a"})
end
function Input:CloseWindow( a)
    print("close window")
    print(self.win)
    print(self.buf)
    --vim.api.nvim_win_close( self.win, true)
    --vim.api.nvim_buf_delete(self.buf, { force = true })
end

--local input = Input:new()

-----------------------------------------------------------------------------------
local win
local buf
function OpenWindow()
    buf = vim.api.nvim_create_buf(true, false) 
    win = vim.api.nvim_open_win( buf, true, {
        relative = "editor",
        width = 10 ,
        height =10,
        row = 10,
        col = 10,
        style = "minimal",
        border = "solid",
    })
    vim.api.nvim_buf_set_lines( buf, 0, -1, false, {"a", "b"})
end
function CloseWindow()
    vim.api.nvim_win_close( win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
end
local winState = 0
function toogleWin()
    if(winState == 0)then
        winState = 1
        OpenWindow()
    else 
        winState = 0
        CloseWindow()
    end
end
vim.api.nvim_set_keymap("n", "ff", ":lua toogleWin()<cr>",{silent=true,noremap=true})


function CmdLineEnter()
    print("cmd enter")
end
vim.api.nvim_create_autocmd("CmdLineEnter *", { callback = CmdLineEnter})

function CmdLineLeave()
    print("cmd leave")
end
vim.api.nvim_create_autocmd("CmdLineEnter *", { callback = CmdLineLeave})

-----------------------------------------------------------------------------------
function commentSelection()
  -- Get the current visual selection
  local start_line, start_col, end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- Iterate over the selected lines and prepend the comment string
  local comment_string = vim.api.nvim_buf_get_option(0, "commentstring")
  for i, line in ipairs(lines) do
    lines[i] = comment_string:gsub("%%s", line)
  end

  -- Replace the selected lines with the commented lines
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end
--vim.api.nvim_set_keymap("v", "qr", ":lua commentSelection()<cr>", {noremap=true, silent = true})
-----------------------------------------------------------------------------------
 print(unpack(vim.api.nvim_buf_get_mark(0, "<")))

-----------------------------------------------------------------------------------
--
function BuildRunScript()
    SaveSource()
    local file = vim.fn.expand("%:f")
    local ext = vim.fn.expand("%:e")
    if ext == "cpp" then
        vim.cmd("sp | terminal clang++ " .. file)
    end

end
vim.api.nvim_set_keymap("n", "qr", ":lua BuildRunScript()<cr>", {noremap=true, silent=true})


local buf1
local win1

function fileColRow(fileBuf)
    local maxCol = 0
    for i , line in ipairs( fileBuf) do
        if #line > maxCol then
            maxCol = #line
        end
    end

    return maxCol, #fileBuf
end
function pTableKeys(table)
    local keys = {}
    for i, key in pairs(table)do
        print(i, key)
    end
end

--local a = vim.api.nvim_get_keymap("q")
--
--for i, elm in pairs(a)do
--    pTableKeys(elm)
--    print(elm.mode, elm.lhs, elm.rhs)
--end
--pTableKeys(a)
--       
function KeyboardUIOpen()
    buf1 = vim.api.nvim_create_buf(true, false) 
    local file_path = "C:\\Users\\spamg\\keyboard\\keyboard.txt"
    local file_content = vim.fn.readfile(file_path)
    local col, row = fileColRow( file_content)
    print(col,row) 
    vim.api.nvim_buf_set_lines( buf1, 0, -1, false, file_content )
    

    win1 = vim.api.nvim_open_win( buf1, true, {
        relative = "editor",
        width = col ,
        height = row ,
        row = 10,
        col = 10,
        style = "minimal",
        border = "solid",
    })

end
function KeyboardUIClose()
    vim.api.nvim_win_close( win1, true)
    vim.api.nvim_buf_delete(buf1, { force = true })

end
local toggleKb = true
function ToogleKeyboardUI()
    if toogleKb == true then
        toogleKb = false
        KeyboardUIOpen()
    else
        toogleKb = true 
        KeyboardUIClose()
    end
end
vim.api.nvim_set_keymap("n", "qt", ":lua ToogleKeyboardUI()<cr>", {noremap=true, silent=true})
