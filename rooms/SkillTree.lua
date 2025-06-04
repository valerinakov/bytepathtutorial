SkillTree = Object:extend()

function SkillTree:new()
    -- self.previous_mx = 0
    -- self.previous_my = 0
    self.nodes = {}
    tree = {}
    self.lines = {}

    tree[1] = {x = 0, y = 0, stats = {'4% Increased HP', 'hp_multiplier', 0.04,
                                     '4% Increased Ammo', 'ammo_multiplier', 0.04}, links = {2}}
    tree[2] = {x = 32, y = 0, stats = {'6% Increased HP', 'hp_multiplier', 0.04}, links = {1,3}}
    tree[3] = {x = 32, y = 32, stats = {'4% Increased HP', 'hp_multiplier', 0.04}, links = {2}}


    self.timer = Timer()
    
    for id, node in ipairs(tree) do table.insert(self.nodes, Node(id, node.x, node.y)) end
    print(tree)
	-- input:bind('mouse1', 'mouse1')

    for id,node in ipairs(tree) do
        for _,linked_node_id in ipairs(node.links) do
            table.insert(self.lines, Line(id,linked_node_id))
        end
    end

end


function SkillTree:update(dt)
    -- camera.smoother = Camera.smooth.damped(5)
    -- camera:lockPosition(dt, 0, 0)
    self.timer:update(dt)
    if input:down('mouse1', dt) then
        local mx,my = camera:getMousePosition(sx,sy,0,0,sx*gw,sy*gh)
        local dx,dy = mx - self.previous_mx, my - self.previous_my

        camera:move(-dx, -dy)
    end

    self.previous_mx, self.previous_my = camera:getMousePosition(sx, sy, 0, 0, sx*gw, sy*gh)

    if input:pressed('zoom_in') then
        self.timer:tween('zoom', 0.2, camera, {scale = camera.scale +0.4}, 'in-out-cubic')
    end

    
    if input:pressed('zoom_out') then
        self.timer:tween('zoom', 0.2, camera, {scale = camera.scale -0.4}, 'in-out-cubic')
    end

    for _, node in ipairs(self.nodes) do
        node:update(dt)
    end
end

function SkillTree:draw()
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(0,0)
    camera:attach()
    for _, line in ipairs(self.lines) do
        line:draw()
    end

    for _, node in ipairs(self.nodes) do
        node:draw()
    end
    camera:detach() 
end