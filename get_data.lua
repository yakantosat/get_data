local DAB_ROOT = "/home/huangyuan/logs/DAB"
local OP = { "api4",
             "cdn_bandwidth",
             "total_bandwidth",
             "slow_ratio",
             "user_cv",
             'okapi4_ratio',
             'block_user_ratio', 
             'play_success_ratio',
             'saveratio',
             'fapi4_ratio'}

local result = {}

local TIME, i

function parser(dir, res)
    local f = io.open(dir)
    local t = f:read("*all")
    local tt, _ = string.gsub(t, "%(%%%)", "")
    for i, op in ipairs(OP) do
        local pattern = string.format("%s:%s", op, " ?[0-9.]+")
        k, j = string.find(tt, pattern)
        if k ~= nil and j ~= nil
        then
            --ngx.log(ngx.ERR, "Pattern: ", pattern, " ", k, " ", j)
            str = string.sub(tt, k, j)
            c, _ = string.gsub(str, " ", "")
            d, _ = string.gsub(c, "\n", "")
            table.insert(res, d)
        end
    end

    f:close()
end

i = 0
TIME = os.date("%Y%m%d%H%M")
local temp, YM, HM, mydir
local y = string.sub(TIME, 1, 4)
local m = string.sub(TIME, 5, 6)
local d = string.sub(TIME, 7, 8)
local h = string.sub(TIME, 9, 10)
local min = math.floor(tonumber(string.sub(TIME, 11, 12))/5)*5
local timestamp = os.time{year=y, month=m, day=d, hour=h, min=min}
while true do
    temp = os.date("%Y%m%d%H%M", tonumber(timestamp) - i*60)
    YM = string.sub(temp, 1, 8)
    HM = string.sub(temp, 9, 12)
    mydir = string.format("%s/%s/%s/pepper.log", DAB_ROOT, YM, HM)
    local f = io.open(mydir, "r")
    if f == nil then
        i = i + 5
        print(mydir .. " file is not existd!")
    else
        if f:read("*a") == "" then
            i = i + 5
            f:close()
            print("file's size is 0.")
        elseif f:seek("end") < 500 then
            i = i + 5
            f:close()
            print("file's size is less then 500")
        else
            --ngx.log(ngx.ERR, "The dir is: ", mydir)
            parser(mydir, result)
            print("Successful!")
            break
        end
    end
end

local r_string = {}
for k, v in ipairs(result) do
    r_string[#r_string + 1] = v .. ' '
end
local s = table.concat(r_string)
ngx.say(s)
