pico-8 cartridge // http://www.pico-8.com
version 7
__lua__

s=""

--to output sprite sheet to
--  host os console:
--img2str(0,0,127,127,true)

--loading examples in update

local cur = 1
local menu = {
  {
    title = "Import 128x128 input.png",
    exec = function() import("input.png") end,
  },
  {
    title = "Export 64x64 to stdout",
    exec = function()
      img2str(0,0,64,64,true)
    end,
  },
  {
    title = "Export 128x64 to stdout",
    exec = function()
      img2str(0,0,128,64,true)
    end,
  },
}

function _update()
  if btnp(2) then 
    cur = cur - 1
    if cur < 1 then
      cur = #menu
    end
  elseif btnp(3) then
    cur = cur + 1
    if cur  > #menu then
      cur = 1
    end
  elseif btnp(4) then
    menu[cur].exec()
  end
end

--draw sprite sheet to screen for now why not
function _draw()
  cls()
  spr(0,0,0,128/8,64/8)
  for i,v in pairs(menu) do
    if cur == i then
      color(9)
    else
      color(7)
    end
    print(v.title,32,64+8*i)
  end
end

plookup = "abcdefghijklmnop"
clookup = "qrstuvwxyz1234567890=-+[]{};:'<,.>?/!@#$%^&*()"

--converts string to image &
--draws it to the sprite sheet
function str2img(str,sx,sy,sw)
  local img={}
  local i=1
  local p,c
  while (i<#str) do
    p=indexof(plookup,sub(str,i,i))
    c=indexof(clookup,sub(str,i+1,i+1))
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
  x=sx
  y=sy
  i=1
  while (i<#img)do
    sset(x,y,img[i]-1)
    x+=1
    if (x>sx+sw-1) then
      x=sx
      y+=1
    end
    i+=1
  end
end

function indexof(s,s2)
 local ret=-1
 for i=1, #s do
  if (sub(s,i,i)==s2) return i
 end
 return ret
end

--outputs string to host os
--(make sure to open pico-8 from a terminal)
--(x,y,max x, max y, printh)
function img2str(sx,sy,sx2,sy2,printit)
  local p = -1
  local c = 1
  local img = ""
  for y = sy,sy2 do
    for x = sx,sx2 do
      px = sget(x,y)+1
      if (px != p or c>=#clookup) then
        if (p != -1) then
          img = img..sub(plookup,p,p)
          if (c>1) then
           img = img..sub(clookup,c,c)
          end
        end
        p = px
        c = 1
      else
        c = c + 1
      end
    end
  end
  img = img..sub(plookup,p,p)..sub(clookup,c,c)
  if (printit) then
    printh("image (max compression):")
    printh('"'..img..'"')
  end
  return img
end
