require './../globals'

Projectile = GameObject:extend()

function Projectile:new(area,x,y,opts)
    Projectile.super.new(self,area,x,y,opts)
    
    self.projectile_size_multiplier = opts.projectile_size_multiplier or 1
    self.s = opts.s or 2.5 * self.projectile_size_multiplier
    self.v = opts.v or 200
    self.multiplier = opts.multiplier or 1
    self.v = self.v * self.multiplier

    self.staticX = self.x
    self.staticY = self.y
    -- Define the laser offset distance
    self.offsetDistance = 20 -- Adjust this to set how far ahead the laser starts

    -- Calculate the offset using the angle (self.r)
    self.offsetX = math.cos(self.r) * self.offsetDistance
    self.offsetY = math.sin(self.r) * self.offsetDistance
    
    self.damage = 100

    self.color = attacks[self.attack].color

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    self.collider:setCollisionClass('Projectile')

    if current_room.player.projectile_ninety_degree_change then
        self.timer:after(0.2/current_room.player.angle_change_frequency_multiplier, function() 
            self.ninety_degree_direction = table.random({-1,1})
            self.r = self.r + self.ninety_degree_direction*math.pi/2
            self.timer:every('ninety_degree_second', 0.1/current_room.player.angle_change_frequency_multiplier, function()
                self.r = self.r - self.ninety_degree_direction*math.pi/2
                self.ninety_degree_direction = -1*self.ninety_degree_direction
            end)
        end)
    end

    if current_room.player.projectile_random_degree_change then
        self.timer:after(0.2/current_room.player.angle_change_frequency_multiplier, function() 
            self.random_degree_direction = table.random({-1,1})
            self.r = self.r + self.random_degree_direction*random(0,math.pi)
            self.timer:every('random_degree_change', 0.1/current_room.player.angle_change_frequency_multiplier, function() 
                self.r = self.r - self.random_degree_direction*random(0,math.pi)
            end)
        end)
    end

    if current_room.player.wavy_projectiles then
        local direction = table.random({-1,1})

        self.timer:tween(0.25, self, {r = self.r + direction*((math.pi/8)*current_room.player.projectile_waviness_multiplier)}, 'linear', function() 
            self.timer:tween(0.25, self, {r = self.r - direction*((math.pi/4)*current_room.player.projectile_waviness_multiplier)}, 'linear')
        end)
        
        self.timer:every(0.75, function() 
            self.timer:tween(0.25, self, {r = self.r + direction*((math.pi/4)*current_room.player.projectile_waviness_multiplier)}, 'linear', function() 
                self.timer:tween(0.5, self, {r = self.r - direction*((math.pi/4)*current_room.player.projectile_waviness_multiplier)}, 'linear')
            end)
        end)
    end

    if current_room.player.fast_slow then
        local initial_v = self.v
        self.timer:tween('fast_slow_first', 0.2, self, {v = 2*initial_v}, 'in-out-cubic', function() 
            self.timer:tween('fast_slow_second', 0.3, self, {v = initial_v/(2*current_room.player.projectile_deceleration_mulitplier)}, 'linear')
        end)
    end

    if current_room.player.slow_fast then
        local initial_v = self.v
        self.timer:tween('slow_fast_first', 0.2, self, {v = initial_v/2}, 'in-out-cubic', function() 
            self.timer:tween('slow_fast_second', 0.3, self, {v = 2*initial_v*current_room.player.projectile_acceleration_multiplier}, 'linear')
        end)
    end

    if self.attack == 'Blast' then 
        self.damage = 75
        self.color = table.random(negative_colors)
        if not self.shield then
            self.timer:tween(random(0.4,0.6), self, {v = 0}, 'linear', function() 
                self:die()
            end)
        end
    end

    if self.attack == 'Spin' then
        self.rv = table.random({random(-2*math.pi, -math.pi), random(math.pi, 2*math.pi)})
        self.timer:after(random(2.4,3.2), function() self:die() end)
        self.timer:every(0.05, function() 
            self.area:addGameObject('ProjectileTrail', self.x, self.y,
            {r = Vector(self.collider:getLinearVelocity()):angleTo(),
            color = self.color, s = self.s})
        end)
    end

    if self.attack == 'Flame' then
        self.damage = 50
        if not self.shield then
            self.timer:tween(random(0.6,1), self, {v = 0}, 'linear', function() 
                self:die()
            end)
        end
        self.timer:every(0.05, function() 
            self.area:addGameObject('ProjectileTrail', self.x, self.y,
            {r = Vector(self.collider:getLinearVelocity()):angleTo(),
            color = self.color, s = self.s})
        end)
    end

    if self.shield then
        self.orbit_distance = random(32,64)
        self.orbit_speed = random(-6,6)
        self.orbit_offset = random(0, 2*math.pi)
        self.timer:after(6, function() self:die() end)

        self.invisible = true
        self.timer:after(0.05, function() self.invisible = false end)
    end

    self.previous_x, self.previous_y = self.collider:getPosition()


end

function Projectile:update(dt)
    Projectile.super.update(self,dt)
    -- print(self.offsetX)
    print(self.offsetX + self.staticX)
    self.offsetX = math.cos(self.r) * self.offsetDistance
    self.offsetY = math.sin(self.r) * self.offsetDistance
    -- self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    
    if self.bounce and self.bounce > 0 then
        if self.x < 0 then
            self.r = math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.y < 0 then
            self.r = 2*math.pi - self.r
            self.bounce = self.bounce - 1
        end
        if self.x > gw then
            self.r = math.pi - self.r
            self.bounce = self.bounce -1
        end
        if self.y > gh then
            self.r = 2*math.pi - self.r
            self.bounce = self.bounce -1
        end
    else
        if self.x < 0 then self:die() end
        if self.y < 0 then self:die() end
        if self.x > gw then self:die() end
        if self.y > gh then self:die() end
    end

    if self.x < 0 or self.y < 0 or self.x > gw or self.y > gh then
        if self.attack == '2Split' or self.attack == '4Split' then
            local d = 1.2*12
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi + math.pi/4) , self.y + 1.5*d*math.sin(self.r - math.pi + math.pi/4), {r = self.r -math.pi + math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi - math.pi/4) , self.y + 1.5*d*math.sin(self.r - math.pi - math.pi/4), {r = self.r - math.pi - math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
        end
    end

    --Homing attack
    if self.attack == 'Homing' then
        if not self.target then
            local targets = self.area:getAllGameObjectsThat(function (e) 
                for _, enemy in ipairs(enemies) do
                    if e:is(_G[enemy]) and (distance(e.x,e.y,self.x,self.y) < 400) then
                        return true
                    end
                end
            end)

            self.target = table.remove(targets, love.math.random(1, #targets))
        end

        if self.target and self.target.dead then self.target = nil end

        if self.target then
            local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
            local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
            local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
            local final_heading = (projectile_heading + 0.1*to_target_heading):normalized()
            self.collider:setLinearVelocity(self.v*final_heading.x,self.v*final_heading.y)
        end
    else self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r)) end
    
    if self.attack == 'Spin' then
        self.r = self.r + self.rv*dt
    end

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local object = collision_data.collider:getObject()

        local d = 1.2*12

        if self.attack == '2Split' then
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/4) , self.y + 1.5*d*math.sin(self.r + math.pi/4), {r = self.r + math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/4) , self.y + 1.5*d*math.sin(self.r - math.pi/4), {r = self.r - math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
        end

        if self.attack == '4Split' then
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + math.pi/4) , self.y + 1.5*d*math.sin(self.r + math.pi/4), {r = self.r + math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi/4) , self.y + 1.5*d*math.sin(self.r - math.pi/4), {r = self.r - math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
        
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi + math.pi/4) , self.y + 1.5*d*math.sin(self.r - math.pi + math.pi/4), {r = self.r - math.pi + math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r - math.pi - math.pi/4) , self.y + 1.5*d*math.sin(self.r - math.pi - math.pi/4), {r = self.r - math.pi - math.pi/4, attack = 'Neutral', multiplier = current_room.player.pspd_multiplier.value, projectile_size_multiplier = current_room.player.projectile_size_multiplier, color = ammo_color})
        end

        if self.attack == 'Explode' then
            self.area:addGameObject('ExplodeEffect', self.x, self.y, {color = hp_color, w=30*self.s})
        end

        if not object then return end

        -- if object:is(Rock) then
        --     object:hit(self.damage)
        --     self.dead = true
        -- end

        -- if object:is(Shooter) then
        --     object:hit(self.damage)
        --     self.dead = true
        -- end


        if self.attack == 'Explode' then 
            local test = self.area:queryCircleArea(self.x,self.y, (30*self.s)/2, {"Rock","Shooter"})

            for k,v in ipairs(test) do
                if v then
                    v:hit(self.damage)
                    self.dead = true
                    if v.hp <= 0 then current_room.player:onKill() end
                end
            end
        elseif object then
            object:hit(self.damage)
            self.dead = true
            if object.hp <= 0 then current_room.player:onKill() end
        end
    end

    if self.shield then
        local player = current_room.player
        self.collider:setPosition(
            player.x + self.orbit_distance*math.cos(self.orbit_speed*time + self.orbit_offset),
            player.y + self.orbit_distance*math.sin(self.orbit_speed*time + self.orbit_offset))
        local x,y = self.collider:getPosition()
        local dx,dy = x - self.previous_x, y -self.previous_y
        self.r = Vector(dx,dy):angleTo()    
    end

    self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:draw()    
    if self.invisible then return end
    pushRotate(self.x,self.y, Vector(self.collider:getLinearVelocity()):angleTo())
    love.graphics.setLineWidth(self.s - self.s/4)
    if(self.attack == 'Spread') then
        love.graphics.setColor(love.math.colorFromBytes(table.random(all_colors)))
    else
        love.graphics.setColor(love.math.colorFromBytes(default_color))
    end

    if self.attack == 'Bounce' then
        love.graphics.setColor(love.math.colorFromBytes(table.random(default_colors)))
    end

    if(self.attack == 'Homing') then
        love.graphics.setColor(love.math.colorFromBytes(default_color))
        self.area:addGameObject('TrailParticle', self.x, self.y, {parent = self, r = random(2,4), d = random(0.15,0.25), color = skill_point_color})
        Draft:rhombus(self.x,self.y ,self.s*3.5,self.s*3.5,'fill')
    elseif self.attack == 'Explode' then
        love.graphics.setColor(love.math.colorFromBytes(default_color))
        self.area:addGameObject('TrailParticle', self.x, self.y, {parent = self, r = random(2,4), d = random(0.15,0.25), color = hp_color})
        Draft:rhombus(self.x,self.y ,self.s*4,self.s*4,'fill')
    elseif self.attack == '2Split' then
        love.graphics.setColor(love.math.colorFromBytes(default_color))
        self.area:addGameObject('TrailParticle', self.x , self.y , {parent = self, r = random(1.5,3), d = random(0.15,0.25), color = ammo_color})
        Draft:rhombus(self.x,self.y ,self.s*2.5,self.s*2.5,'fill')
    elseif self.attack == '4Split' then
        love.graphics.setColor(love.math.colorFromBytes(default_color))
        self.area:addGameObject('TrailParticle', self.x, self.y, {parent = self, r = random(1.5,3), d = random(0.15,0.25), color = boost_color})
        Draft:rhombus(self.x,self.y ,self.s*2.5,self.s*2.5,'fill')
    elseif self.attack == 'Laser' then
        
    else
        love.graphics.line(self.x - 2*self.s, self.y, self.x, self.y)
        love.graphics.setColor(love.math.colorFromBytes(self.color))
        love.graphics.line(self.x, self.y, self.x + 2*self.s, self.y)
    end
    love.graphics.setLineWidth(1)
    love.graphics.pop()


    pushRotate(self.staticX,self.staticY, Vector(self.collider:getLinearVelocity()):angleTo())
    if self.attack == 'Laser' then
        love.graphics.setColor(love.math.colorFromBytes(default_color))
        love.graphics.setLineWidth(7)
        love.graphics.line(self.staticX + self.offsetX, self.staticY +self.offsetY, self.staticX+500, self.staticY )
        love.graphics.setLineWidth(1)
    end
    love.graphics.pop()
end

function Projectile:die()
    self.dead = true
    if self.attack == 'Explode' then
        self.area:addGameObject('ExplodeEffect', self.x, self.y, {color = hp_color, w=30*self.s})
    else
        self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = hp_color, w=3*self.s})
    end

end
