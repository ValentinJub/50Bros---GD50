--[[
    GD50
    Super Mario Bros. Remake

    -- Flag Class --

    Author: Valentin Wissler 
]]

Flag = Class{__includes = Entity}

function Flag:init(def)
    Entity.init(self, def)
end

function Flag:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.currentAnimation:getCurrentFrame()],
        math.floor(self.x) + 8, math.floor(self.y) + 8)
end