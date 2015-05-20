--[[
Provides custom authorization for nginx.
See the `nginx_authorize_by_lua.conf` for the Nginx config. This lua file is referenced in the config
See testWebserverAccess.sh for unit tests.

To Run nginx (make sure you have the lua, config and htpasswd file):
$ /usr/local/openresty/nginx/sbin/nginx -c /etc/nginx/conf/nginx_authorize_by_lua.conf

Logs are available at: /usr/local/openresty/nginx/logs/lua.log
To write to the log:
ngx.log(ngx.DEBUG, user) -- Write user to log
]]--

-- Authorization rules
-- This grants rights to a user
-- Usage: $username = "$group"
local userGroups = {
	user = "user",
	dev = "dev",
	admin = "admin",
	bob = "user",
	alice = "user",
	logAdmin = "adminOfLogs"
}

-- Provides group access rights
-- Usage:
-- $GROUP = { ["$URL_REGEX"] = { "$HTTP_METHOD", "$HTTP_METHOD" } }
local restrictions = {
  user = {
	["^/monitor*"]			= { "HEAD", "GET" },
	["^/kibana4*"]			= { "HEAD", "GET", "PUT", "POST"  } -- Note: I believe you may need more permissions than this to use Kibana. Todo.
  },
  
  dev = {
	["^/monitor*"]			= { "HEAD", "GET", "PUT", "POST" },
	["^/log*"]			= { "HEAD", "GET", "PUT", "POST" },
	["^/kibana4*"]			= { "HEAD", "GET", "PUT", "POST"  }
  },

  admin = {
  	["^/*"]               		= { "HEAD", "GET", "POST", "PUT", "DELETE" }
  },

  adminOfLogs = {
    ["^/log*"]				= { "HEAD", "GET", "POST", "PUT", "DELETE" }
  }
}

-- Write 403 message function
function write403Message ()
  ngx.header.content_type = 'text/plain'
  ngx.status = 403
  ngx.say("403 Forbidden: You don\'t have access to this resource.")
  return ngx.exit(403)
end

-- get authenticated user as role
local user = ngx.var.remote_user	-- Get user
local role = userGroups[user]		-- Get group

-- exit 403 when no matching role has been found
if restrictions[role] == nil then
  return write403Message()
end

-- get URL
local uri = ngx.var.uri

-- get method
local method = ngx.req.get_method()

local allowed  = false

for path, methods in pairs(restrictions[role]) do
  -- path matched rules?
  local p = string.match(uri, path)

  -- method matched rules?
  local m = nil
  for _, _method in pairs(methods) do
    m = m and m or string.match(method, _method)
  end

  if p and m then
    allowed = true
    break
  end
end

if not allowed then
  return write403Message()
end
