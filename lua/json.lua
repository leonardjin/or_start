local cjson = require "cjson.safe"


local str = ngx.req.raw_header()

ngx.say("raw header is :"..str)

local headers = ngx.req.get_headers()
for k, v in pairs(headers) do
     ngx.say(k .. ":" .. v)
end

local uriargs= ngx.req.get_uri_args(0)
ngx.say("uri args ")
for k, v in pairs(uriargs) do
     ngx.say(k .. ":" .. v)
end

---- 
--
local method = ngx.req.get_method()
ngx.say('get method: '..method)


ngx.req.read_body()

local body_str = ngx.req.get_body_data()

ngx.say("get the body")

if not body_str then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local value, err = cjson.decode(body_str)

if not value then

    local value = ngx.req.get_post_args()

    -- value now is table 

    ngx.say("body is post data")

else
    ngx.say("body is post json")
    --ngx.say(value)
    ngx.say(value['id'])
    ngx.say(value.id)
end
