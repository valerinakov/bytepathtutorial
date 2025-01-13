LightningLine = GameObject:extend()

function LightningLine:new(area,x,y,opts)
    LightningLine.super.new(self,area,x,y,opts)

    self.lines = { }
    self.alpha = 255

    self.timer:tween(0.15, self, {alpha = 0}, 'in-out-cubic', function() 
        self.dead = true
    end)

    self:generate()
end

function LightningLine:update(dt)
    LightningLine.super.update(self,dt)
end

function LightningLine:generate()
    -- Start and end points for the initial lightning
    local startPoint = {x = self.x1, y = self.y1}
    local endPoint = {
        x = self.x2,
        y = self.y2
    }

    -- Create the initial segment list
    local segmentList = {
        {startPoint = startPoint, endPoint = endPoint}
    }
    local maximumOffset = 50 -- Maximum offset for the first generation
    local generations = 5 -- Number of generations to create

    -- Loop through generations
    for gen = 1, generations do
        local newSegments = {}
        local offsetAmount = maximumOffset / (2 ^ (gen - 1)) -- Halve offset each generation
        
        -- Process each segment in the current generation
        for _, segment in ipairs(segmentList) do
            -- Calculate the midpoint
            local midPoint = {
                x = (segment.startPoint.x + segment.endPoint.x) / 2,
                y = (segment.startPoint.y + segment.endPoint.y) / 2
            }

            -- Offset the midpoint by a random amount along the perpendicular
            local dx = segment.endPoint.x - segment.startPoint.x
            local dy = segment.endPoint.y - segment.startPoint.y
            local length = math.sqrt(dx * dx + dy * dy)
            local perpendicular = {x = -dy / length, y = dx / length}

            midPoint.x = midPoint.x + perpendicular.x * love.math.random(-offsetAmount, offsetAmount)
            midPoint.y = midPoint.y + perpendicular.y * love.math.random(-offsetAmount, offsetAmount)

            -- Add two new segments with the offset midpoint
            table.insert(newSegments, {startPoint = segment.startPoint, endPoint = midPoint})
            table.insert(newSegments, {startPoint = midPoint, endPoint = segment.endPoint})
        end

        -- Replace old segments with the new ones
        segmentList = newSegments
    end

    -- Store the final segments in self.lines
    for _, segment in ipairs(segmentList) do
        table.insert(self.lines, {
            x1 = segment.startPoint.x, y1 = segment.startPoint.y,
            x2 = segment.endPoint.x, y2 = segment.endPoint.y
        })
    end
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