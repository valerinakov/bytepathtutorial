LaserProjectile = GameObject:extend()

function LaserProjectile:new(area,x,y,opts)
    LaserProjectile.super.new(self,area,x,y,opts)

    self.laserWidth = 15    
    self.laserOutlineWidth = 2
    self.timer:tween(0.1, self, {laserWidth=0}, 'in-linear', function() 
        self.dead = true
    end)
    self.timer:tween(0.1, self, {laserOutlineWidth=0}, 'in-linear',function() 
        self.dead = true
    end)

    -- Define the laser offset distance
    self.offsetDistance = 10 -- Adjust this to set how far ahead the laser starts

    -- Calculate the offset using the angle (self.r)
    self.offsetX = math.cos(self.r) * self.offsetDistance
    self.offsetY = math.sin(self.r) * self.offsetDistance

    self.staticX = self.x + self.offsetX
    self.staticY = self.y + self.offsetY

    self.damage = 100

    self.color = attacks[self.attack].color
    -- Define laser length and thickness
    self.laserLength = 500 -- Length of the laser
    self.thickness = 10 -- Thickness of the laser
    -- Define the vertices for the rectangle collider
    self.endX = self.staticX + self.laserLength * math.cos(self.r)
    self.endY = self.staticY + self.laserLength * math.sin(self.r)
    self.perpX = math.cos(self.r + math.pi / 2) * self.thickness / 2
    self.perpY = math.sin(self.r + math.pi / 2) * self.thickness / 2

    self.collider = self.area.world:newPolygonCollider({
        self.staticX - self.perpX, self.staticY - self.perpY, -- Bottom-left
        self.staticX + self.perpX, self.staticY + self.perpY, -- Top-left
        self.endX + self.perpX, self.endY + self.perpY, -- Top-right
        self.endX - self.perpX, self.endY - self.perpY -- Bottom-right
    })

    self.collider:setSensor(true) -- This makes the collider non-physical

    -- self.collider = self.area.world:newLineCollider(self.staticX, self.staticY, self.staticX + 500 *math.cos(self.r), self.staticY + 500 * math.sin(self.r))
    self.collider:setObject(self)
    self.collider:setCollisionClass('Projectile')

    self.previous_x, self.previous_y = self.collider:getPosition()
end

function LaserProjectile:update(dt)
    LaserProjectile.super.update(self,dt)

   -- Define the laser's bounding box (axis-aligned for simplicity)
   local x1 = math.min(self.staticX, self.staticX + self.laserLength * math.cos(self.r))
   local y1 = math.min(self.staticY, self.staticY + self.laserLength * math.sin(self.r))
   local x2 = math.max(self.staticX, self.staticX + self.laserLength * math.cos(self.r))
   local y2 = math.max(self.staticY, self.staticY + self.laserLength * math.sin(self.r))

   -- Query all objects within the bounding box
--    local colliders = self.area.world:queryBoundingBox(x1, y1, x2, y2)

   local colliders_1 = self.area.world:queryPolygonArea({self.staticX - self.perpX, self.staticY - self.perpY,
        self.staticX + self.perpX, self.staticY + self.perpY,
        self.endX + self.perpX, self.endY + self.perpY,
        self.endX - self.perpX, self.endY - self.perpY }, {'Enemy'})

   -- Loop through all colliders and damage enemies
   for _, collider in ipairs(colliders_1) do
       if collider.collision_class == 'Enemy' then
           local enemy = collider:getObject()
           if enemy and not enemy.hit_by_laser then
               enemy:hit(self.damage)
            --    enemy.hit_by_laser = true -- Avoid hitting the same enemy multiple times
               if enemy.hp <= 0 then current_room.player:onKill() end
           end
       end
   end

end

function LaserProjectile:draw()
    
    love.graphics.setColor(love.math.colorFromBytes(default_color))

    local perpendicularDistance = 5
    local perpendicularOffsetX = math.cos(self.r + math.pi / 2) * perpendicularDistance
    local perpendicularOffsetY = math.sin(self.r + math.pi / 2) * perpendicularDistance

    -- Calculate starting positions for the left and right lines
    local leftStartX = self.staticX + self.offsetX + perpendicularOffsetX
    local leftStartY = self.staticY + self.offsetY + perpendicularOffsetY
    local rightStartX = self.staticX + self.offsetX - perpendicularOffsetX
    local rightStartY = self.staticY + self.offsetY - perpendicularOffsetY

    -- End positions for the lines
    local endX = self.staticX + self.offsetX + 500 * math.cos(self.r)
    local endY = self.staticY + self.offsetY + 500 * math.sin(self.r)
    local leftEndX = endX + perpendicularOffsetX
    local leftEndY = endY + perpendicularOffsetY
    local rightEndX = endX - perpendicularOffsetX
    local rightEndY = endY - perpendicularOffsetY

    -- Draw the original line
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    love.graphics.setLineWidth(self.laserWidth)
    love.graphics.line(self.staticX + self.offsetX, self.staticY + self.offsetY, endX, endY)
    love.graphics.setLineWidth(self.laserOutlineWidth)
    -- Draw the left line
    love.graphics.setColor(love.math.colorFromBytes(hp_color))
    love.graphics.line(leftStartX, leftStartY, leftEndX, leftEndY)

    -- Draw the right line
    love.graphics.line(rightStartX, rightStartY, rightEndX, rightEndY)
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    -- Reset line width
    love.graphics.setLineWidth(1)

end

function LaserProjectile:die()
    self.dead = true
end