Node = Object:extend()

function Node:new(id, x,y)
    self.id = id
    self.x, self.y = x, y
    self.hot = false
    self.h = 12
    self.w = 12
end

function Node:update(dt)
    local mx,my = camera:getMousePosition(sx*camera.scale, sy*camera.scale, 0,0, sx*gw, sy*gh)
    if mx >= self.x - self.w/2 and mx <= self.x + self.w/2 and
       my >= self.y - self.h/2 and my <= self.y + self.h/2 then
        print('sup')
        self.hot = true
       else self.hot = false end
    
       print('mx' .. mx)
       print('my' .. my)
    --    print(self.hot)
end

function Node:draw()
    love.graphics.setColor(love.math.colorFromBytes(background_color))
    love.graphics.circle('fill', self.x, self.y, 12)
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    love.graphics.circle('line', self.x, self.y, 12)
    print('in draw ' .. self.x)
end