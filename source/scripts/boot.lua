-- This code is licensed under the MIT Open Source License.

-- Copyright (c) 2016 Ruairidh Carmichael - ruairidhcarmichael@live.co.uk

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-- This is a bit messy
-- But it means we can move stuff out of main.c

package.path = './?.lua;./?/init.lua'
package.cpath = './?.lua;./?/init.lua'

local config = 
{
    console = false,
    version = "1.0.0",
    identity = "SuperGame"
}


if love.filesystem.getInfo("conf.lua") then
    success, err = pcall(require, 'conf')

    if success and love.conf then
        love.conf(config)
    end
end

in_error = false
love.filesystem.setIdentity(config.identity)

__defaultFont = love.graphics.newFont()
love.graphics.setFont(__defaultFont)

function love.createhandlers()
    -- Standard callback handlers.
    love.handlers = setmetatable({
        load = function()
            if love.load then
                return love.load()
            end
        end,
        update = function(dt)
            if love.update then
                return love.update(dt)
            end
        end,
        draw = function()
            if love.draw then
                return love.draw()
            end
        end,
        keypressed = function (key)
            if love.keypressed then 
                return love.keypressed(key) 
            end
        end,
        keyreleased = function (key)
            if love.keyreleased then 
                return love.keyreleased(key) 
            end
        end,
        mousemoved = function (x,y,dx,dy,t)
            if love.mousemoved then 
                return love.mousemoved(x,y,dx,dy,t) 
            end
        end,
        mousepressed = function (x, y, button)
            if love.mousepressed then 
                return love.mousepressed(x, y, button) 
            end
        end,
        mousereleased = function (x, y, button)
            if love.mousereleased then 
                return love.mousereleased(x, y, button)
            end
        end,
        joystickpressed = function (joystick, button)
            if love.joystickpressed then 
                return love.joystickpressed(joystick, button)
            end
        end,
        joystickreleased = function (joystick, button)
            if love.joystickreleased then 
                return love.joystickreleased(joystick, button)
            end
        end,
        joystickaxis = function (joystick, axis, value)
            if love.joystickaxis then 
                return love.joystickaxis(joystick, axis, value)
            end
        end,
        joystickhat = function (joystick, hat, value)
            if love.joystickhat then 
                return love.joystickhat(joystick, hat, value) 
            end
        end,
        gamepadpressed = function (joystick, button)
            if love.gamepadpressed then 
                return love.gamepadpressed(joystick, button)
            end
        end,
        gamepadreleased = function (joystick, button)
            if love.gamepadreleased then 
                return love.gamepadreleased(joystick, button)
            end
        end,
        gamepadaxis = function (joystick, axis, value)
            if love.gamepadaxis then 
                return love.gamepadaxis(joystick, axis, value)
            end
        end,
        textinput = function(text)
            if love.textinput then 
                return love.textinput(text) 
            end
        end,
        focus = function (focus)
            if love.focus then 
                return love.focus(focus) 
            end
        end,
        visible = function (visible)
            if love.visible then 
                return love.visible(visible) 
            end
        end,
        quit = function ()
            if love.quit then
                return love.quit()
            end
        end,
        threaderror = function (t, err)
            if love.threaderror then return love.threaderror(t, err) end
        end,
        lowmemory = function ()
            collectgarbage()
            if love.lowmemory then return love.lowmemory() end
        end
    }, {
        __index = function(self, name)
            error('Unknown event: ' .. name)
        end,
    })

end

love.createhandlers()

function love.errhand(message)
    message = tostring(message)

    message = message:gsub("^(./)", "")

    local err = {}
    in_error = true

    local major, minor, rev = love.getVersion()

    table.insert(err, message .. "\n")
    
    love.audio.stop()

    local trace = debug.traceback()
    
    for l in trace:gmatch("(.-)\n") do
        if not l:match("boot.lua") then
            l = l:gsub("stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end
    
    table.insert(err, "\nLove Potion " .. love.getVersion(true) .. " (API " .. major .. "." .. minor .. "." .. rev .. ")")
    
    dateTime = os.date("%c")
    table.insert(err, "\nA log has been saved to " .. love.filesystem.getSaveDirectory() .. "log.txt")
    
    local realError = table.concat(err, "\n")
    realError = realError:gsub("\t", "")
    realError = realError:gsub("%[string \"(.-)\"%]", "%1")
    
    love.filesystem.write("log.txt", realError)
    
    love.graphics.setBackgroundColor(0.35, 0.62, 0.86)
    --love.graphics.clear()

    love.graphics.setColor(1, 1, 1, 1)
    
    love.graphics.setFont(__defaultFont)

    local error_img = love.graphics.newImage("error:warn");
    local plus_img = love.graphics.newImage("error:plus");

    local function draw()
        love.graphics.clear("top")

        love.graphics.setScreen("top")

        love.graphics.print(realError, 30, 16)

        love.graphics.draw(plus_img, 324, 220)
        love.graphics.print("Quit", 340, 220)

        love.graphics.present()

        love.graphics.setColor(1, 1, 1)
        
        love.graphics.clear("bottom")

        love.graphics.setScreen("bottom")

        love.graphics.draw(error_img, 96, 56)

        love.graphics.present()
    end

    --local joycon = love.joystick.getJoysticks()[1]

    while true do
        draw()

        --[[if joycon:isGamepadDown("plus") then
            break
        end]]

        love.timer.sleep(0.1)
    end

    --love.event.quit()
end 

local function pseudoRequireMain()
    return require("main")
end

local function gameFailure()
    return error("Failed to load game!")
end

if love.filesystem.getInfo("main.lua") then
    --Try main
    local result = xpcall(pseudoRequireMain, love.errhand)
    if not result then
        return
    end

    --See if loading works
    result = xpcall(love.load, love.errhand)
    if not result then
        return
    end

    --Run the thing dammit
    result = xpcall(love.run, love.errhand)
    if not result then
        return
    end
else
    xpcall(love._nogame, love.errhand)
end

if love.timer then
    love.timer.step()
end