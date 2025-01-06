Health = GameObject:extend()

function Health:new(area,x,y,opts)
    Health.super.new(self,area,x,y,opts)

    local direction = table.random({-1,1})

    self.x = gw/2 + direction*(gw/2+48)
    self.y = random(48,gh-48)

    self.w,self.h = 12,12
    
    self.collider = self.area.world:newCircleCollider(self.x,self.y,self.w)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20,40)
    self.collider:setLinearVelocity(self.v,0)
    self.collider:applyAngularImpulse(random(-24,24))
end


function Health:update(dt)
    Health.super.update(self,dt)

    self.collider:setLinearVelocity(self.v,0)
end

function Health:draw()
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    love.graphics.circle('line', self.x,self.y, self.w)
    love.graphics.setColor(love.math.colorFromBytes(hp_color))
    Draft:rectangle(self.x, self.y, self.w, self.h/2, 'fill')
    Draft:rectangle(self.x, self.y, self.w/2, self.h, 'fill')
end

function Health:die()
    self.dead = true
    self.area:addGameObject('HealthEffect', self.x,self.y, {w = self.w, h = self.h,color = hp_color})
    self.area:addGameObject('InfoText', self.x +  table.random({-1, 1})*self.w, self.y +  table.random({-1, 1})*self.h, {text = '+HP',color=hp_color, w = self.w, h = self.h})
end