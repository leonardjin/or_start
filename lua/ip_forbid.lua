local redis = require("resty.redis")
local conn = redis:new()
conn:set_timeout(10000)

local redis_ip = "127.0.0.1"
local redis_port = 6379

local ok , err = conn:connect(redis_ip,redis_port)
if not ok then
    ngx.say("connect to redis fatal error: " ,err)
    return redis_close(conn)
end

-- ngx.exit(ngx.ERR) 客户端无法返回

local ttl = 60 -- key过期时间
local top_times = 10
local forbit_ttl = 100 --60内无法再次访问
local ip = ngx.var.remote_addr
local ip_total_times = conn:get(ip)

ngx.say("debug...................................." , conn:ttl(ip))
ngx.say("debug...................................." , ip)


if ip_total_times ~= ngx.null then
    if (ip_total_times == "-1") then
        return ngx.exit(403)
    else
        this_ttl = conn:ttl(ip)
        
        if (this_ttl == -1) then --没有设置超时时间
            conn:set(ip,0)
            conn:expire(ip,ttl)
            return ngx.exit(ngx.OK)
        end
        v_times = tonumber(conn:get(ip)) + 1
        
        if (v_times > top_times) then
            
            conn:set(ip,-1)
            conn:expire(ip,forbit_ttl)
            return ngx.exit(ngx.OK)
        else
            print("debug 03")
            conn:set(ip,v_times)
            
            conn:expire(ip,this_ttl) -- 不要重新计时 
            return ngx.exit(ngx.OK)

        end     

        
    end
else
    print("key is not exists")
    conn:set(ip,1)
    conn:expire(ip,ttl)
    return ngx.exit(ngx.OK) --step done，如access_by_lua_file模块此处后，进入到content_by_lua_file模块处理
end
