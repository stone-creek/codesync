-------------------------------------------------------------------------------
Game = {}
Game.Print = function(message)
    -- print("GAMEPRINT:" .. message)
end
Game.InFrontOf = function(player,x,y)
    return 1,2,3
end
-------------------------------------------------------------------------------
Players = {}
Players.Count = function()
    return 2
end
Players.RemoveFromInventory = function(player,inventory)
    return true
end
-------------------------------------------------------------------------------
Effects = {}
Effects.Fire = function(item,enable)
end
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
-------------------------------------------------------------------------------