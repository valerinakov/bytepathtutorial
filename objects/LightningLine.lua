LightningLine = GameObject:extend()

function LightningLine:new(area,x,y,opts)
    LightningLine.super.new(self,area,x,y,opts)

    self.lines = {    {x1 = 1, y1 = 2, x2 = 3, y2 = 4},
    {x1 = 5, y1 = 6, x2 = 7, y2 = 8},
    {x1 = 9, y1 = 10, x2 = 11, y2 = 12},
    {x1 = 13, y1 = 14, x2 = 15, y2 = 16}}
    self.alpha = 255

    self.timer:tween(0.15, self, {alpha = 0}, 'in-out-cubic', function() 
        self.dead = true
    end)

    self:generate()
end

function LightningLine:update(dt)
    LightningLine.super.update(self,dt)
    print(self.lines[1])
end

function LightningLine:generate()
    table.insert(self.lines, {x1 = 1, y1 =1, x2 =2, y2 = 2})
end

function LightningLine:draw()
    for i, line in ipairs(self.lines) do
        local r,g,b = unpack(boost_color)
        love.graphics.setColor(love.math.colorFromBytes(r,g,b, self.alpha))
        love.graphics.setLineWidth(2.5)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2)
    
        local r,g,b = unpack(default_color)
        love.graphics.setColor(love.math.colorFromBytes(r,g,b, self.alpha))
        love.graphics.setLineWidth(1.5)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2)
    
    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(love.math.colorFromBytes(255,255,255,255))
end

function LightningLine:destroy()
    LightningLine.super.destroy(self)
end