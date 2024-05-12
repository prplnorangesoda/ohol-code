local foodModule = {}

local Players = game:GetService("Players")

foodModule.createFoodItemFrom = function(foodItem: Tool, foodThirst, foodHunger)
	foodItem.Activated:Connect(function()
		local plr = Players:GetPlayerFromCharacter(foodItem.Parent)
		local statsFolder = plr.PlayerStats
		local plrHunger: NumberValue = statsFolder.Hunger
		local plrThirst: NumberValue = statsFolder.Thirst

		plrHunger.Value += foodHunger
		plrThirst.Value += foodThirst
		foodItem:Destroy()
	end)
	foodItem.ToolTip = "Hunger: "..foodHunger..", Thirst: "..foodThirst
end

return foodModule