---@diagnostic disable: undefined-global
--[[

    Script by Tobias00723
    from the TGFB server
    Discord : https://discord.gg/hEHd4A3czx
    any questions?                   ^^
    find me on my discord server     ^^

    These scripts are opensource and free to use for everybody.
    But i would appreaciate some credit if you "borrow" some code ;p

]]





--Change to 'true' if you want to load all settings below from a .lua file (so you just need to restard mission to change a setting here)
--Settings file will be located at default in Your DCS saved games folder : DCS\Missions\Saves\Script_loader_settings.lua

Dynamic_settings = true



--change how the dir as you like, this will create a 'TGFB_script_loader_settings.lua' file in the directory below only if
--Dynamic_settings is set to true : default is your DCS saved games folder : DCS\Missions\Saves\Script_loader_settings.lua
--!!When puting in your directory make sure you use the '/' other wise it will not find the directory

Settings_Dir = lfs.writedir()..'Missions\\Saves'



--list all your .lua files here that you dont want to load with the mission

BadScripts = {
    "Example_exlude1.lua",
    "Example_exlude2.lua",
    "Example_exlude3.lua",
}



--Change to 'true' to removes the message when scripts are loaded

Silent_mode = false



--put your directory inbetween the "" where you have all your lua files in.
--Warning : this script will also search in the subdirectories!
--!!When puting in your directory make sure you use the '/' other wise it will not find the directory

Dir = lfs.writedir() .. "Missions/your/mission/directory"




--[[


    DO NOT EDIT BELOW THIS LINE     DO NOT EDIT BELOW THIS LINE     DO NOT EDIT BELOW THIS LINE
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=





















]]






local exclude_not_found = {}

local exclude_count = 0
local function directoryToLuaFileName(path)
    return path:match("[^/]*.lua$")
end

local function TobyLoadFiles(LuaFilesTable)
    for TobyLoops, fileDir in ipairs(LuaFilesTable) do
        local fileName = directoryToLuaFileName(fileDir)
        local badFile = false
        local counter = 0
        for i, Bad_file_name in pairs(BadScripts) do
            counter = counter + 1
            if fileName == Bad_file_name then
                exclude_count = exclude_count + 1
                --trigger.action.outText("excluded :" ..fileName, 15, false)
                badFile = true
                table.remove(exclude_not_found, counter)
            end
        end

        if badFile == false then
            local success, load_error = loadfile(fileDir)

            if success then
                local success2, execution_error = pcall(success)
                if not success2 then
                    trigger.action.outText("Failed to execute " .. fileDir .. "\n\n File : " .. fileName .. "\n\n Error msg: " .. execution_error, 180, false)
                end
            else
                trigger.action.outText("Failed to load " .. fileDir .. "\n\n File : " .. fileName .. "\n\n Error msg: " .. load_error, 180, false)
            end
        end
    end
end

function Table_to_string(tbl)
    local str = "{\n"

    for j, Content in pairs(tbl) do
        local new_str = "\t\"" .. tostring(Content) .. "\",\n"
        str = str .. new_str
    end
    return str .. "}"
end

function Init_dynamic_settings(filepath)

    trigger.action.outText("Dynamic settings initialized", 15, false)
    local file = io.open(filepath, "w")

    if file then
        file:write("Dir = \"" .. tostring(Dir) .. "\"\n\n")
        --file:write("Settings_Dir = \"" .. tostring(Settings_Dir) .. "\"\n\n")
        --file:write("Dynamic_settings = " .. tostring(Dynamic_settings) .. "\n\n")
        file:write("Silent_mode = " .. tostring(Silent_mode) .. "\n\n")
        file:write("BadScripts = " .. Table_to_string(BadScripts))
        file:close()
        file = io.open(filepath, "r")
        if file then
            local filecontent = file:read()
            if filecontent then
                local success, error = loadfile(filepath:gsub('/','\\'))
                if success then
                    local success2, execution_error = pcall(success)
                    if not success2 then
                        trigger.action.outText("Failed to execute " .. fileDir .. "\n\n File : 'TGFB_script_loader_settings.lua'\n\n Error msg: " .. execution_error, 180, false)
                    end

                    if not Silent_mode then
                        trigger.action.outText("Dynamic settings enabled", 15, false)
                    end
                else
                    trigger.action.outText("Failed to load " .. filepath:gsub('/','\\') .. "\nUsing own setting instead\n\n" .. error , 180, false)
                end
                file:close()
            end
        end
    else
        trigger.action.outText("Failed to make file\nUsing own setting instead", 15, false)
    end
end

if lfs then
    if io then
        trigger.action.outText("Dynamic DCS .lua loading script by : Tobias00723", 30 , false)
        if not Silent_mode then
            trigger.action.outText("Searching in : " .. Dir, 15 , false)
        end
        local File_count = 0

        if Dynamic_settings then
            if not Silent_mode then
                trigger.action.outText("Settings file located at : " .. Settings_Dir, 15 , false)
            end
            lfs.mkdir(Settings_Dir)

            local filepath = '\\TGFB_script_loader_settings.lua'
            filepath = Settings_Dir..filepath
            local file = io.open(filepath, "r")
            if file then
                local content = file:read("*a")
                if content ~= nil and content ~= "" then
                    local success, error = loadfile(filepath:gsub('/','\\'))
                    if success then
                        local success2, execution_error = pcall(success)
                        if not success2 then
                            trigger.action.outText("Failed to execute " .. fileDir .. "\n\n File : 'TGFB_script_loader_settings.lua'\n\n Error msg: " .. execution_error, 180, false)
                        end
                        if not Silent_mode then
                            trigger.action.outText("Dynamic settings enabled" , 15 , false)
                        end
                    else
                        trigger.action.outText("Failed to load " .. filepath:gsub('/','\\') .. "\nUsing own setting instead\n\n" .. error , 180, false)
                    end
                    file:close()
                else
                    Init_dynamic_settings(filepath)
                end 
            else
                Init_dynamic_settings(filepath)
            end
        end

        Dir = Dir:gsub('\\','/')

        exclude_not_found = BadScripts

        local found = false
        for i, Filename in pairs(BadScripts) do
            if Filename == "DCS_Dynamic_Script_loader_Tobias00723.lua" then
                found = true
            end
        end
        if not found then
            table.insert(BadScripts , "DCS_Dynamic_Script_loader_Tobias00723.lua")
        end
        -- Function to check if a given file has a Lua extension
        local function isLuaFile(filename)
            return filename:match("%.lua$") ~= nil
        end

        -- Function to get a table of Lua files in a directory (including subdirectories)
        local function getLuaFilesInDirectory(directory)
            local luaFiles = {}

            for file in lfs.dir(directory) do
                if file ~= "." and file ~= ".." then
                    local fullPath = directory .. "/" .. file

                    if lfs.attributes(fullPath, "mode") == "file" and isLuaFile(file) then
                        table.insert(luaFiles, fullPath)
                        File_count = File_count + 1
                    elseif lfs.attributes(fullPath, "mode") == "directory" then
                        -- Recursively search subdirectories
                        local subdirectoryFiles = getLuaFilesInDirectory(fullPath)
                        for _, subfile in ipairs(subdirectoryFiles) do
                            table.insert(luaFiles, subfile)
                            File_count = File_count + 1
                        end
                    end
                end
            end

            return luaFiles
        end

        LuaFilesTable = getLuaFilesInDirectory(Dir)
        TobyLoadFiles(LuaFilesTable)
        if not Silent_mode then
            if exclude_count == 0 then
                exclude_count = 1
            end
            if File_count == 0 then
                File_count = 2
            end
            if #exclude_not_found > 0 then
                trigger.action.outText("'".. File_count - exclude_count - 1 .. "' .lua files loaded!\nAnd excluded '".. exclude_count - 1 .. "' .lua files\n\nWARNING : '" .. #exclude_not_found .. "' excluded .lua files are missed!" , 30, false)
                for i, missed_exclude in pairs(exclude_not_found) do
                    trigger.action.outText("Missed exlude : '" .. missed_exclude .."'", 30, false)
                end
            else
                trigger.action.outText("All '".. File_count - exclude_count - 1 .. "' .lua files loaded!\nAnd excluded all '".. exclude_count - 1 .. "' .lua files" , 15, false)
            end
        end
    else
        trigger.action.outText("Failed to use io" , 60 , false)
        env.error("Failed to init io", true)
    end
else
    trigger.action.outText("Failed to use lfs" , 60 , false)
    env.error("Failed to init lfs", true)
end