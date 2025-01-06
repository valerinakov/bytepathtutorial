SkillPoint = GameObject:extend()

function SkillPoint:new(area,x,y,opts)
    SkillPoint.super.new(self,area,x,y,opts)

    local direction = table.random({-1,1})

    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48,gh-48)

    self.w,self.h = 12,12

    self.collider = self.area.world:newRectangleCollider(self.x,self.y,self.w,self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20,40)
    self.collider:setLinearVelocity(self.v,0)
    self.collider:applyAngularImpulse(random(-24,24))
end

function SkillPoint:update(dt)
    SkillPoint.super.update(self,dt)

    self.collider:setLinearVelocity(self.v, 0)
end

function SkillPoint:draw()
    love.graphics.setColor(love.math.colorFromBytes(skill_point_color))
    pushRotate(self.x,self.y,self.collider:getAngle())

    Draft:rhombus(self.x,self.y, 1.5*self.w, 1.5*self.h, 'line')
    Draft:rhombus(self.x,self.y, 0.5*self.w, 0.5*self.h, 'fill')

    love.graphics.pop()
    love.graphics.setColor(love.math.colorFromBytes(default_color))
end

function SkillPoint:die(amount)
    self.dead = true
    self.area:addGameObject('SkillPointEffect', self.x, self.y, {w = self.w, h = self.h, color = skill_point_color})
    self.area:addGameObject('InfoText', self.x +  table.random({-1, 1})*self.w, self.y +  table.random({-1, 1})*self.h, {text = '+' .. amount .. ' SP', color = skill_point_color, w = self.w, h = self.h})
end