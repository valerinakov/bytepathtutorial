Shooter = GameObject:extend()

function Shooter:new(area,x,y,opts)
    Shooter.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.max_hp = 100
    self.hp = self.max_hp

    self.hit_flash = false

    self.w, self.h = 12, 6
    self.collider = self.area.world:newPolygonCollider({self.w,0,-self.w/2,self.h,-self.w,0,-self.w/2,-self.h})
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    -- self.collider:setMass(50)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFixedRotation(false)
    self.collider:setAngle(direction == 1 and math.pi or 0)
    self.collider:setFixedRotation(true)
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-100, 100))

    self.timer:every(random(3,5), function () 
        self.area:addGameObject('PreAttackEffect', 
        self.x + 1.4*self.w*math.cos(self.collider:getAngle()),
        self.y + 1.4*self.w*math.sin(self.collider:getAngle()),
        {shooter = self, color = hp_color, duration = 1})
        self.timer:after(1, function () 
            self.area:addGameObject('EnemyProjectile',
            self.x + 1.4*self.w*math.cos(self.collider:getAngle()),
            self.y + 1.4*self.w*math.sin(self.collider:getAngle()),
            {r = math.atan2(current_room.player.y - self.y, current_room.player.x - self.x),
            v = random(80,100), s = 3.5})
        end)
    end)
end

function Shooter:update(dt)
    Shooter.super.update(self,dt)

    self.hit_by_laser = false
end

function Shooter:draw()
    if self.hit_flash then
        love.graphics.setColor(love.math.colorFromBytes(default_color))
    else
        love.graphics.setColor(love.math.colorFromBytes(hp_color))
    end
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    
    love.graphics.polygon('line', points)
    love.graphics.setColor(love.math.colorFromBytes(default_color))
end

function Shooter:hit(damage)
    local damage = damage or 100
    self.hp = self.hp - damage

    if self.hp <= 0 then
        self.dead = true
        if current_room.player.chances.drop_double_ammo_chance:next() then
            self.area:addGameObject('Ammo', self.x + 3, self.y + 3)
        end  
        self.area:addGameObject('Ammo', self.x, self.y)
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = self.w, h = self.h})
        current_room.score = current_room.score + 150
    else
        self.hit_flash = true
        self.timer:after(0.2, function () 
            self.hit_flash = false
        end)
    end
end