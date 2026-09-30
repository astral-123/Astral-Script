loadstring(game:HttpGet("https://raw.githubusercontent.com/astral-123/loader/refs/heads/main/.lua"))()

local playersService = game:GetService("Players")
local localPlayer = playersService.LocalPlayer

local WATCHED = {
	"request", "http_request", "httpget", "HttpGet",
	"http.request", "syn.request", "fluxus.request",
}

local function resolve(path)
	local target = getgenv()
	for part in path:gmatch("[^%.]+") do
		if type(target) ~= "table" then return nil end
		target = rawget(target, part)
	end
	return target
end

local function isTampered(func)
	if type(func) ~= "function" then return false end
	if islclosure(func) or isexecutorclosure(func) or isnewcclosure(func) then return true end
	return isfunctionhooked(func)
end

local function scan()
	for _, path in ipairs(WATCHED) do
		if isTampered(resolve(path)) then return path end
	end

	local meta = getrawmetatable(game)
	local namecall = rawget(meta, "__namecall")
	if isnewcclosure(namecall) or isfunctionhooked(namecall) then return "__namecall" end

	return nil
end

task.spawn(function()
	while task.wait(1) do
		local hit = scan()
		if hit then
			localPlayer:Kick("HTTP logger detected: " .. hit)
			break
		end
	end
end)
