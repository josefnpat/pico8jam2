plookup = "abcdefghijklmnop"
clookup = "qrstuvwxyz1234567890=-+[]{};:'<,.>?/!@#$%^&*()"

function indexof(s,s2)
  local ret=-1
  for i=1, #s do
    if (sub(s,i,i)==s2) return i
  end
  return ret
end

--converts string to image &
--draws it to the sprite sheet
function str2img(str,sx,sy,sw,trans,flip)
  local img={}
  local i=1
  local transparent
  if trans == nil then
    transparent = -1
  elseif type(trans) == "number" then
    transparent = trans
  end
  while (i<#str) do
    local p=indexof(plookup,sub(str,i,i))
    if transparent == nil then
      transparent = p
    end
    local c=indexof(clookup,sub(str,i+1,i+1))
    if (c==-1) then
      c=1
      i+=1
    else
      i+=2
    end
    for k=1,c do
      add(img,p)
    end
  end
  local x=sx
  local y=sy
  local offsetx = 0
  i=1
  while (i<#img)do
    if img[i] ~= transparent then
      if flip then
        sset(sx+sw-offsetx,y,img[i]-1)
      else
        sset(x,y,img[i]-1)
      end
    end
    x+=1
    offsetx += 1
    if (x>sx+sw-1) then
      x=sx
      offsetx = 0
      y+=1
    end
    i+=1
  end
end

function get_room(index)
  local c = 0
  for i,v in pairs(rooms) do
    c = c + 1
    if index == c then
      return v
    end
  end
  printh("missing room "..index)
end

function get_room_index(name)
  local c = 0
  for i,v in pairs(rooms) do
    c = c + 1
    if i == "r_"..name then
      return c
    end
  end
  printh("missing room "..name)
end

function get_person(index)
  local c = 0
  for i,v in pairs(people) do
    c = c + 1
    if index == c then
      return v
    end
  end
  printh("missing person")
end

function get_person_index(name)
  local c = 0
  for i,v in pairs(people) do
    c = c + 1
    if i == "p_"..name then
      return c
    end
  end
  printh("missing person "..name)
end

room_count = 0
for i,v in pairs(rooms) do
  room_count = room_count + 1
end
people_count = 0
for i,v in pairs(people) do
  people_count = people_count + 1
end

room = nil
left = nil
left_name = ""
right = nil
right_name = ""

text_dt = 0

function _update()

  text_dt = text_dt + 1/30

  local redraw = false

  if debug then
    if btnp(0) then
      left = (left or 0) + 1
      if left > people_count then
        left = nil
      end
      redraw = true
    elseif btnp(1) then
      right = (right or 0) + 1
      if right > people_count then
        right = nil
      end
      redraw = true
    elseif btnp(2) then
      room = (room or 0) + 1
      if room > room_count then
        room = nil
      end
      redraw = true
    end
    if redraw then
      if room then str2img(get_room(room),0,0,128) end
      if left then str2img(get_person(left),0,0,64,true) end
      if right then str2img(get_person(right),64,0,64,true,true) end
    end
    return
  end

  if btnp(4) then
    if not choice and text_dt < 3600 then
      text_dt = 3600
    else
      if script[current].target_label then
        goto_label(script[current].target_label)
      else
        current = current + 1
      end
      if choice then
        goto_label(choice[current_choice].label)
        current_choice = 1
        choice = nil
      end
      wait = false
      redraw = true
      text_dt = 0
    end
  end

  if choice then
    local choice_count = 0
    for i,v in pairs(choice) do
      choice_count = choice_count + 1
    end
    if btnp(3) then
      current_choice = current_choice + 1
      if current_choice > choice_count then
        current_choice = 1
      end
    elseif btnp(2) then
      current_choice = current_choice - 1
      if current_choice < 1 then
        current_choice = choice_count
      end
    end
  end

  if script[current] == nil then
    current = 1
  end

  if script[current].exe then
    script[current].exe()
  end

  if script[current].room then
    redraw = true
    if script[current].room == false then
      room = nil
    else
      room = get_room_index(script[current].room)
    end
  end

  if script[current].choice then
    choice = script[current].choice
    text = nil
  elseif script[current].text then
    text = script[current].text
    choice = nil
  end

  if script[current].left ~= nil then
    redraw = true
    if script[current].left == false then
      left = nil
    else
      left = get_person_index(script[current].left)
    end
  end
  if script[current].right ~= nil then
    redraw = true
    if script[current].right == false then
      right = nil
    else
      right = get_person_index(script[current].right)
    end
  end

  if redraw and not wait then
    wait = true
    if room then str2img(get_room(room),0,0,128) end
    if left then str2img(get_person(left),0,0,64,true) end
    if right then str2img(get_person(right),64,0,64,true,true) end
  end

end

function goto_label(name)
  for i,v in pairs(script) do
    if v.label == name then
      current = i
      return
    end
  end
  current = 1
end

lower = "abcdefghijklmnopqrstuvwxyz"
upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

function swapcase(string,low,up)
  local new_string = ""
  for i = 1,#string do
    found = false

    if low and not found then
      for j = 1,#lower do
        if sub(lower,j,j) == sub(string,i,i) then
          found = true
          new_string = new_string .. sub(upper,j,j)
          break
        end
      end
    end

    if up and not found then
      for j = 1,#lower do
        if sub(upper,j,j) == sub(string,i,i) then
          found = true
          new_string = new_string .. sub(lower,j,j)
          break
        end
      end
    end

    if not found then
      new_string = new_string .. sub(string,i,i)
    end

  end
  return new_string
end

function printf(str,x,y,w)
  local x2 = x+w
  line(x,y,x2,y)
  local lines = {}
  while #str > w/4 do
    add(lines,sub(str,1,w/4))
    str = sub(str,w/4+1)
  end
  add(lines,str)
  for i,line in pairs(lines) do
    print(swapcase(line,false,true),2,64+2+7*i)
  end
end

current_choice = 1

function _draw()
  cls()
  spr(0,0,0,16,8)
  print(left_name,0,64+1)
  print(right_name,127+2-#right_name*4,64+1)
  if choice then
    for i,data in pairs(choice) do
      local extra = " "
      if i == current_choice then
        color(8)
        extra = ">"
      else
        color(7)
      end
      print(extra..swapcase(data.text,false,true),3,64+7*i)
      color(7)
    end
  elseif text then
    if text_dt*20 > #text then
      text_dt = 3600
    end
    printf(
      sub(text,1,text_dt*20),
      0,64+7,127)
  end
end

script = {
  {
    label="mainmenu",
    choice={
      {text="New Game",label="newgame"},
      {text="Back Story",label="backstory"},
      {text="Credits",label="credits"},
      {text="Debug",label="debug"},
    },
    left=false,
    right=false,
    room="game",
  },
  {
    label="debug",
    exe=function() debug = true end,
    target_label = "mainmenu",
  },
  {
    label="credits",
    room="credits",
    text=
      "The Career of Peter was made   "..
      "for the #pico2jam2 2016        "..
      "Missing Sentinel Software      "..
      "missingsentinelsoftware.com    "..
      "Programming & Story: @josefnpat"..
      "Art: @bytedesigning            ",
    target_label="menu",
  },
  {
    label="backstory",
    room="backstory",
    text="March 7, 1936 - Adolf Hitler entered forces into the Rhineland, breaking the Treaty of Versailles. The French and the British invade in retaliation.",
  },
  {text="The League of Nations identify the economic issues that brought Hitler to power, and they discard Article 231 (War Guilt Clause) and send aid to strengthen the infrastructure."},
  {text="This turn of events saves 60 million lives. The Cold War never happens."},
  {text="The League of Nations succeeds in it's mission of world peace."},
  {text="Telecommunication and computing takes leaps and bounds and is able to provide a personal computer in every home connected to a variant of ARPANET."},
  {text="Communist and Marxist ideals begin to enter politics without opposition, and the world's governments reforms into a united communist system that is run by an artificial intelligence written by the leading scientists."},
  {left="pso_asexual",right="pso_asexual",text="This system runs government, economy, people's lives, everything. The people call it Ethel, and it's will is enforced by the Protection Squadron Officers."},
  {label="newgame",text="hello world",left="pso_male",right="pso_female"},
}
