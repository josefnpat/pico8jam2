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
function str2img(str,sx,sy,sw,trans)
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
  i=1
  while (i<#img)do
    if img[i] ~= transparent then
      sset(x,y,img[i]-1)
    end
    x+=1
    if (x>sx+sw-1) then
      x=sx
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
  printh("missing room")
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

room_count = 0
for i,v in pairs(rooms) do
  room_count = room_count + 1
end
people_count = 0
for i,v in pairs(people) do
  people_count = people_count + 1
end

room = 1
left = 1
right = 1

function _update()
  local redraw = false
  if btnp(0) then
    left = left + 1
    if left > people_count then
      left = 1
    end
    redraw = true
  elseif btnp(1) then
    right = right + 1
    if right > people_count then
      right = 1
    end
    redraw = true
  elseif btnp(2) then
    room = room + 1
    if room > room_count then
      room = 1
    end
    redraw = true
  end
  if redraw then
    str2img(get_room(room),0,0,128)
    str2img(get_person(left),0,0,64,true)
    str2img(get_person(right),64,0,64,true)
  end
end

function _draw()
  cls()
  spr(0,0,0,16,16)
end
