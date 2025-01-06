HealthEffect = GameObject:extend()

function HealthEffect:new(area,x,y,opts)
    HealthEffect.super.new(self,area,x,y,opts)

    self.current_color = default_color
    self.visible = true

    self.sx, self.sy = 1,1

    self.timer:tween(0.35, self, {sx=1.5,sy =1.5}, 'in-out-cubic')

    self.timer:after(0.2, function () 
        self.current_color = self.color
        self.timer:after(0.35, function () 
            self.dead = true
        end)
    end)

    self.timer:after(0.2, function () 
        self.timer:every(0.05, function () 
            self.visible = not self.visible
        end, 6)
        self.timer:after(0.35, function () 
            self.visible = true 
        end)
    end)
    
end

function HealthEffect:update(dt)
    HealthEffect.super.update(self,dt)
end

function HealthEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(love.math.colorFromBytes(default_color))
    love.graphics.circle('line', self.x,self.y, self.w*self.sx)
    love.graphics.setColor(love.math.colorFromBytes(self.current_color))
    Draft:rectangle(self.x, self.y, self.w*self.sx, self.h/2*self.sy, 'fill')
    Draft:rectangle(self.x, self.y, self.w/2*self.sx, self.h*self.sy, 'fill')
end