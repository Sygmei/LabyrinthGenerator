require "rooms";

used_colors = {};

function close_some_rooms()
  Log.print("Closing some rooms' doors");
  for k, v in pairs(Rooms.rooms) do
    if not v.used then
      local run_once = true;
      while not Rooms.check_accessible_around(v) or run_once do
        local r = Rooms.random_doors();
        local vlN = Rooms.get(v.x, v.y - 1);
        if vlN then vlN = vlN.locks.S; end
        local vlS = Rooms.get(v.x, v.y + 1);
        if vlS then vlS = vlS.locks.N; end
        local vlW = Rooms.get(v.x - 1, v.y);
        if vlW then vlW = vlW.locks.E; end
        local vlE = Rooms.get(v.x + 1, v.y);
        if vlE then vlE = vlE.locks.W; end
        if vlN then v.N = false; else v.N = r.N; end      
        if vlS then v.S = false; else v.S = r.S; end 
        if vlW then v.W = false; else v.W = r.W; end 
        if vlE then v.E = false; else v.E = r.E; end 
        Log.print("NSWE Closure ", v.N, v.S, v.W, v.E);
        run_once = false;
      end
    end
  end
end

function disable_some_rooms()
  Log.print("Disabling some rooms");
  for k, v in pairs(Rooms.rooms) do
    if not v.used and v.id ~= Rooms.start_index and v.id ~= Rooms.finish_index and not v.dont_delete and Rooms.exists_rand() then
      v.exists = false;
      Log.print("Trying to disable room ", v.id);
      if not Rooms.check_accessible_around(v, true) then
        v.exists = true;
      end
    end
  end
end

function backup_doors(room, doors)
  if doors then
    room.N = doors.N;
    room.S = doors.S;
    room.W = doors.W;
    room.E = doors.E;
  else
    return { N = room.N, S = room.S, W = room.W, E = room.E };
  end
end

function close_all_doors(room)
  room.N = false;
  room.S = false;
  room.W = false;
  room.E = false;
end

function generate_chest()
  return { item = "lol" };
end

function add_chest(room, cont)
  if cont then
    table.insert(room.content, cont);
  else
    table.insert(room.content, generate_chest());
  end
end

function all_different(...)
  local cache = {};
  for k, v in pairs({...}) do
    if cache[v] then
      return false;
    else
      cache[v] = true;
    end
  end
  return true;
end

function put_key(col, in_closed)
  Log.print("Placing key..");
  local placed_key = false;
  while not placed_key do 
    local keyr = pick(Rooms.rooms);
    if keyr.exists then
      if in_closed and keyr.used and keyr.color.name ~= col.name then
       placed_key = true;
       Log.print("Putting key in room ", keyr.id);
     elseif not in_closed and not keyr.used then
       placed_key = true;
     end
     if placed_key then
       add_chest(keyr, {
         item = "key",
         color = rcol;
       });
       keyr.dont_delete = true;
     end
   end
 end
 Log.print("Key placed");
end

function close_required_doors()
  Log.print("Closing required doors");
  for k, v in pairs(Rooms.rooms) do
    if not v.used and v.zone == 0 then
      local ngb = Rooms.check_around(v, true);
      local NR = Rooms.get(v.x, v.y - 1);
      local SR = Rooms.get(v.x, v.y + 1);
      local WR = Rooms.get(v.x - 1, v.y);
      local ER = Rooms.get(v.x + 1, v.y);
      if ngb.N and NR.close_all then
        v.N = false;
      end
      if ngb.S and SR.close_all then
        v.S = false;
      end
      if ngb.W and WR.close_all then
        v.W = false;
      end
      if ngb.E and ER.close_all then
        v.E = false;
      end
    end
  end
end

function generate_door_with_key(size, key_in_closed)
  Log.print("Generating room with key of size ", size);
  local ok = false;
  local found_color = false;
  local rcol;
  while not found_color do
    rcol = pick(Box.colors);
    Log.print("Iterating color found ", inspect(rcol));
    local dup = false;
    for k, v in pairs(used_colors) do
      Log.print("Check for dup ", inspect(v));
      if rcol.name == v.name then 
        dup = true; 
        break; 
      end
    end
    if not dup then found_color = true; end
  end
  table.insert(used_colors, rcol);
  Log.print("Picked color : ", inspect(rcol));
  while not ok do
    local r1 = pick(Rooms.rooms);
    if size == 1 then
      if r1.x > 0 and r1.x < Rooms.width - 1 then
        if r1.y > 0 and r1.y < Rooms.height - 1 then
          if not r1.used and all_different(r1.id, Rooms.start_index, Rooms.finish_index) then
            close_all_doors(r1);
            r1.close_all = true;
            r1.locks = {
                N = true;
                S = true;
                W = true;
                E = true;
            };
            r1[pick({"N", "S", "W", "E"})] = {
                cond = "key",
                color = col
            };
            add_chest(r1);
            r1.used = true;
            r1.color = rcol;
            put_key(rcol, key_in_closed);
            ok = true;
          end
        end
      end
    elseif size == 2 then
    if r1.x > 0 and r1.x < Rooms.width - 3 then
      if r1.y > 0 and r1.y < Rooms.height - 3 then
        local r2 = Rooms.get(r1.x + 1, r1.y);  
        local r3 = Rooms.get(r1.x, r1.y + 1) 
        local r4 = Rooms.get(r1.x + 1, r1.y + 1);
        if not r1.used and not r2.used and not r3.used and not r4.used and all_different(r1.id, r2.id, r3.id, r4.id, Rooms.start_index, Rooms.finish_index) then
          Log.print("Creating 2x2 room on ", r1.id);
          close_all_doors(r1);
          close_all_doors(r2);
          close_all_doors(r3);
          close_all_doors(r4);
          r1.S = true; r1.E = true;
          r2.S = true; r2.W = true;
          r3.N = true; r3.E = true;
          r4.N = true; r4.W = true;
          r1.close_all = true;
          r1.locks = { N = true, W = true };
          r2.close_all = true;
          r2.locks = { N = true, E = true };
          r3.close_all = true;
          r3.locks = { S = true, W = true };
          r4.close_all = true;
          r4.locks = { S = true, E = true };
          local entrance = pick({ r1, r2, r3, r4 });
          local not_entrance = false;
          local dirs = { "N", "S", "W", "E" };
          while not not_entrance do
            Log.print("Loop entrance");
            local dir = pick(dirs);
            if not entrance[dir] then
              entrance[dir] = {
                  cond = "key",
                  color = rcol
              };
              not_entrance = true;
            end
          end
          Log.print("Entrance created");
          local chest = pick({ r1, r2, r3, r4 });
          add_chest(chest);
          r1.used = true;
          r2.used = true;
          r3.used = true;
          r4.used = true;
          r1.color = rcol;
          r2.color = rcol;
          r3.color = rcol;
          r4.color = rcol;
          put_key(rcol, key_in_closed);
          ok = true;
        end
      end
    end
    end
  end
end

function generate_zone_with_tp()
  Log.print("Generating zone with tp");
  local zone = Rooms.get_zone(math.random(10, 30));
  local zone_tp = pick(zone);
  table.insert(zone_tp.content, {
      item = "tp"
  });
  zone_tp.dont_delete = true;
  local found_tp = false;
  while not found_tp do
    local r = pick(Rooms.rooms);
    if r.zone ~= Rooms.zones and not r.used then
      table.insert(r.content, {
          item = "tp"
      });
      r.dont_delete = true;
      found_tp = true;
    end
  end
end

function generate_quest()

end

function generate_npc()
  local found_npc = false;
  while not found_npc do
    local r = pick(Rooms.rooms);
    if r.exists and not r.used then
      table.insert(r.content, {
        item = "NPC",
        quest = generate_quest(r)
      });
      r.dont_delete = true;
    end
  end
end

function create_dungeon(width, height)
  Log.print("Clearing rooms");
  Rooms.rooms = {};
  Log.print("Filling dungeon");
  for x = 0, width - 1 do
    for y = 0, height - 1 do
      Rooms.create(x, y);
    end
  end
  Log.print("Generating start_index");
  local start_index = math.random(#Rooms.rooms);
  Rooms.rooms[start_index].start = true;
  Rooms.rooms[start_index].color = { 
    r = 100,
    g = 255,
    b = 100
  };
  Log.print("Generating finish_index");
  local finish_index = math.random(#Rooms.rooms);
  while Rooms.rooms[finish_index].start do
    finish_index = math.random(#Rooms.rooms);
  end
  Rooms.rooms[finish_index].finish = true;
  Rooms.rooms[finish_index].color = {
      r = 255,
      g = 100,
      b = 100
  };
  Rooms.start_index = start_index;
  Rooms.finish_index = finish_index;
  Log.print("Calculating dimensions");
  Rooms.draw_width = love.graphics.getWidth() / width / 2;
  Rooms.draw_height = love.graphics.getHeight() / height;
  Rooms.width = width;
  Rooms.height = height;
  Rooms.max_dist = width * height;
  local dist = Rooms.accessible_rooms(Rooms.rooms[start_index]);
  Log.print("Dungeon created, start = ", start_index, ", finish = ", finish_index, ", rooms = ", dist);
  Log.print("Creating room with key 1");
  generate_door_with_key(1);
  Log.print("Creating room with key 2");
  generate_door_with_key(2, true);
  Log.print("Creating zone");
  generate_zone_with_tp();
  generate_zone_with_tp();
  Log.print("Closing required doors");
  close_required_doors();
  Log.print(inspect(Rooms.rooms));
  close_some_rooms();
  disable_some_rooms();
  for k, v in pairs(Rooms.rooms) do
    Rooms.generate_background(v);
  end
end