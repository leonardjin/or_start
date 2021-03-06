--  get the config shared key
local ip_blacklist = ngx.shared.ip_blacklist


local cache_ttl  = 60

local ip = ngx.var.remote_addr 
local redis_key = 'ip_blacklist'
local redis_timeout = 1000
local last_update_time = ip_blacklist.get("last_update_time")

if last_update_time == nil or ( ngx.now() - last_update_time) > cache_ttl then
    local redis = require "resty.redis"
    local red = redis:new()
    red:set_timeout(redis_timeout)
    local ok, err = red:connect("127.0.0.2", 6379)
    if not ok then
            ngx.say("failed to connect: ", err)
            ngx.log(ngx.DEBUG, "failed to connect: "..err)
            return
    end
    
ngx.say("set result: ", ok)

local res, err = red:get("dog")
if not res then
        ngx.say("failed to get doy: ", err)
        return
end

if res == ngx.null then
        ngx.say("dog not found.")
        return
end

ngx.say("dog: ", res)
