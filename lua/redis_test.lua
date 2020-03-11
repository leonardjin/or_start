local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000)

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
        ngx.say("failed to connect: ", err)
        return
end

ngx.say("set result: ", ok)

local res, err = red:get("key")
if type(res) == 'string' then 
    ngx.say("to number is ", tonumber(res))
end
if not res then
        ngx.say("failed to get doy: ", err)
        return
end

if res == ngx.null then
        ngx.say("dog not found.")
        return
end

ngx.say("dog: ", res)
