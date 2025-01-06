Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.area.world:addCollisionClass('Player')
    self.area.world:addCollisionClass('Enemy')
    self.area.world:addCollisionClass('Projectile', {ignores = {'Projectile', 'Player'}})
    self.area.world:addCollisionClass('Collectable', {ignores = {'Collectable','Projectile'}})
    self.area.world:addCollisionClass('EnemyProjectile', {ignores = {'EnemyProjectile', 'Projectile', 'Enemy'}})
    self.timer = Timer()
    self.main_canvas = love.graphics.newCanvas(gw,gh)
    self.font = fonts.m5x7_16

    self.score = 0
    self.player = self.area:addGameObject('Player', gw/2, gh/2)
    self.timer:after(0.01, function () 
        self.director = Director(self)
    end)
    -- self.director = Director(self)
    input:bind('f2', function() self.player.dead = true end)
    input:bind('p', function() self.area:addGameObject('Ammo', random(0,gw), random(0,gh)) end)
    input:bind('h', function() self.area:addGameObject('Boost', random(0,gw), random(0,gh)) end)
    input:bind('z', function() self.area:addGameObject('Health', random(0,gw), random(0,gh)) end)
    input:bind('v', function() self.area:addGameObject('SkillPoint', random(0,gw), random(0,gh)) end)
    input:bind('x', function() self.area:addGameObject('AttackRessource', random(0,gw), random(0,gh)) end)
    input:bind('y', function() self.area:addGameObject('Rock', random(0,gw), random(0,gh)) end)
    input:bind('q', function() self.area:addGameObject('Shooter', random(0,gw), random(0,gh)) end)
end

function Stage:update(dt)
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    self.area:update(dt)
    self.timer:update(dt)
    -- self.director:update(dt)
    if self.director then
        self.director:update(dt)
    end
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        camera:attach(0,0,gw,gh)
        if self.area then self.area:draw() end
        camera:detach()

        love.graphics.setFont(self.font)

        --score
        love.graphics.setColor(love.math.colorFromBytes(default_color))
        love.graphics.print(self.score, gw-20, 10, 0, 1, 1, 
        math.floor(self.font:getWidth(self.score)/2), self.font:getHeight()/2)
        love.graphics.setColor(love.math.colorFromBytes(255,255,255))

        --sp
        love.graphics.setColor(love.math.colorFromBytes(skill_point_color))
        love.graphics.print('SP ' .. sp, 20, 10, 0, 1, 1, 
        math.floor(self.font:getWidth(self.score)/2), self.font:getHeight()/2)
        love.graphics.setColor(love.math.colorFromBytes(255,255,255))
    
        --hp
        local r,g,b = unpack(hp_color)
        local hp, max_hp = self.player.hp, self.player.max_hp
        love.graphics.setColor(love.math.colorFromBytes(r,g,b))
        love.graphics.rectangle('fill', gw/2 - 52, gh - 16, 48*(hp/max_hp), 4)
        love.graphics.setColor(love.math.colorFromBytes(r-32,g-32,b-32))
        love.graphics.rectangle('line', gw/2 - 52, gh -16, 48, 4)

        love.graphics.print('HP', gw/2 - 52 + 24, gh - 24, 0, 1, 1,
        math.floor(self.font:getWidth('HP')/2), math.floor(self.font:getHeight()/2))

        love.graphics.print(hp .. '/' .. max_hp, gw/2 - 52 + 24, gh - 6, 0, 1, 1,
        math.floor(self.font:getWidth(hp .. '/' .. max_hp)/2),
        math.floor(self.font:getHeight()/2))

        --ammo
        r,g,b = unpack(ammo_color)
        local ammo,max_ammo = self.player.ammo, self.player.max_ammo
        love.graphics.setColor(love.math.colorFromBytes(r,g,b))
        love.graphics.rectangle('fill', gw/2 - 52, 16, 48*(ammo/max_ammo), 4)
        love.graphics.setColor(love.math.colorFromBytes(r-32,g-32,b-32))
        love.graphics.rectangle('line', gw/2 - 52, 16, 48, 4)

        love.graphics.print('AMMO', gw/2 - 52 + 24, 16 + 12, 0, 1, 1,
        math.floor(self.font:getWidth('AMMO')/2), math.floor(self.font:getHeight()/2))

        love.graphics.print(ammo .. '/' .. max_ammo, gw/2 - 52 + 24, 16 - 10, 0,1,1,
        math.floor(self.font:getWidth(ammo .. '/' .. max_ammo)/2),
        math.floor(self.font:getHeight()/2))

        --boost gw/2 + 4, gh - 16
        r,g,b = unpack(boost_color)
        local boost,max_boost = math.floor(self.player.boost),self.player.max_boost
        love.graphics.setColor(love.math.colorFromBytes(r,g,b))
        love.graphics.rectangle('fill', gw/2 + 4, 16, 48*(boost/max_boost), 4)
        love.graphics.setColor(love.math.colorFromBytes(r-32,g-32,b-32))
        love.graphics.rectangle('line', gw/2 + 4, 16, 48, 4)

        love.graphics.print('BOOST', gw/2 + 4 + 24,16 + 12, 0, 1, 1,
        math.floor(self.font:getWidth('BOOST')/2), math.floor(self.font:getHeight()/2))

        love.graphics.print(boost .. '/' .. max_boost, gw/2 + 4 + 24, 16 - 10, 0,1,1,
        math.floor(self.font:getWidth(boost .. '/' .. max_boost)/2),
        math.floor(self.font:getHeight()/2))

        --cycle
        r,g,b = unpack(default_color)
        local cycle,cycle_cooldown,cycle_speed_multiplier = math.min(5,self.player.cycle_timer),self.player.cycle_cooldown,self.player.cycle_speed_multiplier.value
        love.graphics.setColor(love.math.colorFromBytes(r,g,b))
        love.graphics.rectangle('fill', gw/2 + 4, gh - 16, 48*(cycle/(cycle_cooldown/cycle_speed_multiplier)), 4)
        love.graphics.setColor(love.math.colorFromBytes(r-32,g-32,b-32))
        love.graphics.rectangle('line', gw/2 + 4, gh -16, 48, 4)

        love.graphics.print('CYCLE', gw/2 + 4 + 24, gh - 24, 0, 1, 1,
        math.floor(self.font:getWidth('CYCLE')/2), math.floor(self.font:getHeight()/2))
        

    love.graphics.setCanvas()

    love.graphics.setColor(love.math.colorFromBytes(default_color))
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas,0,0,0,sx,sy)
    love.graphics.setBlendMode('alpha')
end

function Stage:destroy()
    self.area:destroy()
    self.player = nil
    self.area = nil
end

function Stage:finish()
    timer:after(1, function() 
        gotoRoom('Stage')
    end)
end