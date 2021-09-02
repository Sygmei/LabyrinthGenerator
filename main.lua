require "log";
require "util";
require "generation";
require "rooms";
require "ui";

function love.load()
  success = love.window.setMode( 1920, 1080 )
  math.randomseed(os.time());
  Log.print("Save folder : " .. love.filesystem.getSaveDirectory());
  local f, e = love.filesystem.newFile("log.txt", "w");
  Log.print("Dungeon v0.0.1");
  Ui.init();
  create_dungeon(10, 10);
end

function love.draw()
  love.graphics.clear(0, 0, 0);
  love.graphics.setNewFont(10);
  for k, v in pairs(Rooms.rooms) do
    Rooms.draw(v);
    love.graphics.setNewFont(10);
  end
  Log.draw();
  Ui.draw();
end

function love.mousepressed(x, y, button, istouch, pressure)
  for k, v in pairs(Rooms.rooms) do
    if x > v.x * Rooms.draw_width and y > v.y * Rooms.draw_height then
      if x < v.x * Rooms.draw_width + Rooms.draw_width and y < v.y * Rooms.draw_height + Rooms.draw_height then
        Rooms.unselect_all();
        v.selected = true;
      end
    end
  end
  --create_dungeon(10, 10);
  Ui.touchpressed(x, y, button, istouch, pressure);
end

function love.keypressed(key)
  if key == "escape" then
     love.event.quit()
  end
end

function love.update(dt)
  Ui.update(dt);
end