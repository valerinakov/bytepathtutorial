ExplodeEffect = GameObject:extend()

function ExplodeEffect:new(area,x,y,opts)
    ExplodeEffect.super.new(self,area,x,y,opts)
    self.current_color = default_color

    self.initialSize = 0
    self.maxSize = self.w*2
    self.size = 0


    self.timer:tween(0.25, self, {size = 75*current_room.player.area_multiplier}, 'in-out-cubic', function() 
        for i = 1, love.math.random(4,8) do
            self.area:addGameObject('ExplodeParticle', self.x,self.y, {color = hp_color, s = random(8,12), v = random(150,300)})
        end
        self.timer:tween(0.1, self, {size = 35}, 'in-out-cubic', function() 
            self.dead = true
        end)
    end)

    self.timer:after(0.3, function()
        self.current_color = self.color
        self.timer:after(0.2, function () 
            self.dead = true
        end)
    end)
end

function ExplodeEffect:update(dt)
    ProjectileDeathEffect.super.update(self,dt)
end

function ExplodeEffect:draw()
    love.graphics.setColor(love.math.colorFromBytes(self.current_color))
    love.graphics.rectangle('fill', self.x - self.size/2, self.y - self.size /2, self.size, self.size)
end