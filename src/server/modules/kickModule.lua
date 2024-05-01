local kickModule = {}
local isStudio = game:GetService("RunService"):IsStudio();

kickModule.kick = function(player: Player, message: string|nil)
	if not isStudio then
		player:Kick(message or "met your time")
	else
		print("Would have kicked player",player,"for reason",message or "met your time")
	end
end

return kickModule