Log = {};
Log.log = {};

function Log.print(...)
  local text = "";
  for i,v in pairs({...}) do
    text = text .. tostring(v);
  end
  table.insert(Log.log, text);
  love.filesystem.append("log.txt", text .. "\n");
end

function Log.draw()
  love.graphics.setColor(1, 1, 1, 1);
  local log_txt = "";
  local minlog = #Log.log - 76;
  if minlog < 1 then minlog = 1; end
  for i = minlog, #Log.log do
    log_txt = log_txt .. Log.log[i] .. "\n";
  end
  love.graphics.print(log_txt, love.graphics.getWidth() / 2 + 10, 0)
end

return Log;