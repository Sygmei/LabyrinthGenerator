function deepcopy(orig) 
  local orig_type = type(orig) 
  local copy 
  if orig_type == 'table' then
    copy = {} 
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end 
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else 
    copy = orig 
  end 
  return copy 
end

function table_size(list)
  local size = 0;
  for k, v in pairs(list) do
    size = size + 1;
  end
  return size;
end

function pick(list)
  --Log.print("Started pick func");
  local size = table_size(list);
  local sel = math.random(1, size);
  local index = 1;
  --Log.print("Size " .. tostring(size) .. " sel " .. tostring(sel));
  for k, v in pairs(list) do
    if index == sel then
      --Log.print("Picked index : " .. tostring(index) .. " = " .. inspect(v) .. " on " .. tostring(size));
      return v, k;
    end
    index = index + 1;
  end
end