-------------------------------------------------------------------------------
Game = {}
Game.Print = function(message)
    -- print("GAMEPRINT:" .. message)
end
Game.InFrontOf = function(player,x,y)
    return 1,2,3,4
end
-------------------------------------------------------------------------------
Zombies = {}
Zombies.SpawnAt = function() end
-------------------------------------------------------------------------------
Players = {}
Players.Count = function()
    return 2
end
Players.EquipWeapon = function(player, weapon_info)
end
Players.FlashMessage = function(player, message)
end
Players.GetCoords = function(player)
    return {
        x = 1,
        y = 2,
        z = 3
    }
end
-------------------------------------------------------------------------------
Inventory = {}
Inventory.RemoveFrom = function(player,inventory)
    return true
end
Inventory.Count = function(player)
    return 1
end
Inventory.At = function(player,pos)
    return "random item guid" 
end
Inventory.ClassOf = function(player,item)
    return "random item class" 
end
-------------------------------------------------------------------------------
Effects = {}
Effects.Fire = function(item,enable) end
-------------------------------------------------------------------------------
Events = {}
Events['OnItemUse'] = 1
-------------------------------------------------------------------------------
WorldItems = {}
WorldItems.Property = function() 
end
WorldItems.ReactsTo = function(object,event,callback) 

    if event == Events.OnItemUse then 
        -- print("ONITEMUSE")
        callback("player","inventory","class")
    end

end
WorldItems.SpawnItemAt = function(class,x,y,z,rotation)
    return "spawned-item-guid-0001"
end
WorldItems.AddMeshTo = function(item,mesh,x,y,z,rotation)
    return "spawned-item-guid-0001"
end
WorldItems.Set = function(object,variable,table)
end
WorldItems.NearestAt = function(x,y,z)
    return "nearest-item-at"
end
WorldItems.ClassOf = function(object)
    return "class-of-item"
end
-------------------------------------------------------------------------------