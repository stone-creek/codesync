-------------------------------------------------------------------------------
Events = {}
Events['OnItemUse'] = 1
Events['OnEverySecond'] = 2
Events['OnEveryMinute'] = 3
Events['OnAddMesh'] = 4
Events['OnLoad'] = 5
Events['OnHover'] = 6
Events['OnUseWeapon'] = 7
Events['OnClick'] = 8
Events['OnRun'] = 9
-------------------------------------------------------------------------------
Game = {}
Game.Print = function(message)
    -- print("GAMEPRINT:" .. message)
end
Game.InFrontOf = function(player,x,y)
    return 1,2,3,4
end
Game.Menu = function(player,item,options)
end
Game.SubscribeTo = function(event,callback)
    callback()
end
-------------------------------------------------------------------------------
Zombies = {}
Zombies.Create = function() 
end
-------------------------------------------------------------------------------
NPCs = {}
NPCs.Create = function() 
end
-------------------------------------------------------------------------------
Notifications = {}
Notifications.Create = function()
end
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
Players.PopHover = function(player, object, message1, message2, message3)
end
Players.BuildingMode = function(player)
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
WorldItems = {}
WorldItems.Property = function() 
end
WorldItems.Count = function(class)
    return 0
end
WorldItems.ReactsTo = function(object,event,callback) 

    if event == nil then
        print("ERROR: event cant be nil, add to Events[] above.")
        return
    end

    if event == Events.OnEverySecond then 
        -- print("Testing OnEverySecond")
        callback()
    elseif event == Events.OnEveryMinute then 
        -- print("Testing OnEveryMinute")
        callback()
    elseif event == Events.OnItemUse then 
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
WorldItems.Get = function(object,variable)
    return nil
end
WorldItems.At = function(class,pos)
    return nil
end
WorldItems.NearestAt = function(x,y,z)
    return "nearest-item-at"
end
WorldItems.ClassOf = function(object)
    return "class-of-item"
end
-------------------------------------------------------------------------------