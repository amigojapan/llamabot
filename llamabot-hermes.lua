#!/usr/bin/lua
local http = require("socket.http")
local ltn12 = require"ltn12"
local body = {}

local context=nil
local tabstring=nil

local JSON = require "json"
--local json = require "cjson"
require "inkeylua"
require "helperFunctions"
--print("Welcome to voice internet relayed chat, press control plus C to quit")
socket = require("socket")
print("starting llamabot")
function getFirstWord(inputString)
    local firstWord = string.match(inputString, "%S+")
    return firstWord
end

function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
    return s
end

function stripCRLF(str)
    return str:gsub("\r\n$", "")
end

function removeApostrophes(inputString)
    inputString=inputString:gsub("'", "")
    inputString=inputString:gsub(";", "")
    inputString=inputString:gsub("|", "")
    inputString=inputString:gsub("\"", "")
    inputString=inputString:gsub(">", "")
    inputString=inputString:gsub("<", "")
    inputString=inputString:gsub("%(", "") --need % cause ( is a "magic character"
    inputString=inputString:gsub("%)", "")
    inputString=inputString:gsub("%[", "")
    inputString=inputString:gsub("{", "")
    inputString=inputString:gsub("}", "")
    return inputString
end

function post(uri,data)
    local res, code, headers, status = http.request {
        method = "POST",
        url = uri,
        source = ltn12.source.string(data),
        headers = {
            ["content-type"] = "text/plain",
            ["content-length"] = #data
        },
        sink = ltn12.sink.table(body)
    }

    response = table.concat(body)local http = require("socket.http")
    local ltn12 = require"ltn12"
    local body = {}

    local res, code, headers, status = http.request {
        method = "POST",
        url = uri,
        source = ltn12.source.string(data),
        headers = {
            ["content-type"] = "text/plain",
            ["content-length"] = #data
        },
        sink = ltn12.sink.table(body)
    }

    response = table.concat(body)
    return response
end

if(arg[1]) then
    nick = arg[1]
else    
    nick ="doraemon"
end
 
if(arg[2]) then
    channel = arg[2]
else    
    channel = "#VoxAssist"
end

server = "irc.libera.chat"

client = socket.tcp()
client:connect(server, 6667)
client:settimeout(0.5)


user_input = ""
print("waiting 5 seconds for connect...\r\n server, " .. server .. " channel, " .. channel .. "")
socket.sleep(5) -- wait enough till logon

line = "nick ".. nick .. "\r\nuser a a a a\r\n"
--os.exit()
print(line)
client:send(line)

socket.sleep(2)

line = "join " .. channel .. "\r\n"
print(line)
client:send(line)

socket.sleep(2)

buff = ""
afterEnter="not entered"
userInputBefore=""
buff=""

function translate(message,command)
    local start, finish = string.find(message, command)
    if start==1 then --this tests to see is !tellai is at the beginning of the string
        --local _,aicommand=getBeforeAndAfterSTring(buff,nick)
        local _,aicommand=getBeforeAndAfterSTring(buff,command)
        aicommand=removeApostrophes(aicommand)
        --maybe make two commands !tellai !askai
        aicommand = stripCRLF(aicommand)
        print("aicommand:"..aicommand)
        if command == "!men" then
            line = "privmsg " .. channel .. " :" .. ".trenes " .. aicommand .. "\r\n"
            client:send(line)
            line = "privmsg " .. channel .. " :" .. ".trenja " .. aicommand .. "\r\n"
            client:send(line)
        end
        if command == "!mes" then
            line = "privmsg " .. channel .. " :" .. ".tresen " .. aicommand .. "\r\n"
            client:send(line)
            line = "privmsg " .. channel .. " :" .. ".tresja " .. aicommand .. "\r\n"
            client:send(line)
        end
        if command == "!mja" then
            line = "privmsg " .. channel .. " :" .. ".trjaes " .. aicommand .. "\r\n"
            client:send(line)
            line = "privmsg " .. channel .. " :" .. ".trjaen " .. aicommand .. "\r\n"
            client:send(line)
        end

        -- local command_line='user_input="' .. aicommand .. '";command="ollama run openhermes \"$user_input\"";eval "$command"'
        -- local output = os.capture(command_line,false)
        --print(output)
        --line = "privmsg " .. channel .. " :" .. output .. "\r\n"
        --client:send(line)
    end
end

while true do
    repeat
        --client:receive"*l"
        local chunk, err, partial = client:receive(1024)
        if chunk then
            buff = buff .. chunk
        elseif partial and #partial > 0 then
            buff = buff .. partial
        elseif err ~= "timeout" then
            if err == "closed" then
                print("errors from socket, closed, probably ping timeout:", err)
                print("exiting")
                os.exit(1)          
            end
        end

        -- Check for PING message
        --local ping_message = buff:match("^PING :(.+)")
        local ping_message = buff:match("PING :(.-)\n")
        if ping_message then
            print("PING received, responding with PONG pong message:" .. ping_message .. "end")
            
            line = "PONG :" .. ping_message .. "\r\n"
            client:send(line)

            -- Remove the PING message from the buffer
            buff=""
        end

        local lastChar = string.sub(buff, -1)
        if lastChar == "\n" then
            local before,after=getBeforeAndAfterSTring(buff,"PRIVMSG")
            if before then
                local friendnick=findLastNick(buff)
                --local friendnick,after=getBeforeAndAfterSTring(buffbuff,"!")
                if friendnick then
                    --local friendnick = string.sub(friendnick,2, #friendnick)
                    local _,message=getBeforeAndAfterSTring(buff,channel.." :")
                    if message then
                        local message=findLastMessage(buff,channel)
                        print("message from:"..friendnick..","..message)
                        --find command
                        local start, finish = string.find(message, "!askai")
                        comienzo, finish = string.find(message, "!dimeia")
                        lang="eng"
                        if start==1 or comienzo == 1 then
                            if comienzo == 1 then
                                lang="es"
                            end
                             --this tests to see is !askai is at the beginning of the string
                            --local _,aicommand=getBeforeAndAfterSTring(buff,nick)
                            local aicommand=nil
                            if lang == "eng" then
                                    _,aicommand=getBeforeAndAfterSTring(buff,"!askai")
                            else 
                                    _,aicommand=getBeforeAndAfterSTring(buff,"!dimeia")
                            end
                            aicommand=removeApostrophes(aicommand)
                            
                                --maybe make two commands !tellai !askai
                            if lang == "es" then
                                aicommand = "contesta es espaÃƒÂ±ol : resumeme lo siguiente  " .. stripCRLF(aicommand) .. " en 240 letras o menos en una sola linea"
                            else
                                aicommand = "answer in english : a summary  " .. stripCRLF(aicommand) .. " in 240 characters or less in one line"
                            end
                            print("aicommand:"..aicommand)
                            -- local command_line='user_input="' .. aicommand .. '";command="ollama run openhermes \"$user_input\"";eval "$command"'
                            -- local output = os.capture(command_line,false)
                            local r=nil
                            if obj1 ~= nil then
                                print("using previous context")
                                r=post("http://localhost:11434/api/generate",  '{"model": "openhermes","prompt": "' .. aicommand .. '","stream": false, "context": ' .. tabstring .. '}')    
                            else
                                print("new context")
                                r=post("http://localhost:11434/api/generate",  '{"model": "openhermes","prompt": "' .. aicommand .. '","stream": false}')
                            end
                            print(r)
                            obj1=JSON.decode(r)
                            context=obj1["context"]
                            tabstring="["
                            local n=1
                            for k,v in pairs(context) do
                                n=n+1
                                tabstring=tabstring..tostring(v)
                                if n<#context+1 then
                                    tabstring=tabstring..","
                                end        
                            end
                            tabstring=tabstring.."]"
                            print(tabstring)
                            --local obj1 = json.decode(r)
                            line = "privmsg " .. channel .. " :" .. obj1["response"] .. "\r\n"
                            client:send(line)
                        end
                        local start, finish = string.find(message, "!tellai")
                        if start==1 then --this tests to see is !tellai is at the beginning of the string
                            --local _,aicommand=getBeforeAndAfterSTring(buff,nick)
                            local _,aicommand=getBeforeAndAfterSTring(buff,"!tellai")
                            aicommand=removeApostrophes(aicommand)
                            --maybe make two commands !tellai !askai
                            aicommand = stripCRLF(aicommand)
                            print("aicommand:"..aicommand)
                            local r=nil
                            if obj1 ~= nil then
                                print("using previous context")
                                r=post("http://localhost:11434/api/generate",  '{"model": "openhermes","prompt": "' .. aicommand .. '","stream": false, "context": ' .. tabstring .. '}')    
                            else
                                print("new context")
                                r=post("http://localhost:11434/api/generate",  '{"model": "openhermes","prompt": "' .. aicommand .. '","stream": false}')
                            end
                            print(r)
                            obj1=JSON.decode(r)
                            context=obj1["context"]
                            tabstring="["
                            local n=1
                            for k,v in pairs(context) do
                                n=n+1
                                tabstring=tabstring..tostring(v)
                                if n<#context+1 then
                                    tabstring=tabstring..","
                                end        
                            end
                            tabstring=tabstring.."]"
                            print(tabstring)
                            --local obj1 = json.decode(r)
                            line = "privmsg " .. channel .. " :" .. obj1["response"] .. "\r\n"
                            client:send(line)
                            -- local command_line='user_input="' .. aicommand .. '";command="ollama run openhermes \"$user_input\"";eval "$command"'
                            -- local output = os.capture(command_line,false)
                            --print(output)
                            --line = "privmsg " .. channel .. " :" .. output .. "\r\n"
                            --client:send(line)
                        end
                        local start, finish = string.find(message, "!reboot")
                        if start==1 then --this tests to see is !reboot is at the beginning of the string
                                os.execute("resurection")
                        end
                        local start, finish = string.find(message, "!feliz cumpleaÃƒÂ±os")
                        if start==1 then --this tests to see is !tellai is at the beginning of the string
                            line = "privmsg " .. channel .. " : feliz cumpleaÃƒÂ±os zcom, de cosmicadventure y amigojapan! https://www.youtube.com/watch?v=cDT12zAWDuM \r\n"
                            client:send(line)
                        end
                        translate(message,"!men")
                        translate(message,"!mes")
                        translate(message,"!mja")
                        buff=""
                    end 
                end
                afterEnter="not entered"
            end
        end    
    until not chunk
end
