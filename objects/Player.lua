require './../globals'

Player = GameObject:extend()

function Player:new(area,x,y,opts)
    Player.super.new(self,area,x,y,opts)

    self.x,self.y = x, y
    self.w,self.h = 12,12

    self.shoot_timer = 0
    self.shoot_cooldown = 0.24

    self.invincible = false
    self.invisible = false

    self.collider = self.area.world:newCircleCollider(self.x,self.y,self.w)
    self.collider:setObject(self)
    -- self.collider:setMass(0.1)
    self.collider:setCollisionClass('Player')

    self.ship = 'Fighter'
    self.polygons = {}


    -- self.inside_haste_area = false
    -- self.aspd_multiplier = self.pre_haste_aspd_multiplier
    -- self.pre_haste_aspd_multiplier = nil

    -- self.chances = {}

    --boost
    self.max_boost = 100
    self.boost = self.max_boost
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2
    self.boosting = false

    --hp
    self.max_hp = 100
    self.hp = self.max_hp

    --ammo
    self.max_ammo = 100
    self.ammo = self.max_ammo

    --cycle/tick
    self.cycle_timer = 0
    self.cycle_cooldown = 5

    --movement
    self.r = -math.pi/2
    self.rv = 1.66*math.pi
    self.v = 0
    self.base_max_v = 100
    self.max_v = self.base_max_v
    self.a = 100
    self.trail_color = skill_point_color

    --multipliers
    self.hp_multiplier = 1
    self.ammo_multiplier = 1
    self.boost_multiplier = 1
    self.luck_multiplier = 1
    self.hp_spawn_chance_multiplier = 1
    self.sp_spawn_chance_multiplier = 1
    self.boost_spawn_chance_multiplier = 1
    self.enemy_spawn_rate_multiplier = 1
    self.resource_spawn_rate_multiplier = 1
    self.attack_spawn_rate_multiplier = 1
    self.turn_rate_multiplier = 1
    self.boost_effectiveness_multiplier = 1
    self.projectile_size_multiplier = 1
    self.boost_recharge_rate_multiplier = 1
    self.invulnerability_time_multiplier = 1
    self.ammo_consumption_multiplier = 1
    self.size_multiplier = 1
    self.angle_change_frequency_multiplier = 1
    self.projectile_waviness_multiplier = 1
    self.projectile_acceleration_multiplier = 1
    self.projectile_deceleration_mulitplier = 1
    self.area_multiplier = 5

    self.additional_bounce_projectiles = 5

    self.aspd_multiplier = Stat(1)
    self.mvspd_multiplier = Stat(1)
    self.pspd_multiplier = Stat(1)
    self.cycle_speed_multiplier = Stat(1)

    --flats
    self.flat_hp = 0
    self.flat_ammo = 50
    self.flat_boost = 0

    self.ammo_gain = 30

    --passive vars
    self.invulnerability_while_boosting = true
    self.increased_cycle_speed_while_boosting = true
    self.increased_luck_while_boosting = true
    self.projectile_ninety_degree_change = false
    self.projectile_random_degree_change = false
    self.wavy_projectiles = false
    self.fast_slow = false
    self.slow_fast = false
    self.additional_lightning_bolt = true
    self.fixed_spin_attack_direction = true

    --chances
    self.split_projectiles_split_chance = 10
    self.launch_homing_projectile_on_ammo_pickup_chance = 20
    self.regain_hp_on_ammo_pickup_chance = 0
    self.regain_hp_on_sp_pickup_chance = 0
    self.spawn_haste_area_on_hp_pickup_chance = 10
    self.spawn_haste_area_on_sp_pickup_chance = 10
    self.spawn_sp_on_cycle_chance = 10
    self.barrage_on_kill_chance = 0
    self.spawn_hp_on_cycle_chance = 0
    self.regain_hp_on_cycle_chance = 0
    self.regain_full_ammo_on_cycle_chance = 0
    self.change_attack_on_cycle_chance = 0
    self.spawn_haste_area_on_cycle_chance = 0
    self.barrage_on_cycle_chance = 0
    self.launch_homing_projectile_on_cycle_chance = 0
    self.regain_ammo_on_kill_chance = 0
    self.launch_homing_projectile_on_kill_chance = 0
    self.regain_boost_on_kill_chance = 0
    self.spawn_boost_on_kill_chance = 0
    self.gain_aspd_boost_on_kill_chance = 0
    self.mvspd_boost_on_cycle_chance = 0
    self.pspd_boost_on_cycle_chance = 0
    self.pspd_inhibit_on_cycle_chance = 0
    self.launch_homing_projectile_while_boosting_chance = 0
    self.attack_twice_chance = 0
    self.spawn_double_hp_chance = 0
    self.spawn_double_sp_chance = 0
    self.gain_double_sp_chance = 100 
    self.drop_double_ammo_chance = 100
    self.shield_projectile_chance = 0

    self.w,self.h = 12*self.size_multiplier,12*self.size_multiplier

    
    if self.ship == 'Fighter' then
        self.polygons[1] = {
            self.w,0,
            self.w/2, -self.w/2,
            -self.w/2,-self.w/2,
            -self.w,0,
            -self.w/2,self.w/2,
            self.w/2,self.w/2,
        }

        self.polygons[2] = {
            self.w/2, -self.w/2,
            0, -self.w,
            -self.w - self.w/2, -self.w,
            -3*self.w/4, -self.w/4,
            -self.w/2, -self.w/2,
        }
        
        self.polygons[3] = {
            self.w/2, self.w/2,
            -self.w/2, self.w/2,
            -3*self.w/4, self.w/4,
            -self.w - self.w/2, self.w,
            0, self.w,
        }
    elseif self.ship == 'Big Hunter' then
        self.polygons[1] = {
            self.w,0,
            self.w/2, -self.w/2,
            -self.w,-self.w/2,
            -self.w/2,0,
            -self.w,self.w/2,
            self.w/2,self.w/2,
        }
    elseif self.ship == 'Crusader' then
        self.polygons[1] = {
            self.w,0,
            self.w/2, -self.w/2,
            -self.w/2,-self.w/2,
            -self.w/2,0,
            -self.w/2,self.w/2,
            self.w/2,self.w/2,
        }
        self.polygons[2] = {
            self.w/4, -self.w/2,
            self.w/4, -self.w,
            -self.w/2, -self.w,
            -self.w, -self.w/2,
            -self.w, 0,
            -self.w/2, 0,
            -self.w/2,-self.w/2            
        }
        self.polygons[3] = {
            self.w/4, self.w/2,
            self.w/4, self.w,
            -self.w/2, self.w,
            -self.w, self.w/2,
            -self.w, 0,
            -self.w/2, 0,
            -self.w/2,self.w/2            
        }
    elseif self.ship == 'Cleaner' then
        self.polygons[1] = {
            self.w,0,
            self.w/2, -self.w/2,
            -self.w/2,-self.w/2,
            -self.w/2,0,
            -self.w/2,self.w/2,
            self.w/2,self.w/2,
        }
        self.polygons[2] = {
            self.w/4, -self.w/2,
            self.w/4, -self.w,
            -self.w/2, -self.w,
            -self.w, -self.w/2,          
        }
        self.polygons[3] = {
            self.w/4, self.w/2,
            self.w/4, self.w,
            -self.w/2, self.w,
            -self.w, self.w/2,          
        }
    elseif self.ship == 'Wisp' then
        self.polygons[1] = {
            self.w,self.w/4,
            self.w,-self.w/4,
            self.w/ self.w/2, -self.w,
            (self.w/ self.w/2) - self.w/2,-self.w,
            -self.w - self.w/2,-self.w/4,
            -self.w - self.w/2,self.w/4,
            (self.w/ self.w/2) - self.w/2,self.w,
            self.w/ self.w/2, self.w,
        }
    elseif self.ship == 'Nuclear' then
        self.polygons[1] = {
            self.w,self.w/4,
            self.w,-self.w/4,
            self.w/2, -self.w/2,
            -self.w/2 - self.w/2, -self.w/2,
            -self.w - self.w/2,-self.w/4,
            -self.w - self.w/2,self.w/4,
            -self.w/2 - self.w/2,self.w/2,
            self.w/2,self.w/2,
        }
    elseif self.ship == 'Cycler' then
        self.polygons[1] = {
            self.w,0,
            0, -self.w,
            -self.w,0,
            0,self.w,
        }
    end

    self.timer:every(0.01, function()
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle', 
            self.x - 0.9*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 0.9*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25)*self.size_multiplier, color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 0.9*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 0.9*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4)*self.size_multiplier, d = random(0.15, 0.25)*self.size_multiplier, color = self.trail_color}) 
        elseif self.ship == 'Big Hunter' then
            self.area:addGameObject('TrailParticle', self.x - 0.8*self.w*math.cos(self.r), self.y - 0.8*self.h*math.sin(self.r), {parent = self, r = random(3,5), d = random(0.15,0.25), color = self.trail_color})
        elseif self.ship == 'Crusader' then
            self.area:addGameObject('TrailParticle', self.x - 0.65*self.w*math.cos(self.r), self.y - 0.65*self.h*math.sin(self.r), {parent = self, r = random(3,5), d = random(0.15,0.25), color = self.trail_color})
        elseif self.ship == 'Cleaner' then
            self.area:addGameObject('TrailParticle', self.x - 0.65*self.w*math.cos(self.r), self.y - 0.65*self.h*math.sin(self.r), {parent = self, r = random(3,5), d = random(0.15,0.25), color = self.trail_color})
        elseif self.ship == 'Wisp' then
            self.area:addGameObject('TrailParticle', self.x - 1.5*self.w*math.cos(self.r), self.y - 1.5*self.h*math.sin(self.r), {parent = self, r = random(3,5), d = random(0.15,0.25), color = self.trail_color})
        end
    end)

    self:setAttack('Laser')
    self:setStats()
    self:generateChances()

    input:bind('f6', function() self:die() end)
end

function Player:update(dt)
    Player.super.update(self,dt)

    randomSpread = random(-math.pi/8, math.pi/8)

    if self.inside_haste_area then self.aspd_multiplier:increase(100) end
    if self.aspd_boosting then self.aspd_multiplier:increase(100) end
    self.aspd_multiplier:update(dt)

    if self.mvspd_boosting then self.mvspd_multiplier:increase(50) end
    self.mvspd_multiplier:update(dt)

    if self.pspd_boosting then self.pspd_multiplier:increase(100) end
    if self.pspd_inhibit then self.pspd_multiplier:decrease(50) end
    self.pspd_multiplier:update(dt)

    self.cycle_speed_multiplier:increase(50)
    self.cycle_speed_multiplier:update(dt)

    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown/self.aspd_multiplier.value then
        self.shoot_timer = 0
        self:shoot()
        if self.chances.attack_twice_chance:next() then
            self.timer:after(0.01,  function () 
                self:shoot()
            end)
        end
    end

    self.max_v = self.base_max_v * self.mvspd_multiplier.value
    if self.boosting == false then self.boost = math.min(self.boost + 10*self.boost_recharge_rate_multiplier*dt, self.max_boost) end
    self.boost_timer = self.boost_timer + dt
    if self.boost_timer > self.boost_cooldown then self.can_boost = true end
    

    self.cycle_timer = self.cycle_timer + dt
    if self.cycle_timer > self.cycle_cooldown / self.cycle_speed_multiplier.value then
        self:cycle()
        self.cycle_timer = 0
    end

    if input:pressed('up') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('up') then self:onBoostEnd() end
    if input:down('up') and self.boost > 1 and self.can_boost then 
        if self.increased_cycle_speed_while_boosting then self.cycle_speed_multiplier:increase(200) end
        self.boosting = true
        self.max_v = 1.5*self.base_max_v*self.boost_effectiveness_multiplier
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
            self:onBoostEnd()
        end
    end
    if input:pressed('down') and self.boost > 1 and self.can_boost then self:onBoostStart() end
    if input:released('down') then self:onBoostEnd() end
    if input:down('down') and self.boost > 1 and self.can_boost then
        if self.increased_cycle_speed_while_boosting then self.cycle_speed_multiplier:increase(200) end
        self.boosting = true
        self.max_v = (0.5/self.boost_effectiveness_multiplier )*self.base_max_v
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
            self:onBoostEnd()
        end
    end

    self.trail_color = skill_point_color
    if self.boosting then self.trail_color = boost_color end

    if input:down('left') then self.r = self.r - (self.rv*self.turn_rate_multiplier)*dt end
    if input:down('right') then self.r = self.r + (self.rv*self.turn_rate_multiplier)*dt end

    self.v = math.min(self.v + self.a*dt, self.max_v)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))

    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end

    if self.collider:enter('Collectable') then
        local collision_data = self.collider:getEnterCollisionData('Collectable')
        local object = collision_data.collider:getObject()
        if object:is(Ammo) then
            object:die()
            self:addAmmo(5)
            self:onAmmoPickup()
        end
        if object:is(Boost) then
            object:die()
            self:addBoost(25)
        end
        if object:is(Health) then
            object:die()
            self:setHealth(25)
            self:onHPPickup()
        end
        if object:is(SkillPoint) then
            if self.chances.gain_double_sp_chance:next() then
                object:die(2)
                self:addSP(2)
            else
                self:addSP(1)
                object:die(1)
            end
            self:onSPPickup()
        end
        if object:is(AttackRessource) then
            object:die()
            self:setAttack(object:getRessourceType())
            current_room.score = current_room.score + 500
        end
    end

    if self.collider:enter('Enemy') then
        self:hit(30)
    end
end

function Player:draw()
    if self.invisible then return end
    pushRotate(self.x,self.y,self.r)
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    for _,polygon in ipairs(self.polygons) do
        local points = Moses.map(polygon, function(v, k)
            if k % 2 == 1 then
                return self.x + v + random(-1,1)
            else
                return self.y + v + random(-1,1)
            end
        end)
        love.graphics.polygon('line', points)
    end
    love.graphics.pop()
end

function Player:destroy()
    Player.super.destroy(self)
end

function Player:shoot()
    local d = 1.2*self.w
    
    self.area:addGameObject('ShootEffect', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {player = self, d = d})

    local mods = {
        shield =  self.chances.shield_projectile_chance:next()
    }

    if self.attack == 'Neutral' then        
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r) , self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))
    elseif self.attack == 'Double' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r + math.pi/12), 
    	self.y + 1.5*d*math.sin(self.r + math.pi/12), 
    	table.merge({r = self.r + math.pi/12, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))
        
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r - math.pi/12),
    	self.y + 1.5*d*math.sin(self.r - math.pi/12), 
    	table.merge({r = self.r - math.pi/12, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))
    elseif self.attack == 'Triple' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r + math.pi/12), 
    	self.y + 1.5*d*math.sin(self.r + math.pi/12), 
    	table.merge({r = self.r + math.pi/12, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))

        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r),
    	self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier}, mods))

        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r - math.pi/12),
    	self.y + 1.5*d*math.sin(self.r - math.pi/12), 
    	table.merge({r = self.r - math.pi/12, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))
    elseif self.attack == 'Rapid' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r),
    	self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier}, mods))
    elseif self.attack == 'Spread' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r + randomSpread),
    	self.y + 1.5*d*math.sin(self.r + randomSpread), 
    	table.merge({r = self.r + randomSpread, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier}, mods))
    elseif self.attack == 'Back' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r),
    	self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))

        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r + math.pi),
    	self.y + 1.5*d*math.sin(self.r + math.pi), 
    	table.merge({r = self.r + math.pi, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier}, mods))
    elseif self.attack == 'Side' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        
        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r),
    	self.y + 1.5*d*math.sin(self.r), 
    	table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))

        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r + math.pi/2),
    	self.y + 1.5*d*math.sin(self.r + math.pi/2), 
    	table.merge({r = self.r + math.pi/2, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier}, mods))

        self.area:addGameObject('Projectile', 
    	self.x + 1.5*d*math.cos(self.r - math.pi/2),
    	self.y + 1.5*d*math.sin(self.r - math.pi/2), 
    	table.merge({r = self.r - math.pi/2, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier}, mods))
    elseif self.attack == 'Homing' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r) , self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))
    elseif self.attack == 'Blast' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        for i = 1,12 do
            local random_angle = random(-math.pi/6, math.pi/6)
            self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + random_angle),
            self.y + 1.5*d*math.sin(self.r + random_angle),
            table.merge({r = self.r + random_angle, attack = self.attack, v = random(500,600)}, mods))
        end
        camera:shake(4,60,0.4)
    elseif self.attack == 'Spin' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r),
        table.merge({r = self.r, attack = self.attack}, mods))
    elseif self.attack == 'Flame' then
        local random_angle = random(-math.pi/7, math.pi/7)
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r + random_angle), self.y + 1.5*d*math.sin(self.r + random_angle),
        table.merge({r = self.r + random_angle, attack = self.attack}, mods))
    elseif self.attack == 'Bounce' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r),
        table.merge({r = self.r, attack = self.attack, bounce = 4 + self.additional_bounce_projectiles}, mods))
    elseif self.attack == '2Split' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r),
        table.merge({r = self.r, attack = self.attack}, mods))
    elseif self.attack == '4Split' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), self.y + 1.5*d*math.sin(self.r),
        table.merge({r = self.r, attack = self.attack}, mods))
    elseif self.attack == 'Lightning' then
        local x1,y1 = self.x + d*math.cos(self.r), self.y + d*math.sin(self.r)
        local cx,cy = x1 + 24*math.cos(self.r), y1+24*math.sin(self.r)

        -- find closest enemy
        local nearby_enemies = self.area:getAllGameObjectsThat(function(e) 
            for _, enemy in ipairs(enemies) do
                if e:is(_G[enemy]) and (distance(e.x,e.y,cx,cy) < 64*self.area_multiplier) then
                    return true
                end
            end
        end)

        table.sort(nearby_enemies, function(a,b)
            return distance(a.x,a.y, cx,cy) < distance(b.x,b.y,cx,cy)
        end)
        local closest_enemy = nearby_enemies[1]
        local second_closest = nearby_enemies[2]

        -- attack closest enemy
        if closest_enemy then
            self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
            closest_enemy:hit()
            local x2,y2 = closest_enemy.x, closest_enemy.y
            self.area:addGameObject('LightningLine', 0,0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
            for i = 1, love.math.random(4,8) do
                self.area:addGameObject('ExplodeParticle', x1,y1, {color = table.random({default_color, boost_color})})
            end
            for i = 1, love.math.random(4,8) do
                self.area:addGameObject('ExplodeParticle', x2,y2, {color = table.random({default_color, boost_color})})
            end
        end

        if self.additional_lightning_bolt and second_closest then
            self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
            second_closest:hit()
            local x2,y2 = second_closest.x, second_closest.y
            self.area:addGameObject('LightningLine', 0,0, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
            for i = 1, love.math.random(4,8) do
                self.area:addGameObject('ExplodeParticle', x1,y1, {color = table.random({default_color, boost_color})})
            end
            for i = 1, love.math.random(4,8) do
                self.area:addGameObject('ExplodeParticle', x2,y2, {color = table.random({default_color, boost_color})})
            end
        end


    elseif self.attack == 'Explode' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r) , self.y + 1.5*d*math.sin(self.r), table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))
    elseif self.attack == 'Laser' then
        self.ammo = self.ammo - attacks[self.attack].ammo*self.ammo_consumption_multiplier
        self.area:addGameObject('LaserProjectile', self.x, self.y,table.merge({r = self.r, attack = self.attack, multiplier = self.pspd_multiplier.value, projectile_size_multiplier = self.projectile_size_multiplier},mods))
        slow(0.5,0.25)
    camera:shake(1, 60, 0.2)
    end

    if self.ammo <= 0 then 
        self:setAttack('Neutral')
        self.ammo = self.max_ammo
    end
end

function Player:cycle()
    self.area:addGameObject('TickEffect', self.x, self.y, {parent = self})
    self:onCycle()
end

function Player:die()
    self.dead = true
    flash(4)
    slow(0.15,1)
    camera:shake(6, 60, 0.4)

    for i = 1, random(8,12) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end

    current_room:finish()
end

function Player:addAmmo(amount)
    self.ammo = math.min(math.max(0,self.ammo + amount + self.ammo_gain), self.max_ammo)
    current_room.score = current_room.score + 50
end

function Player:addBoost(amount)
    self.boost = math.min(math.max(0,self.boost + amount), self.max_boost)
    current_room.score = current_room.score + 150
end

function Player:setHealth(amount)
    self.hp = math.min(math.max(0,self.hp + amount), self.max_hp)
    if self.hp <= 0 then
        self:die()
    end 
end

function Player:addSP(amount)
    sp = sp + amount
    current_room.score = current_room.score + 250
    self:onSPPickup()
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo
end

function Player:hit(damage)
    self.damage = damage or 10
    if self.invincible then return end

    self:setHealth(-self.damage)

    if self.damage >= 30 then
        flash(3)
        slow(0.25,0.5)
        camera:shake(6, 60, 0.2)
        self.invincible = true
        self.timer:after(2*self.invulnerability_time_multiplier, function () 
            self.invincible = false
            self.invisible = false
        end)
        self.timer:every(0.04, function () 
            self.invisible = not self.invisible
        end,30)
    end
    
    if self.damage < 30 then
        flash(2)
        slow(0.75,0.25)
        camera:shake(6, 60, 0.1)
    end

    for i = 1, random(4,8) do 
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
end

function Player:setStats()
    self.max_hp = (self.max_hp + self.flat_hp)*self.hp_multiplier
    self.hp = self.max_hp

    self.max_ammo = (self.max_ammo + self.flat_ammo)*self.ammo_multiplier
    self.ammo = self.max_ammo
    
    self.max_boost = (self.max_boost + self.flat_boost)*self.boost_multiplier
    self.boost = self.max_boost
end

function Player:generateChances()
    self.chances = {}
    for k,v in pairs(self) do
        if k:find('_chance') and type(v) == 'number' then
      	    self.chances[k] = chanceList({true, math.ceil(v*self.luck_multiplier)}, {false, 100-math.ceil(v*self.luck_multiplier)})
      	end
    end
end

function Player:onAmmoPickup()
    if self.chances.launch_homing_projectile_on_ammo_pickup_chance:next() then
        local d = 1.2*self.w
        self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', multiplier = self.pspd_multiplier.value})
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile!', color = default_color})
    end
    if self.chances.regain_hp_on_ammo_pickup_chance:next()  then
        self:setHealth(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
    end
end

function Player:onSPPickup()
    if self.chances.regain_hp_on_sp_pickup_chance:next() then
        self:setHealth(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'HP Regain!', color = hp_color})
    end

    if self.chances.spawn_haste_area_on_sp_pickup_chance:next() then
        self.area:addGameObject('HasteArea', self.x,self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!', color = default_color})
    end
end

function Player:onHPPickup()
    if self.chances.spawn_haste_area_on_hp_pickup_chance:next() then
        self.area:addGameObject('HasteArea', self.x,self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Haste Area!', color = default_color})
    end
end

function Player:onCycle()
    if self.chances.spawn_sp_on_cycle_chance:next() then
        self.area:addGameObject('SkillPoint')
        self.area:addGameObject('InfoText', self.x, self.y, {text = "SP Spawn!", color = skill_point_color})
    end

    if self.chances.spawn_hp_on_cycle_chance:next() then
        self.area:addGameObject('Health')
        self.area:addGameObject('InfoText', self.x, self.y, {text = "HP Spawn!", color = hp_color})
    end

    if self.chances.regain_hp_on_cycle_chance:next() then
        self:setHealth(25)
        self.area:addGameObject('InfoText', self.x, self.y, {text = "HP Regain!", color = hp_color})
    end

    if self.chances.regain_full_ammo_on_cycle_chance:next() then
        self:addAmmo(self.max_ammo)
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Full Ammo!", color = ammo_color})
    end

    if self.chances.change_attack_on_cycle_chance:next() then
        local keys = {}
        for key in pairs(attacks) do
            table.insert(keys, key)
        end
    
        self.attack = table.random(keys)
        self.area:addGameObject('InfoText', self.x, self.y, {text = self.attack .. '!', color = attacks[self.attack].color})
    end

    if self.chances.spawn_haste_area_on_cycle_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Haste Area!", color = default_color})
    end

    if self.chances.barrage_on_cycle_chance:next() then
        for i = 1, 8 do
            self.timer:after((i-1)*0.05, function() 
                local random_angle = random(-math.pi/8, math.pi/8)
                local d = 2.2*self.w
                self.area:addGameObject('Projectile', self.x + d*math.cos(self.r + random_angle), self.y + d*math.sin(self.r + random_angle), {r = self.r + random_angle, attack = self.attack, multiplier = self.pspd_multiplier.value})
            end)
        end
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Barrage!", color = default_color})
    end

    if self.chances.launch_homing_projectile_on_cycle_chance:next() then
        local d = self.w * 1.2
        self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {attack = 'Homing', r = self.r, multiplier = self.pspd_multiplier.value})
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Homing Projectile!", color = default_color})
    end

    if self.chances.mvspd_boost_on_cycle_chance:next() then
        self.mvspd_boosting = true
        self.timer:after(4, function() self.mvspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'MVSPD Boost!', color = default_color})
    end

    if self.chances.pspd_boost_on_cycle_chance:next() then
        self.pspd_boosting = true
        self.timer:after(4, function() self.pspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Boost!', color = default_color})
    end

    if self.chances.pspd_inhibit_on_cycle_chance:next() then
        self.pspd_inhibit = true
        self.timer:after(4, function() self.pspd_inhibit = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'PSPD Inhibit!', color = default_color})
    end
    -- if self.regain_full_ammo_on_cycle_chance:next() then
    --     self:addAmmo(self.max_ammo)
    --     self.area:addGameObject('InfoText', self.x, self.y, {text = "Full Ammo!", color = ammo_color})
    -- end
end

function Player:onKill()
    if self.chances.barrage_on_kill_chance:next() then
        for i = 1, 8 do
            self.timer:after((i-1)*0.05, function() 
                local random_angle = random(-math.pi/8, math.pi/8)
                local d = 2.2*self.w
                self.area:addGameObject('Projectile', self.x + d*math.cos(self.r + random_angle), self.y + d*math.sin(self.r + random_angle), {r = self.r + random_angle, attack = self.attack})
            end)
        end
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Barrage!", color = default_color})
    end

    if self.chances.regain_ammo_on_kill_chance:next() then
        self:addAmmo(20)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Ammo Regained!', color = ammo_color})
    end

    if self.chances.launch_homing_projectile_on_kill_chance:next() then
        local d = self.w * 1.2
        self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {attack = 'Homing', r = self.r, multiplier = self.pspd_multiplier.value})
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Homing Projectile!", color = default_color})
    end

    if self.chances.regain_boost_on_kill_chance:next() then
        self:addBoost(40)
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Boost Regained", color = boost_color})
    end

    if self.chances.spawn_boost_on_kill_chance:next() then
        self.area:addGameObject('Boost')
        self.area:addGameObject('InfoText', self.x, self.y, {text = "Boost Spawned!", color = boost_color})
    end

    if self.chances.gain_aspd_boost_on_kill_chance:next() then
        self.aspd_boosting = true
        self.timer:after(4, function() self.aspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'ASPD Boost!', color = ammo_color})
    end


end

function Player:onBoostStart()
    self.timer:every('launch_homing_projectile_while_boosting_chance', 0.2, function() 
        if self.chances.launch_homing_projectile_while_boosting_chance:next() then
            local d = 1.2*self.w
            self.area:addGameObject('Projectile', self.x + d*math.cos(self.r), self.y + d*math.sin(self.r), {r = self.r, attack = 'Homing', multiplier = self.pspd_multiplier.value})
            self.area:addGameObject('InfoText', self.x, self.y, {text = 'Homing Projectile', color = default_color})
        end
    end)

    if self.invulnerability_while_boosting then self.invincible = true end

    if self.increased_luck_while_boosting then
        self.luck_boosting = true
        self.luck_multiplier = self.luck_multiplier*2
        self:generateChances()
    end
end

function Player:onBoostEnd()
    self.timer:cancel('launch_homing_projectile_while_boosting_chance')

    self.boosting = false

    if self.invulnerability_while_boosting then self.invincible = false end

    if self.increased_luck_while_boosting and self.luck_boosting then
        self.luck_boosting = false
        self.luck_multiplier = self.luck_multiplier/2
        self:generateChances()
    end
end