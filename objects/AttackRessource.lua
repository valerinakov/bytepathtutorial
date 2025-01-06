require './../globals'

AttackRessource = GameObject:extend()

function AttackRessource:new(area,x,y,opts)
    AttackRessource.super.new(self,area,x,y,opts)

    self.font = fonts.m5x7_16
    love.graphics.setFont(self.font)

    local direction = table.random({-1,1})

    local keys = {}
    for key in pairs(attacks) do
        table.insert(keys, key)
    end

    self.ressourceType = table.random(keys)

    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48, gh-48)

    self.w,self.h = 12,12

    self.collider = self.area.world:newRectangleCollider(self.x,self.y,self.w,self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20,40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-24,24))
end

function AttackRessource:update(dt)
    AttackRessource.super.update(self,dt)

    self.collider:setLinearVelocity(self.v,0)
end

function AttackRessource:draw()
    love.graphics.setColor(love.math.colorFromBytes(attacks[self.ressourceType].color))

    Draft:rhombus(self.x, self.y, 2.5*self.w, 2.5*self.h, 'line')
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    Draft:rhombus(self.x, self.y, 2*self.w, 2*self.h, 'line')
    love.graphics.setColor(love.math.colorFromBytes(attacks[self.ressourceType].color))
    love.graphics.print(attacks[self.ressourceType].abbreviation,self.x - (self.font:getWidth(attacks[self.ressourceType].abbreviation)/2),self.y,0,1,1,0,self.font:getHeight()/2)

    love.graphics.setColor(love.math.colorFromBytes(default_color))
end

function AttackRessource:die()
    self.dead = true
    self.area:addGameObject('AttackRessourceEffect', self.x, self.y, {w = self.w, h = self.h, color = attacks[self.ressourceType].color})
    self.area:addGameObject('InfoText', self.x +  table.random({-1, 1})*self.w, self.y +  table.random({-1, 1})*self.h, {text = self.ressourceType, color = boost_color, w = self.w, h = self.h})
end

function AttackRessource:getRessourceType()
    return self.ressourceType
end