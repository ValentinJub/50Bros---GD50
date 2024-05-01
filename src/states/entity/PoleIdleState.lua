--[[
    GD50
    Super Mario Bros. Remake

    Author: Valentin Wissler 
]]

PoleIdleState = Class{__includes = BaseState}

function PoleIdleState:init()
    self.animation = Animation {
        frames = {1,2,3},
        interval = 1
    }
end

function PoleIdleState:enter(params)
    self.flag = params.flag
    self.flag.currentAnimation = self.animation
end

function PoleIdleState:update(dt)
    self.flag.currentAnimation:update(dt)
end