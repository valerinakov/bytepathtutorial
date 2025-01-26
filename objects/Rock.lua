Rock = GameObject:extend()

function Rock:new(area,x,y,opts)
    Rock.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(16, gh - 16)

    self.max_hp = 100
    self.hp = self.max_hp

    self.hit_flash = false

    self.w, self.h = 8, 8
    self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(8))
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    -- self.collider:setMass(10)
    self.collider:setCollisionClass('Enemy')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-100, 100))
end

function Rock:update(dt)
    Rock.super.update(self,dt)

    self.hit_by_laser = false
end

function Rock:draw()
    if self.hit_flash then
        love.graphics.setColor(love.math.colorFromBytes(default_color))
    else
        love.graphics.setColor(love.math.colorFromBytes(hp_color))
    end
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    
    love.graphics.polygon('line', points)
    love.graphics.setColor(love.math.colorFromBytes(default_color))
end

function Rock:hit(damage)
    local damage = damage or 100
    self.hp = self.hp - damage

    if self.hp <= 0 then
        self.dead = true
        if current_room.player.chances.drop_double_ammo_chance:next() then
            self.area:addGameObject('Ammo', self.x + 3, self.y + 3)
        end  
        self.area:addGameObject('Ammo', self.x, self.y)
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, w = self.w, h = self.h})
        current_room.score = current_room.score + 100
    else
        self.hit_flash = true
        self.timer:after(0.2, function () 
            self.hit_flash = false
        end)
    end
end