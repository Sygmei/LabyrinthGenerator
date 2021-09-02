require "box";
inspect = require "inspect";

Rooms = {};
Rooms.rooms = {};
Rooms.draw_width = 100;
Rooms.draw_height = 100;
Rooms.walls_thickness = 5;
Rooms.width = 0;
Rooms.height = 0;
Rooms.max_dist = 0;
Rooms.close_coeff = 10/100;
Rooms.fill_rand = 50;
Rooms.close_rand = 85;
Rooms.start_index = 0;
Rooms.finish_index = 0;
Rooms.zones = 0;
Rooms.bg_cache = {};

function Rooms.exists_rand()
  return math.random(100) < Rooms.fill_rand;
end

function Rooms.check_accessible_around(v, disable_c)
  Log.print("Check access around ", v.id);
  local C;
  local ngb = Rooms.check_around(v, true);
  local N, S, W, E;
  
  local A = Rooms.active_rooms(v);
  if disable_c then
    C = A;
  else
    C = Rooms.accessible_rooms(v);
  end
  if ngb.N then
    local NR = Rooms.get(v.x, v.y - 1);
    N = Rooms.accessible_rooms(NR);
    Log.print(NR.id, " (N) has access to ", N);
  else
    N = A;
  end
  if ngb.S then
    local SR = Rooms.get(v.x, v.y + 1);
    S = Rooms.accessible_rooms(SR);
    Log.print(SR.id, " (S) has access to ", S);
  else
    S = A;
  end
  if ngb.W then
    local WR = Rooms.get(v.x - 1, v.y);
    W = Rooms.accessible_rooms(WR);
    Log.print(WR.id, " (W) has access to ", W);
  else
    W = A;
  end
  if ngb.E then
    local ER = Rooms.get(v.x + 1, v.y);
    E = Rooms.accessible_rooms(ER);
    Log.print(ER.id, " (E) has access to ", E );
  else
    E = A;
  end
  Log.print("Result ", A, " C = ", C, "NSWE ", N, " ", S, " ", W, " ", E);
  if C >= A and N >= A and S >= A and W >= A and E >= A then
    return true;
  else
    return false;
  end
end

function Rooms.check_background_duplicate(room)
  Log.print("Check room duplicate for " .. inspect(room))
  for k, v in pairs(Rooms.rooms) do
    --Log.print("Compare with " .. inspect(v));
    if room.id ~= v.id and #room.bg == #v.bg then
      local occ = 0;
      for i = 1, #room.bg do
        if room.bg[i].item == v.bg[i].item then
          if room.bg[i].attr == v.bg[i].attr then
            if room.bg[i].size == v.bg[i].size then
              occ = occ + 1;
            end
          end
        end
      end
      if occ == #room.bg then return true; end
    end
  end
  return false;
end

function Rooms.get_rel(r, dir)
  if dir == "N" then return Rooms.get(r.x, r.y - 1); end
  if dir == "S" then return Rooms.get(r.x, r.y + 1); end
  if dir == "W" then return Rooms.get(r.x - 1, r.y); end
  if dir == "E" then return Rooms.get(r.x + 1, r.y); end
end

function Rooms.opposite_dir(dir)
  local odir = { N = "S", S = "N", W = "E", E = "W" };
  return odir[dir];
end

function Rooms.get_possible_dirs(r)
  local ngb = Rooms.check_around(r);
  Log.print("Check accessible ngb ", inspect(ngb));
  local dirs = {};
  for k, v in pairs(ngb) do
    if v then
      table.insert(dirs, k);
    end
  end
  return dirs;
end

function Rooms.get_zone(amount, avoid)
  local zcol = {
      r = math.random(0.2, 0.8),
      g = math.random(0.2, 0.8),
      b = math.random(0.2, 0.8)
  };
  Log.print("Generating zone of size ", amount);
  avoid = avoid or {};
  Rooms.zones = Rooms.zones + 1;
  local starting_point_found = false;
  local r;
  while not starting_point_found do
    r = pick(Rooms.rooms);
    if not r.used and r.exists and r.zone == 0 and Rooms.check_accessible_around(r) and not Rooms.in_list(r, avoid) then
      starting_point_found = true;
    end
  end
  Log.print("Starting point found : ", r.id);
  local cache = {};
  table.insert(cache, r);
  r.exists = false;
  r.zone = Rooms.zones;
  local deadlock = false;
  while #cache < amount and not deadlock do
    Log.print("Zone building iteration with cache size : ", #cache);
    if not Rooms.in_list(r, cache) then
      Log.print("Adding ", r.id, " to cache");
      table.insert(cache, r);
      r.zone = Rooms.zones;
    end
    local found_ngb = false;
    local dirs = Rooms.get_possible_dirs(r);
    local reroll_it = 1;
    while not found_ngb do
      Log.print("FNGB iteration ", inspect(r), inspect(dirs));
      local dir, ddir = pick(dirs);
      local nr = Rooms.get_rel(r, dir);
      Log.print("Trying to propagate to ", dir, inspect(nr));
      if nr and not nr.used and nr.exists and not Rooms.in_list(nr, cache) and nr.zone == 0 and not Rooms.in_list(nr, avoid) then
        nr.exists = false;
        if Rooms.check_accessible_around(nr) then
          Log.print("Propagating on ", dir);
          r = nr;
          found_ngb = true;
          if reroll_it > 1 then
            reroll_it = reroll_it - 1;
          end
        else
          nr.exists = true;
          Log.print("Can't propagate on ", dir, " (barrage)");
          table.remove(dirs, ddir);
          Log.print("Available possibilities : ", inspect(dirs));
        end
      else
        Log.print("Can't propagate on ", dir);
        table.remove(dirs, ddir);
        Log.print("Available possibilities : ", inspect(dirs));
      end
      if not found_ngb and #dirs == 0 then
        if reroll_it <= #cache then
          r = cache[reroll_it];
          dirs = Rooms.get_possible_dirs(r);
          Log.print("No more available possibilities, rerolling from cache : ", r.id);
          reroll_it = reroll_it + 1;
        else
          Log.print("Cache reroll empty, exitting..");
          deadlock = true;
          break;
        end
      end
    end   
  end
  r.exists = true;
  Log.print("Closing zone, cache content : ", inspect(cache));
  for k, v in pairs(cache) do
    Log.print("Locking zone node ", v.id);
    v.exists = true;
    v.color = zcol;
    local dirs = { "N", "S", "W", "E" };
    v.close_all = true;
    for _, dir in pairs(dirs) do
      local rt = Rooms.get_rel(v, dir);
      if rt and rt.zone == Rooms.zones then    
      else
        Log.print("Locking zone walls ", v.id);
        v.locks[dir] = true;
        v[dir] = false;
        if rt then
          Log.print("Locking opposite side ", rt.id);
          rt.locks[Rooms.opposite_dir(dir)] = true;
          rt[Rooms.opposite_dir(dir)] = false;
        end
      end
    end
  end
  Log.print("Zone created ! ", inspect(cache));
  return cache;
end

function Rooms.generate_background(room)
  room.bg = Box.random_background();
  while Rooms.check_background_duplicate(room) do
    room.bg = Box.random_background();
  end
end

function Rooms.unselect_all()
  for k, v in pairs(Rooms.rooms) do
    v.selected = false;
  end
end

function Rooms.get_selected()
  for k, v in pairs(Rooms.rooms) do
    if v.selected then return v; end
  end
end

function Rooms.active_rooms(r)
  local count = 0;
  for k, v in pairs(Rooms.rooms) do
    local cz = true;
    if r then cz = (v.zone == r.zone); end
    if v.exists and not v.used and cz then
      count = count + 1;
    end
  end
  return count;
end  

function Rooms.create(x, y)
  local doors = { N = true, S = true, W = true, E = true };
  table.insert(Rooms.rooms, {
    id = #Rooms.rooms + 1,
    x = x,
    y = y,
    content = {},
    selected = false,
    exists = true,
    N = doors.N,
    S = doors.S,
    W = doors.W,
    E = doors.E,
    start = false,
    finish = false,
    bg = {},
    used = false,
    color = { r = 0.4, g = 0.4, b = 0.4 },
    close_all = false,
    locks = {},
    zone = 0,
    dont_delete = false
  });
end

function Rooms.random_doors()
  return {
      N = math.random(100) < Rooms.close_rand,
      S = math.random(100) < Rooms.close_rand,
      W = math.random(100) < Rooms.close_rand,
      E = math.random(100) < Rooms.close_rand
  }
end

function Rooms.get(x, y)
  for k, v in pairs(Rooms.rooms) do
    if v.x == x and v.y == y then
      return v;
    end
  end
end

function Rooms.check_around(room, ignore_doors)
  local around = {
      N = false,
      S = false,
      W = false,
      E = false
  };
  local x = room.x;
  local y = room.y;
  local RW = Rooms.get(x - 1, y);
  local RE = Rooms.get(x + 1, y);
  local RN = Rooms.get(x, y - 1);
  local RS = Rooms.get(x, y + 1);
  local doors;
  if ignore_doors then
    doors = { N = true, S = true, W = true, E = true };
    if room.locks.N then doors.N = false; end
    if room.locks.S then doors.S = false; end
    if room.locks.W then doors.W = false; end
    if room.locks.E then doors.E = false; end
  else
    doors = { 
      N = room.N,
      S = room.S,
      W = room.W,
      E = room.E
    };
  end
  if doors.W and room.x > 0 and RW and RW.exists then
    around.W = true;
  end
  if doors.E and room.x < Rooms.width and RE and RE.exists then
    around.E = true;
  end
  if doors.N and room.y > 0 and RN and RN.exists then
    around.N = true;
  end
  if doors.S and room.y < Rooms.height and RS and RS.exists then
    around.S = true;
  end
  return around;
end

function Rooms.in_list(elem, list)
  for k, v in pairs(list) do
    if elem.id == v.id then
      return true;
    end
  end
  return false;
end

function Rooms.accessible_rooms(room1, cache)
  cache = cache or {};
  local in_cache = Rooms.in_list(room1, cache);
  if not in_cache then
    table.insert(cache, room1);
    local ngb = Rooms.check_around(room1);
    local nd = {
        N = Rooms.max_dist,
        S = Rooms.max_dist,
        W = Rooms.max_dist,
        E = Rooms.max_dist
    };
    local NR = Rooms.get(room1.x, room1.y - 1);
    if ngb.N and not Rooms.in_list(NR, cache) then
      nd.N = Rooms.accessible_rooms(NR, cache);
    end
    local NS = Rooms.get(room1.x, room1.y + 1);
    if ngb.S and not Rooms.in_list(NS, cache) then
      nd.S = Rooms.accessible_rooms(NS, cache);     
    end
    local NW = Rooms.get(room1.x - 1, room1.y);
    if ngb.W and not Rooms.in_list(NW, cache) then
      nd.W = Rooms.accessible_rooms(NW, cache);
    end
    local NE = Rooms.get(room1.x + 1, room1.y);
    if ngb.E and not Rooms.in_list(NE, cache)then
      nd.E = Rooms.accessible_rooms(NE, cache);
    end
  end
  return #cache;
end

function Rooms.draw(room)
  local ccx = Rooms.draw_width / 2 -(Rooms.close_coeff / 2 * Rooms.draw_width);
  local ccw = Rooms.draw_width * Rooms.close_coeff;
  local ccy = Rooms.draw_height / 2 -(Rooms.close_coeff / 2 * Rooms.draw_height);
  local cch = Rooms.draw_height * Rooms.close_coeff;
  love.graphics.setColor(0.25, 0.25, 0.25, 1);
  love.graphics.rectangle("fill", room.x * Rooms.draw_width, room.y * Rooms.draw_height, Rooms.draw_width, Rooms.draw_height);
  if room.exists then
    if not room.selected then
      love.graphics.setColor(room.color.r, room.color.g, room.color.b, 255);
    else
      love.graphics.setColor(0, 0.8, 0.8, 1);
    end
    love.graphics.rectangle("fill", room.x * Rooms.draw_width + Rooms.walls_thickness, room.y * Rooms.draw_height + Rooms.walls_thickness, Rooms.draw_width - 2 * Rooms.walls_thickness, Rooms.draw_height - 2 * Rooms.walls_thickness);
    local ngb = Rooms.check_around(room);
    if ngb.N then
      love.graphics.rectangle("fill", room.x * Rooms.draw_width + ccx, room.y * Rooms.draw_height, ccw, Rooms.walls_thickness);
    end
    if ngb.S then
      love.graphics.rectangle("fill", room.x * Rooms.draw_width + ccx, room.y * Rooms.draw_height + Rooms.draw_height - Rooms.walls_thickness, ccw, Rooms.walls_thickness);
    end
    if ngb.W then
      love.graphics.rectangle("fill", room.x * Rooms.draw_width, room.y * Rooms.draw_height + ccy, Rooms.walls_thickness, cch);
    end
    if ngb.E then
      love.graphics.rectangle("fill", room.x * Rooms.draw_width + Rooms.draw_width - Rooms.walls_thickness, room.y * Rooms.draw_height + ccy, Rooms.walls_thickness, cch);
    end
  end
  love.graphics.setColor(1, 1, 1, 1);
  if #room.content > 0 then
    love.graphics.rectangle("fill", room.x * Rooms.draw_width + Rooms.walls_thickness, room.y * Rooms.draw_height + Rooms.walls_thickness, Rooms.draw_width / 2, Rooms.draw_height / 2);
  end
  love.graphics.print(tostring(room.id) .. " (" .. tostring(room.x) .. ", " .. tostring(room.y) .. ")", room.x * Rooms.draw_width + Rooms.draw_width / 3, room.y * Rooms.draw_height + Rooms.draw_height / 3);
  local sr = Rooms.get_selected();
  if sr then
    local sr_info = "";
    for k, v in pairs(sr.bg) do
      sr_info = sr_info .. v.size .. " " .. v.item .. " " .. v.attr .. "\n";
    end
    love.graphics.setNewFont(32);
    love.graphics.print(sr_info, 1300, 0);
    local content_info = "";
    for k, v in pairs(sr.content) do
      content_info = content_info .. "> "  .. v.item .. "\n";
    end
    love.graphics.print(content_info, 1300, 300);
  end
end