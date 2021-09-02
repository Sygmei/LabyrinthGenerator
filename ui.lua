Ui = {};
Ui.widgets = {};
Ui.tags = {
    R = { 
      id = 0, 
      x = 300,
      y = 100,
      r = 1, g = 0, b = 0
    },
    G = {
      id = 0,
      x = 200,
      y = 100,
      r = 0, g = 1, b = 0
    },
    B = {
      id = 0,
      x = 100,
      y = 100,
      r = 0, g = 0, b = 1
    }
};

function Ui.set_tag_index(tag)
  if Rooms.get_selected() then
    Ui.tags[tag].id = Rooms.get_selected().id;
  end
end

function Ui.button(text, x, y, width, height, color, callback)
  table.insert(Ui.widgets, {
      type = "button",
      text = text,
      x = x,
      y = y, 
      width = width,
      height = height,
      color = color,
      callback = callback
  });
end

function Ui.init()
  for k, v in pairs(Ui.tags) do
    Ui.button(k, love.graphics.getWidth() - v.x, love.graphics.getHeight() - v.y, 100, 100, { r = v.r, g = v.g, b = v.b}, function()
      local s = Rooms.get_selected();
      if s then
        if s.id == v.id then 
          v.id = 0;
        else
          v.id = s.id;
        end
      end
    end);
  end
end

function Ui.update(dt)
end

function Ui.draw()
  Ui.draw_tags();
  for k, v in pairs(Ui.widgets) do
    love.graphics.setColor(v.color.r, v.color.g, v.color.b, 1);
    love.graphics.rectangle("fill", v.x, v.y, v.width, v.height);
    love.graphics.setColor(1, 1, 1, 1);
    love.graphics.setNewFont(42);
    love.graphics.printf(v.text, v.x, v.y + v.height / 2, v.width, "center");
  end
end

function Ui.draw_tags()
  for k, v in pairs(Ui.tags) do
    local r = Rooms.rooms[v.id];
    if r then
      love.graphics.setColor(v.r, v.g, v.b, 1);
      love.graphics.circle("fill", r.x * Rooms.draw_width + Rooms.draw_width / 2, r.y * Rooms.draw_height + Rooms.draw_height / 2, math.min(Rooms.draw_width, Rooms.draw_height) / 5);
    end
  end
end

function Ui.touchpressed(x, y, button, istouch, pressure)
  for k, v in pairs(Ui.widgets) do
    if x > v.x and x < v.x + v.width and y > v.y and y < v.y + v.height then
      v.callback();
    end
  end
end