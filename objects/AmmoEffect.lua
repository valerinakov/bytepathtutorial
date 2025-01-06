AmmoEffect = GameObject:extend()

function AmmoEffect:new(area,x,y,opts)
    AmmoEffect.super.new(self,area,x,y,opts)
    self.current_color = ammo_color

    self.timer:after(0.1, function () 
        self.current_color = self.color
        self.timer:after(0.25, function () 
            self.dead = true
        end)
    end)
end

function AmmoEffect:update(dt)
    AmmoEffect.super.update(self,dt)
end

function AmmoEffect:draw()
    love.graphics.setColor(love.math.colorFromBytes(self.current_color))
    Draft:rhombus(self.x,self.y,self.w,self.h,'fill')
end