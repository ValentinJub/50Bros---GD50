--[[
    GD50
    Super Mario Bros. Remake

    -- NextLevelState Class --

    Author: Valentin Wissler 
]]

NextLevelState = Class{__includes = BaseState}

function NextLevelState:init()
    self.transitionAlpha = 1
    -- start our level # label off-screen
    self.levelLabelY = -64
end

function NextLevelState:enter(params)
    self.score = params.score
    self.level = params.level
    self.background = math.random(3)
    self.map = LevelMaker.generate(100, 10)

    --
    -- animate our white screen fade-in, then animate a drop-down with
    -- the level text
    --

    -- first, over a period of 1 second, transition our alpha to 0
    Timer.tween(1, {
        [self] = {transitionAlpha = 0}
    })
    
    -- once that's finished, start a transition of our text label to
    -- the center of the screen over 0.25 seconds
    :finish(function()
        Timer.tween(0.25, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })
        
        -- after that, pause for one second with Timer.after
        :finish(function()
            Timer.after(1, function()
                
                -- then, animate the label going down past the bottom edge
                Timer.tween(0.25, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })
                
                -- once that's complete, we're ready to play!
                :finish(function()
                    gStateMachine:change('play', {
                        level = self.level,
                        score = self.score
                    })
                end)
            end)
        end)
    end)
end

function NextLevelState:update(dt)
    Timer.update(dt)
end

function NextLevelState:render()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    self.map:render()

    love.graphics.setFont(gFonts['title'])

    love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('Level ' .. tostring(self.level),
        0, self.levelLabelY, VIRTUAL_WIDTH, 'center')

    -- our transition foreground rectangle
    love.graphics.setColor(1, 1, 1, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    -- love.graphics.setColor(0, 0, 0, 255)
    -- -- print the level number
    -- love.graphics.printf('Level ' .. tostring(self.level), 1, VIRTUAL_HEIGHT / 2 - 40 + 1, VIRTUAL_WIDTH, 'center')
    -- love.graphics.setColor(255, 255, 255, 255)
    -- love.graphics.printf('Level ' .. tostring(self.level), 1, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')
end