--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    local key_spawned = false
    local lock_spawned = false

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        if x == width then
            tileID = TILE_ID_GROUND
            for y = 8, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 8 and topper or nil, tileset, topperset))
            end
        end
        -- chance to just be emptiness except for the starting position
        if x ~= 1 and math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil
            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 then
                -- if the key has already been spawned, spawn a lock
                if key_spawned and not lock_spawned then
                    table.insert(objects,
                        GameObject {
                            texture = 'keys-n-locks',
                            x = (x - 1) * TILE_SIZE,
                            y = (blockHeight - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            frame = math.random(5, #LOCK_IDS),
                            collidable = true,
                            solid = true,
                            consumable = true,
                            
                            onCollide = function(player, obj, k)
                                if player.key then
                                    gSounds['pickup']:play()
                                    player.score = player.score + 100
                                    player.key = false
                                    player.flag = true
                                    table.remove(player.level.objects, k)

                                    -- spawn a flag pole
                                    table.insert(player.level.objects,
                                        GameObject {
                                            texture = 'flags',
                                            x = (width - 1) * TILE_SIZE,
                                            y = (7 - 4) * TILE_SIZE,
                                            width = 16,
                                            height = 48,
                                            frame = math.random(#FLAGS_IDS),
                                            collidable = true,
                                            consumable = true,
                                            solid = true,
                                            
                                            onCollide = function(player, object)
                                                if player.flag then
                                                    gSounds['pickup']:play()
                                                    player.score = player.score + 100
                                                    player.flag = false
                                                    player.win = true
                                                    gStateMachine:change('nextlevel', {
                                                        score = player.score,
                                                        level = player.levelIncrement + 1
                                                    })
                                                end
                                            end
                                        }
                                    )
                                    -- spawn a flag
                                    local flag = Entity {
                                        texture = 'flag_tops',
                                        x = (width - 1.5) * TILE_SIZE,
                                        y = (7 - 4) * TILE_SIZE,
                                        width = 16, height = 16,
                                        stateMachine = StateMachine {
                                            ['idle'] = function() return PoleIdleState() end
                                        }
                                    }
                                    flag:changeState('idle', {flag = flag})
                                    table.insert(player.level.entities, flag) 
                                end
                            end
                        }
                    )
                    lock_spawned = true
                else
                     -- 4/5 chance to spawn gem
                     if math.random(5) ~= 1 then
                        table.insert(objects,

                        -- jump block
                        GameObject {
                            texture = 'jump-blocks',
                            x = (x - 1) * TILE_SIZE,
                            y = (blockHeight - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- make it a random variant
                            frame = math.random(#JUMP_BLOCKS),
                            collidable = true,
                            hit = false,
                            solid = true,

                            -- collision function takes itself
                            onCollide = function(obj)

                                -- spawn a gem if we haven't already hit the block
                                if not obj.hit then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)

                                    obj.hit = true
                                end
                                gSounds['empty-block']:play()
                            end
                        }
                    )
                    elseif not key_spawned then
                        table.insert(objects,
                       
                        -- jump block
                        GameObject {
                            texture = 'jump-blocks',
                            x = (x - 1) * TILE_SIZE,
                            y = (blockHeight - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- make it a random variant
                            frame = math.random(#JUMP_BLOCKS),
                            collidable = true,
                            hit = false,
                            solid = true,

                            -- collision function takes itself
                            onCollide = function(obj)

                                -- spawn a key if we haven't already hit the block
                                if not obj.hit then

                                    -- maintain reference so we can set it to nil
                                    local key = GameObject {
                                        texture = 'keys-n-locks',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#KEY_IDS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- key has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                            player.key = true
                                        end
                                    }
                                    
                                    -- make the key move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [key] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, key)

                                    obj.hit = true
                                end
                                gSounds['empty-block']:play()
                            end
                        }
                        )
                        key_spawned = true
                    end
                end
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles
    
    return GameLevel(entities, objects, map)
end

-- function LevelMaker.placeKey(objects)
--     local blocks = {}
--     for k, object in pairs(objects) do
--         if object.texture == 'jump-block'  then
--             table.insert(blocks, objects)
--         end
--     end
--     -- retrieve the legth of blocks
--     local len = #blocks
--     for k = 1, len do
--         if len % 2 == 0 then
            
--         else
--             if 
--         end
--     end
-- end