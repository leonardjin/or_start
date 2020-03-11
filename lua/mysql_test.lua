local mysql = require "resty.mysql"
local db, err = mysql:new()

if not db then
        ngx.say("failed to instantiate mysql: ", err)
        return
end

db:set_timeout(1000)

local ok, err, errno, sqlstate = db:connect{
        host = "127.0.0.1",
        port = 3306,
        database = "test",
       -- user = "root",
       -- password="digdeep",
        max_packet_size = 1024 * 1024
}

if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
end

ngx.say("connected to mysql.")

local res, err, errno, sqlstate = db:query("drop table if exists cats")
if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
end

res, err, errno, sqlstate = db:query("create table cats " .. "(id int not null primary key auto_increment, "
                                        .. "name varchar(30))")
if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
end

ngx.say("table cats created.")

res, err, errno, sqlstate = db:query("insert into cats(name) " .. "values (\'Bob\'),(\'\'),(null)")
if not res then
        ngx.say("bad request: ", err, ": ", errno, ": ", sqlstate, ".")
        return
end

ngx.say(res.affected_rows, " rows inserted into table cats ", "(last insert id: ", res.insert_id, ")")

res, err, errno, sqlstate = db:query("select * from cats order by id asc", 10)
if not res then
        ngx.say("bad result ", err, ": ", errno, ": ", sqlstate, ".")
        return
end

local cjson = require "cjson"
ngx.say("result: ", cjson.encode(res))

local ok, err = db:set_keepalive(1000, 100)
if not ok then
        ngx.say("failed to set keepalive: ", err)
        return
end
