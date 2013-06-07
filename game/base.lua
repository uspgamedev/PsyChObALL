--mythical stuff
base = {}

--[[
	"Localizes" Love2D tables
]]
for k,v in pairs(love) do
	if type(v) == 'table' and not _G[k] then
		_G[k] = v
	end
end

--[[
	Used for modules.
	If you try to access a nil value, it will access the _G one.
	If you try to set a value that already exists on _G, it will be set there,
	otherwise, it will be created on the table
]]
function base.globalize( t )
	setmetatable(t, {
		__index = _G,
		__newindex = function ( t, k, v )
			if _G[k] ~= nil then _G[k] = v
			else rawset(t, k, v) end
		end
		})
end

local http = require "socket.http"

response = http.request{ url=URL, create=function()
	local req_sock = require("socket").tcp()
	req_sock:settimeout(3)
	return req_sock
end}

function base.getLatestVersion()
	return http.request("http://uspgamedev.org/downloads/projects/psychoball/latest")
end