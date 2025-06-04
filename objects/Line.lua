Line = Object:extend()

function Line:new(node_1_id, node_2_id)
    self.node_1_id, self.node_2_id = node_1_id, node_2_id
    self.node_1, self.node_2 = tree[node_1_id], tree[node_2_id]
end

function Line:update(dt)
end

function Line:draw()
    love.graphics.setColor(love.math.colorFromBytes(default_color))
    love.graphics.line(self.node_1.x,self.node_1.y,self.node_2.x,self.node_2.y)
end
