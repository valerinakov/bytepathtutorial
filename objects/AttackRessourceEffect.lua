AttackRessourceEffect = GameObject:extend()

function AttackRessourceEffect:new(area,x,y,opts)
    AttackRessourceEffect.super.new(self,area,x,y,opts)

    self.visible = true

    self.sx, self.sy = 1,1

    self.timer:tween(0.35, self, {sx = 2, sy = 2}, 'in-out-cubic')

    self.timer:after(0.2, function () 
        self.timer:every(0.05, function () 
            self.visible = not self.visible
        end, 6)
    end)

    self.timer:after(0.55, function () 
        self.visible = true
        self.dead = true
    end)
end

function AttackRessourceEffect:update(dt)
    AttackRessourceEffect.super.update(self,dt)
end

function AttackRessourceEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(love.math.colorFromBytes(self.color))
    Draft:rhombus(self.x, self.y, self.sx*2.5*self.w, self.sy*2.5*self.h, 'line')
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    Draft:rhombus(self.x, self.y, self.sx*2*self.w, self.sy*2*self.h, 'line')
    love.graphics.setColor(love.math.colorFromBytes(default_color))
end