buttons = {}

Button = {}
Button.prototype = {
  x = 1, y = 1, 
  width = 12, height = 1,
  
  text = "Button",
  textOn = "On",
  textOff = "Off",
  monitor = nil,
  
  state = true,
  toggle = false,
  colourOff  = colors.red,
  colourOn   = colors.green,
  textColour = colors.white, 
  
  onClick = function()
    print("No onClick function defined")
  end
}

-- Button Metatable
-- Used for default values
Button.mt = {}
Button.mt.__index = function (table, key)
  return Button.prototype[key]
end

function Button:new(o)
  o = o or {}
  setmetatable(o, Button.mt)
  buttons[#buttons+1] = o
  return o
end

function Button.draw(button)
  local oldx, oldy = term.getCursorPos()
  if button.monitor then
    term.redirect(button.monitor)
  else
    term.redirect(term.native())
  end
  
  if button.state then
    term.setBackgroundColor(button.colourOn)
  else
    term.setBackgroundColor(button.colourOff)
  end

  term.setCursorPos(button.x, button.y)

  x1, y1, x2, y2 = Button.getBounds(button)
  for j = y1, y2 do
    for i = x1, x2 do
      term.setCursorPos(i, j)
      term.write(" ")
    end
  end

  local xmid = math.floor(((x2 + x1) - string.len(button.text)) / 2)
  local ymid = math.floor((y2 + y1) / 2)
  term.setCursorPos(xmid, ymid)
  term.write(button.text)
  term.setBackgroundColor(colors.black)
  term.redirect(term.native())
  term.setCursorPos(oldx, oldy)
end

function Button.click(button)
  if not button.toggle then
    button.state = false
    Button.draw(button)
    button.onClick()
    button.state = true
    Button.draw(button)
  else
    button.state = not button.state
    button.onClick(button.state)
    Button.draw(button)
  end
end

-- Returns the four corner coordinates of the button
function Button.getBounds(button)
  return button.x, button.y, (button.x + button.width), (button.y + button.height - 1)
end

function Button.inBounds(button, x, y)
  x1, y1, x2, y2 = Button.getBounds(button)
  return (x >= x1) and (x <= x2) and (y >= y1) and (y <= y2)
end

function Button.updateLoop()
  while true do
    for i, button in pairs(buttons) do
      Button.draw(button)
    end
    
    -- Wait for a click event
    event, side, x, y = os.pullEvent()
    if event == "mouse_click" or event == "monitor_touch" then
      for i, button in pairs(buttons) do
        if Button.inBounds(button, x, y) then
          Button.click(button)
        end
      end
    end
  end
end

-- Function to be used with EventListener.lua
-- When called, it checks the buttons table to see if any buttons have been
-- clicked, if so, it calls click on that function
function Button.eventHandler(event)
  Button.drawAll()

  eventType, side, x, y = unpack(event)
  if eventType == "mouse_click" or eventType == "monitor_touch" then
    for i, button in pairs(buttons) do
      if Button.inBounds(button, x, y) then
        Button.click(button)
        break
      end
    end
  end
end

function Button.drawAll()
  for i, button in pairs(buttons) do
    Button.draw(button)
  end
end