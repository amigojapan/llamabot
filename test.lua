local http = require("socket.http")
local ltn12 = require"ltn12"
local body = {}

local JSON = require("./json")

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
--r=post("http://localhost:11434/api/generate",  '{"model": "llama2","prompt": "summarise this: What color is the sky at different times of the day? in 240 characters in one line","stream": false}')
--r='{"model":"llama2","created_at":"2024-02-06T11:12:23.402836943Z","response":" Happy Birthday! 🎉 You\'re another year older, wiser and more amazing! May your day be filled with love, laughter and endless adventures. 🎂","done":true,"context":[518,25580,29962,3532,14816,29903,29958,5299,829,14816,29903,6778,13,13,29874,15837,259,1809,9796,12060,3250,297,29871,29906,29946,29900,4890,470,3109,297,697,1196,518,29914,25580,29962,13,28569,350,7515,3250,29991,29871,243,162,145,140,887,29915,276,1790,1629,9642,29892,281,7608,322,901,21863,292,29991,2610,596,2462,367,10423,411,5360,29892,10569,357,322,1095,2222,17623,1973,29889,29871,243,162,145,133],"total_duration":12712376468,"load_duration":272348,"prompt_eval_duration":509404000,"eval_count":45,"eval_duration":12193442000}'
--context=JSON.(r) 
--print(obj1["response"])
context={}--[518,25580,29962,3532,14816,29903,29958,5299,829,14816,29903,6778,13,13,29874,15837,259,590,1024,338,626,5973,297,29871,29906,29946,29900,4890,470,3109,297,697,1196,518,29914,25580,29962,13,3421,1024,29901,1913,5973]
context[1]=518
context[2]=25580
context[3]=29962
local tabstring="["
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