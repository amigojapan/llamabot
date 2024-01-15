#!/usr/bin/lua
require "inkeylua"
require "helperFunctions"
--print("Welcome to voice internet relayed chat, press control plus C to quit")
socket = require("socket")

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
    return inputString
end

if(arg[1]) then
    nick = arg[1]
else    
    nick ="llamabot"
end
 
if(arg[2]) then
    channel = arg[2]
else    
    channel = "#BlindOE"
end

server = "irc.libera.chat"

client = socket.tcp()
client:connect(server, 6667)
client:settimeout(0)

user_input = ""
print("waiting 15 seconds for connect...\r\n server, " .. server .. " channel, " .. channel .. "")
socket.sleep(15) -- wait enough till logon

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
buffbuff=""
afterEnter="not entered"
userInputBefore=""
while true do
    buff, err = client:receive(1)
    local str=""
    if buff then
        buffbuff=buffbuff..buff
        str =string.sub(buff,#buff, #buff)
    end
    
    if str == "\n" then
        local before,after=getBeforeAndAfterSTring(buffbuff,"PRIVMSG")
        if before then
            local friendnick=findLastNick(buffbuff)
            --local friendnick,after=getBeforeAndAfterSTring(buffbuff,"!")
            if friendnick then
                --local friendnick = string.sub(friendnick,2, #friendnick)
                local _,message=getBeforeAndAfterSTring(buffbuff,channel.." :")
                if message then
                    local message=findLastMessage(buffbuff,channel)
                    print("message from:"..friendnick..","..message)
                    --find command
                    local start, finish = string.find(message, nick)
                    if start then
                        local _,aicommand=getBeforeAndAfterSTring(buffbuff,nick)
                        aicommand=removeApostrophes(aicommand)
                        aicommand = "a summary  " .. stripCRLF(aicommand) .. " in 240 characters or less in one line"
                        print("aicommand:"..aicommand)
                        local command_line='user_input="' .. aicommand .. '";command="ollama run llama2 \"$user_input\"";eval "$command"'
                        local output = os.capture(command_line,false)
                        print(output)
                        line = "privmsg " .. channel .. " :" .. output .. "\r\n"
                        client:send(line)
                    end
                    buffbuff=""
                end 
            end
            afterEnter="not entered"
        end
        --io.write(buff)
        -- Check for PING message
        local ping_message = buffbuff:match("^PING :(.+)")
        if ping_message then
            print("PING received, responding with PONG")
            line = "PONG :" .. ping_message .. "\r\n"
            client:send(line)
            socket.sleep(2)
            buffbuff=""
        end 
    end
        
    if not buff and err == "timeout" then
        -- No data available from the socket, handle input
        socket.sleep(0.05) -- 50ms delay (20 checks per second)
        local key = inkey()
        if key then
            -- Handle user input here
            if key == '\x7f' then
                -- Backspace pressed
                user_input = user_input:sub(1, -2)
                print("")
                print(user_input)
            elseif key == '\n' then
                -- Enter pressed
                
                if afterEnter ~= "yes enter" then
                    print(user_input)
                    print("send? Y for yes, N for no")
                    userInputBefore=user_input
                    user_input=""
                    afterEnter="yes enter"
                end
                if afterEnter == "yes enter" then
                    --print("user_input:"..user_input)
                    if(string.lower(user_input)=="y") then
                        line = "privmsg " .. channel .. " :" .. userInputBefore .. "\r\n"
                        client:send(line)
                        --print("sending:", line)
                        socket.sleep(2)
                        user_input = ""
                        print("")
                        afterEnter = "no enter"
                        userInputBefore=""
                        print("sent")
                    elseif(string.lower(user_input)=="n") then
                        afterEnter = "no enter"
                        user_input=""
                        userInputBefore=""
                        print("cancelled")
                    end
                end
            else
                -- Alphanumeric key pressed
                user_input = user_input .. key
                io.write(key)
                io.flush()
            end
        end
    elseif not buff then
        -- A "real" error occurred
        print("error:" .. err)
        --print("exiting")
        --os.exit(1)
    end
end