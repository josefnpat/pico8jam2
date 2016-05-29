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

str2img(assets['r_park'],0,0,129)
str2img(assets['p_susan_state'],0,0,65,true)
str2img(assets['p_vladimir'],64,0,65,true)

function _draw()
  cls()
  spr(0,0,0,16,16)
end
