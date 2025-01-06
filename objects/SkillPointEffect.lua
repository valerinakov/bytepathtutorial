SkillPointEffect = GameObject:extend()

function SkillPointEffect:new(area,x,y,opts)
    SkillPointEffect.super.new(self,area,x,y,opts)

    self.current_color = default_color
    self.visible = true

    self.sx,self.sy = 1,1

    self.timer:tween(0.35,self,{sx = 2, sy = 2}, 'in-out-cubic')

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

function SkillPointEffect:update(dt)
    SkillPointEffect.super.update(self,dt)
end

function SkillPointEffect:draw()
    if not self.visible then return end

    love.graphics.setColor(love.math.colorFromBytes(self.color))

    Draft:rhombus(self.x,self.y, 1.34*self.w, 1.34*self.h, 'fill')
    Draft:rhombus(self.x,self.y, self.sx*2*self.w, self.sy*2*self.h, 'line')

    love.graphics.setColor(love.math.colorFromBytes(default_color))
end