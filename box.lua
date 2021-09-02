Box = {};
Box.materials = {
    { name = "Wood", r = 1 },
    { name = "Stone", r = 2 },
    { name = "Copper", r = 4 },
    { name = "Iron", r = 6 },
    { name = "Steel", r = 10 },
    { name = "Silver", r = 15 },
    { name = "Gold", r = 30 }, 
    { name = "Platinum", r = 70 },
    { name = "Obsidian", r = 150 },
    { name = "Diamond", r = 300 },
    { name = "Cobalt", r = 500 },
    { name = "Mithril", r = 1500 },
    { name = "Titanium", r = 5000 },
    { name = "Vibranium", r = 15000 },
    { name = "Void", r = 100000 }
};

Box.furniture_materials = {
    { name = "Oak" },
    { name = "Emerald" },
    { name = "Marble" },
    { name = "Sapphire" },
    { name = "Rubis" },
    { name = "Pearl" },
    { name = "Birch" },
    { name = "Cork" },
    { name = "Elm" },
    { name = "Pine" },
    { name = "Walnut" },
    { name = "Amber" },
    { name = "Amethyst" },
    { name = "Beryl" },
    { name = "Chrome" },
    { name = "Jade" },
    { name = "Quartz" },
    { name = "Onyx" },
    { name = "Bone" },
    { name = "Glass" }
};

Box.soft_materials = {
    { name = "Silk" },
    { name = "Leather" },
    { name = "Wool" },
    { name = "Cotton" },
    { name = "Linen" },
    { name = "Velvet" },
    { name = "Fur" },
    { name = "Nylon" },
    { name = "Flannel" },
    { name = "Chiffon" },
    { name = "Crepe" },
    { name = "Satin" },
    { name = "Tweed" },
    { name = "Voile" },
    { name = "Feather" },
    { name = "Grass" }
};

Box.colors = {
    { name = "Red", r = 255, g = 0, b = 0 },
    { name = "Blue", r = 0, g = 0, b = 255 },
    { name = "Green", r = 0, g = 255, b = 0 },
    { name = "Yellow", r = 255, g = 255, b = 0 },
    { name = "Magenta", r = 255, g = 0, b = 255 },
    { name = "Cyan", r = 0, g = 255, b = 255 },
    { name = "White", r = 255, g = 255, b = 255 }
};

Box.rare_colors = {
    { name = "Crimson", r = 153, g = 0, b = 0 },
    { name = "Ivory", r = 255, g = 255, b = 240 },
    { name = "Scarlet", r = 255, g = 36, b = 0 },
    { name = "Lilac", r = 200, g = 162, b = 200 },
    { name = "Orchid", r = 218, g = 112, b = 214 },
    { name = "Teal", r = 0, g = 128, b = 128 },
    { name = "Lapis", r = 38, g = 97, b = 156 },
    { name = "Artic", r = 0, g = 202, b = 231 },
    { name = "Azure", r = 0, g = 127, b = 255 },
    { name = "Juniper", r = 63, g = 112, b = 69 },
    { name = "Mint", r = 152, g = 255, b = 152 },
};

Box.furnitures = {
    { name = "Statue", 
      compat = "MCRN" }, 
    { name = "Vase",
      compat = "MCRN" },
    { name = "Fresco",
      compat = "CR" },
    { name = "Painting",
      compat = "CR" },
    { name = "Stone",
      compat = "CR" },
    { name = "Pillar",
      compat = "MN" },
    { name = "Torch",
      compat = "MN" },
    { name = "Carpet",
      compat = "S" },
    { name = "Chandelier",
      compat = "MCRN" },
    { name = "Bucket",
      compat = "MN" },
    { name = "Bench", 
      compat = "MCRN"},
    { name = "Curtain",
      compat = "S" },
    { name = "Bed",
      compat = "S" },
    { name = "Wardrobe",
      compat = "MCRN" },
    { name = "Coat hanger",
      compat = "MCRN" }
};

Box.sizes = {
    "Tiny",
    "Small",
    "Medium",
    "Big",
    "Huge",
    "Gigantic"
};

Box.adjectives = {
    "Beautiful",
    "Wet",
    "Creepy",
    "Ugly"
};

Box.shortcuts = {
    A = Box.adjectives,
    C = Box.colors,
    F = Box.furnitures,
    M = Box.materials,
    N = Box.furniture_materials,
    R = Box.rare_colors,
    S = Box.soft_materials,
    X = Box.sizes
}

function Box.random_furniture()
  local furniture = {};
  furniture.item = pick(Box.furnitures);
  furniture.size = pick(Box.sizes);
  Log.print("Picked ITEM " .. inspect(furniture.item));
  local rix = math.random(1, #furniture.item.compat);
  local rand_attr = furniture.item.compat:sub(rix, rix);
  furniture.attr = pick(Box.shortcuts[rand_attr]).name;
  furniture.item = furniture.item.name;
  return furniture;
end

function Box.random_background()
  local a = math.random(100);
  local n = 1;
  if a > 85 then n = 2; end
  if a > 95 then n = 3; end
  Log.print("Creating background with " .. tostring(n) .. " furnitures");
  local bg = {};
  for i = 1, n do
    Log.print("Inserting furniture " .. tostring(i));
    table.insert(bg, Box.random_furniture());
  end
  return bg;
end