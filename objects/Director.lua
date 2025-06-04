Director = Object:extend()

function Director:new(stage)
    self.stage = stage

    self.timer = Timer()

    self.difficulty = 1
    self.round_duration = 22
    self.round_timer = 0

    self.resource_timer_duration = 16
    self.resource_timer = 0
    self.resource_list = {}

    self.attack_timer = 0
    self.attack_timer_duration = 5

    self.resource_spawn_chances = chanceList({'Boost', 28*current_room.player.boost_spawn_chance_multiplier}, {'Health', 14*current_room.player.hp_spawn_chance_multiplier}, {'SkillPoint', 58*current_room.player.sp_spawn_chance_multiplier})
    -- self.resource_spawn_chances = chanceList({'Boost', 28}, {'Health', 14}, {'SkillPoint', 58})


    self.enemy_spawn_chances = {
        [1] = chanceList({'BigRock', 1}),
        [2] = chanceList({'Rock', 6}, {'Shooter', 4}, {'BigRock', 2}),
        [3] = chanceList({'Rock', 4}, {'Shooter', 8}, {'BigRock', 4}),
        [4] = chanceList({'Rock', 4}, {'Shooter', 8}),
    }

    for i = 5, 1024 do
        self.enemy_spawn_chances[i] = chanceList(
            {'Rock', love.math.random(2,12)},
            {'Shooter', love.math.random(2,12)},
            {'BigRock', love.math.random(2,12)}
        )
    end

    self.enemy_to_points = {
        ['Rock'] = 1,
        ['Shooter'] = 2,
        ['BigRock'] = 2
    }

    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16

    for i = 2, 1024, 4 do
        self.difficulty_to_points[i] = self.difficulty_to_points[i-1] + 8
        self.difficulty_to_points[i+1] = self.difficulty_to_points[i]
        self.difficulty_to_points[i+2] = math.floor(self.difficulty_to_points[i+1]/1.5)
        self.difficulty_to_points[i+3] = math.floor(self.difficulty_to_points[i+2]*2)
    end

    self:setEnemySpawnsForThisRound()
end

function Director:update(dt)
    self.timer:update(dt)

    self.round_timer = self.round_timer + dt
    self.resource_timer = self.resource_timer + dt
    self.attack_timer = self.attack_timer + dt

    if self.round_timer > self.round_duration/self.stage.player.enemy_spawn_rate_multiplier then
        self.round_timer = 0
        self.difficulty = self.difficulty + 1
        self:setEnemySpawnsForThisRound()
    end

    if self.resource_timer > self.resource_timer_duration/self.stage.player.resource_spawn_rate_multiplier then
        self.resource_timer = 0
        self:setResourceSpawns()
    end

    if self.attack_timer > self.attack_timer_duration/self.stage.player.attack_spawn_rate_multiplier then
        self.attack_timer = 0
        self:setSpawnAttack()
    end

    -- //    self.resource_spawn_rate_multiplier = 1
    -- self.attack_spawn_rate_multiplier = 25
end

function Director:setEnemySpawnsForThisRound()
    local points = self.difficulty_to_points[self.difficulty]

    local enemy_list = {}
    while points > 0 do
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
        points = points - self.enemy_to_points[enemy]
        table.insert(enemy_list, enemy)
    end

    local enemy_spawn_times = {}
    for i = 1, #enemy_list do 
        enemy_spawn_times[i] = random(0, self.round_duration)
    end

    table.sort(enemy_spawn_times, function(a,b) return a < b end)

    for i = 1, #enemy_spawn_times do
        self.timer:after(enemy_spawn_times[i], function () 
            self.stage.area:addGameObject(enemy_list[i])
        end)
    end
end

function Director:setResourceSpawns()
    if #self.resource_list == 0 then
        for i = 1, 100 do 
            local resource = self.resource_spawn_chances:next()
            table.insert(self.resource_list, resource)
        end
    end
    local resourceToBeSpawned =  math.floor(random(#self.resource_list))
    if self.resource_list[resourceToBeSpawned] == 'Health' and current_room.player.chances.spawn_double_hp_chance:next() then
        self.stage.area:addGameObject(self.resource_list[resourceToBeSpawned])
    end
    if self.resource_list[resourceToBeSpawned] == 'SkillPoint' and current_room.player.chances.spawn_double_sp_chance:next() then
        self.stage.area:addGameObject(self.resource_list[resourceToBeSpawned])
    end

    self.stage.area:addGameObject(self.resource_list[resourceToBeSpawned])
    table.remove(self.resource_list, resourceToBeSpawned)
end

function Director:setSpawnAttack()
    self.stage.area:addGameObject('AttackRessource')
end