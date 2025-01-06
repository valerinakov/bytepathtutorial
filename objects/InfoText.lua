InfoText = GameObject:extend()

function InfoText:new(area,x,y,opts)
    InfoText.super.new(self,area,x,y,opts)

    self.font = fonts.m5x7_16
    love.graphics.setFont(self.font)

    self.depth = 80

    self.characters = {}
    self.background_colors = {}
    self.foreground_colors = {}
    self.visible = true

    -- print('inside info' .. self.text)    

    for i = 1, #self.text do table.insert(self.characters, self.text:utf8sub(i, i)) end

    self.timer:after(0.70, function () 
        self.timer:every(0.05, function () self.visible = not self.visible end, 6)
        self.timer:every(0.035, function () 
            local random_characters = '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
            for i, character in ipairs(self.characters) do
                if love.math.random(1,20) <= 4 then
                    local r = love.math.random(1, #random_characters)
                    self.characters[i] = random_characters:utf8sub(r,r)
                else
                    self.characters[i] = character
                end

                if love.math.random(1,10) <= 3 then
                    self.background_colors[i] = table.random(all_colors)
                else
                    self.background_colors[i] = nil
                end

                if love.math.random(1,20) <=1 then
                    self.foreground_colors[i] = table.random(all_colors)
                else
                    self.background_colors[i] = nil
                end
            end
        end)

        self.timer:after(0.35, function () self.visible = true end)
    end)

    self.timer:after(1.10, function() self.dead = true end)

    local all_info_texts = self.area:getAllGameObjectsThat(function(o) 
        if o:is(InfoText) and o.id ~= self.id then 
            return true 
        end 
    end)

    if all_info_texts then
        local fontHeight = self.font:getHeight()
        for _,v in pairs(all_info_texts) do
            local heightDifference =  (self.y - self.font:getHeight()) - (v.y - self.font:getHeight())
            if heightDifference < 0 then
                heightDifference = -heightDifference
            end

            if heightDifference < fontHeight then
                self.y = self.y + fontHeight
            end
        end
    end
end

function InfoText:update(dt)
    InfoText.super.update(self,dt)
end

function InfoText:draw()
    if not self.visible then return end


    for i = 1, #self.characters do 
        local width = 0
        if i > 1 then
            for j = 1, i-1 do
                width = width + self.font:getWidth(self.characters[j])
            end
        end
        if self.background_colors[i] then 
            love.graphics.setColor(self.background_colors[i])
            love.graphics.rectangle('fill', self.x + width, self.y - self.font:getHeight()/2, self.font:getWidth(self.characters[i]), self.font:getHeight())
        end

        if self.foreground_colors[i] then
            love.graphics.setColor(love.math.colorFromBytes(self.foreground_colors[i]))
        else
            love.graphics.setColor(love.math.colorFromBytes(self.color))
        end
        -- love.graphics.setColor(love.math.colorFromBytes(self.foreground_colors[i]) or love.math.colorFromBytes(self.color) or love.math.colorFromBytes(default_color) )
        love.graphics.print(self.characters[i], self.x + width, self.y,0,1,1,0,self.font:getHeight()/2)
    end
    love.graphics.setColor(love.math.colorFromBytes(default_color))
end