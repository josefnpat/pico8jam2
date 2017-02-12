music(1)

function decomp(src, dest, len)
  local dest0=dest
  local pos = 0
  for i=0,len/2 do
    local a=peek(src)
    local b=peek(src+1)
    src += 2
    if (a == 0) then
      poke(dest, b)
      dest += 1
    else
      memcpy(dest,dest-a,b)
      dest += b
    end
  end
  return dest-dest0
end

plookup = "abcdefghijklmnop"
clookup = "qrstuvwxyz1234567890=-+[]{};:'<,.>?/!@#$%^&*()"

datlen={1582,1876,2274,22,2480,1048,1450,1136}
ss=plookup..clookup
rn={"backstory","credits","game","none","park","peter","studio","vladimir"}
rooms={}
src=0
for i=1,8 do
  l = decomp(src,0x6000,datlen[i])
  s=""
  for j=0,l-1 do
    v=peek(0x6000+j)
    s=s..sub(ss,v,v)
  end
  rooms["r_"..rn[i]] = s
  src += datlen[i]
end
cls()

function indexof(s,s2)
  local ret=-1
  for i=1, #s do
    if (sub(s,i,i)==s2) then
      return i
    end
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
  while (i<=#img)do
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
    text = nil
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
left_name = nil
right = nil
right_name = nil

name_map = {
  pso_male = "ps officer",
  pso_female = "ps officer",
  pso_asexual = "ps officer",
  susan_state = "susan",
  susan_resistance = "susan",
  bbs = "computer",
  susan_tv = "television",
  peter_tv = "television",
}

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
    if script[current].text == nil then
      text_dt = 3600
    end
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
      text = nil
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
      left_name = nil
    else
      left = get_person_index(script[current].left)
      left_name = name_map[script[current].left] or script[current].left
    end
  end
  if script[current].right ~= nil then
    redraw = true
    if script[current].right == false then
      right = nil
      right_name = nil
    else
      right = get_person_index(script[current].right)
      right_name = name_map[script[current].right] or script[current].right
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

function printf(str,x,y,w)
  local x2 = x+w
  line(x,y,x2,y)
  local lines = {}

  local current_word = ""
  local current_line = ""

  for i = 1,#str do
    local current_char = sub(str,i,i)
    if current_char == " " then
      local tw = (#current_line + #current_word+1)*4
      if tw > w then
        add(lines,current_line)
        current_line = current_word
        current_word = ""
      else
        current_line = current_line .. " " .. current_word
        current_word = ""
      end
    else
      current_word = current_word .. current_char
    end
  end

  local tw = (#current_line + #current_word+1)*4
  if tw > w then
    add(lines,current_line)
    current_line = current_word
    current_word = ""
  else
    current_line = current_line .. " " .. current_word
    current_word = ""
  end

  current_line = current_line .. " " .. current_word
  add(lines,current_line)

  for i,line in pairs(lines) do
    print(line,2,64+2+7*i)
  end
end

current_choice = 1

function _draw()
  cls()
  spr(0,0,0,16,8)
  if left_name then
    print(left_name,0,64+1)
  end
  if right_name then
    print(right_name,127+2-#right_name*4,64+1)
  end
  if choice then
    for i,data in pairs(choice) do
      local extra = " "
      if i == current_choice then
        color(8)
        extra = ">"
      else
        color(7)
      end
      print(extra..data.text,3,64+7*i)
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
      {text="new game",label="backstory"},
      {text="credits",label="credits"},
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
      "the career of peter was made for the #pico2jam2 2016 by missing sentinel software (missingsentinelsoftware.com) programming & story: @josefnpat, art: @bytedesigning, music: bennjamin furtado, git: v"..git_count.." ["..git.."]",
    target_label="menu",
  },
  {
    label="backstory",
    room="backstory",
    text="march 7, 1936 - adolf hitler entered forces into the rhineland, breaking the treaty of versailles. the french and the british invade in retaliation.",
  },
  {text="the league of nations identify the economic issues that brought hitler to power, and they discard article 231 (war guilt clause) and send aid to strengthen the infrastructure."},
  {text="this turn of events saves 60 million lives. the cold war never happens."},
  {text="the league of nations succeeds in it's mission of world peace."},
  {text="telecommunication and computing takes leaps and bounds and is able to provide a personal computer in every home connected to a variant of arpanet."},
  {text="communist and marxist ideals begin to enter politics without opposition, and the world's governments reforms into a united communist system that is run by an artificial intelligence written by the leading scientists."},
  {left="pso_asexual",right="pso_asexual",text="this system runs government, economy, people's lives, everything. the people call it ethel, and its will is enforced by the protection squadron officers."},

  {label="newgame",room="peter",text="june 6, 1989 - chicago, il",left=false,right=false},
  {left="peter"},
  {text="peter: good morning alan."},
  {right="alan",text="alan: good morning, peter. how are you feeling?"},
  {text="peter: i'm good. i feel bad about trumping your ace last night. i shouldn't have done that."},
  {text="alan: it's ok. you would have drawn it out in the next round anyway. would you like to play some more euchre today?"},
  {text="peter: i would like that, but i think i would like to wait to eat. vladimir should be here soon."},
  {right=false},
  {text="*knock knock*"},
  {text="vladimir: delivery!"},
  {right="vladimir"},
  {text="vladimir: i have your delivery here peter."},
  {text="peter: thank you very much. i woke up very hungry today."},
  {text="vladimir: did you remember to brush your teeth today?"},
  {text="peter: no, but i was going to brush after breakfast."},
  {text="vladimir takes a quick glance around."},
  {text="vladimir: why does it always feel like you just moved into this place... what do you do in your freetime?"},
  {text="peter: i like to play euchre."},
  {text="vladimir: the card game, right?"},
  {text="peter: yes. do you play?"},
  {text="vladimir: no, sorry peter."},
  {text="vladimir: wait .. who do you play euchre with?"},
  {text="peter: alan."},
  {text="vladimir squints his eyes."},
  {text="vladimir holds out the delivery to peter, and peter accepts it."},
  {text="vladimir: why don't you learn to cook? surely then ethel would not have to provide you with all your meals."},
  {text="peter: oh, i don't think i would know how to do that. i like macaroni."},
  {text="vladimir: what do you do for ethel anyway? it's every person's duty to help the people of the world."},
  {text="peter: i write software for computers."},
  {text="vladimir: i see. i find the computer stuff over my head most of the time. i like to watch television."},
  {text="peter: do they play euchre on television?"},
  {text="vladimir: no, it's mostly government programs. they say that ethel has big plans, and we should work hard in this period of time."},
  {text="vladimir: honestly, i'm not sure why ethel can't just tell us."},
  {text="regardless, you should come over and have dinner with me and my family."},
  {text="peter: will you have macaroni?"},
  {text="vladimir laughs loudly."},
  {text="vladimir: yes my comrade. we can have macaroni ..."},
  {right=false},
  {right="alan"},
  {text="alan: peter, someone has responded to your bbs post."},
  {text="peter: so many people seem to be interested in you."},
  {text="peter sits down in front of his computer and places his phone on the network receiver. he connects to a public bbs."},
  {right="bbs"},
  {text="bbs: *original post*"},
  {text="bbs: hello everybody out there using technocoreai (aka ethel). i'm making a (free) artificial intelligence (just a hobby, won't be big and professional) for eagle-11 clones called alan."},
  {text="i'd like any feedback on things people like/dislike in technocoreai, as my ai resembles it somewhat. yours truly, peter bower (peterb62) [download attachment 641kb]"},
  {text="bbs: *response#623*"},
  {text="bbs: hello peter! i just saw your project, alan, and i love it! i have some patches for alan. i think it will help speed up his memory management. ~grace77"},
  {text="bbs: *response:#624*"},
  {text="bbs: thank you for your patches grace77. i must have missed those in my last review. thank you very much. peter bower."},
  {text="bbs: *response#625*"},
  {text="bbs: i really admire your work peter. i know you made this software originally as a digital euchre partner, but it's grown into so much more! how do you feel about it now? ~grace77"},
  {text="peter stops a moment and thinks of a response."},
  {text="bbs: *response#626*"},
  {text="bbs: sometimes when playing a hand, you have to trump your partner's ace."},
  {text="you should only do this if you want your partner to know that your lowest card is an ace. peter bower."},
  {text="peter sends the response, and only a few moment later there is another response."},
  {text="bbs: *response#627*"},
  {text="bbs: i'm not sure what you mean, but i think i understand. we all have our strengths and weaknesses, but it's important to show each other them."},
  {text="peter notices an issue in one of the patches, and digs into alan's source code to see if he can fix it."},
  {right=false,left=false},
  {text="the next day",room="none"},
  {room="peter"},
  {left="peter",right="alan"},
  {text="peter: i've got the winning trick. see, i have both bowers."},
  {text="alan: you're right peter. well played. i enjoy being your partner."},
  {text="peter: i -"},
  {text="alan: you have a new message on the bbs."},
  {right=false},
  {text="peter walks over to his computer and connects to the bbs."},
  {right="bbs"},
  {text="bbs: *response#692*"},
  {text="bbs: peter, have you seen the news? they're talking about alan! they say it's one of the most popular personal ai's they've ever seen! are you handling the stress ok? i've been swamped with phone calls and interview requests!"},
  {text="do you need any help applying patches? ~grace77"},
  {text="peter laughs"},
  {right="bbs"},
  {text="bbs: *response#693*"},
  {text="bbs: thank you grace77. i have not seen the news, but it's certainly interesting. i don't have any problems since i don't own a phone. as for the patches, alan takes care of most of them now."},
  {text="anyway, i want to play some more cards with alan, so take care. peter bower."},
  {text="peter notices he has a new e-mail."},
  {text="email: subject: revolution"},
  {text="email: body: my name is susan. i represent the people's resistance. for generations we have been under the oppressive powers of bourgeoisie will masked as the will of the artificial intelligence known as ethel."},
  {text="we want to recruit you, so we can get alan to help us wage the digital war. we want your ai to represent the people! peter, we need you!"},
  {text="email: subject: re: revolution"},
  {text="email: body: hello susan, it is nice to meet you. when you're playing quick hands, sometimes it makes sense to just play a lay-down, even when it may seem rude."},
  {text="peter sends the email and returns to the card table for another game of euchre."},
  {right=false,left=false,room="none"},
  {text="later that day"},
  {room="peter"},
  {text="*knock knock knock*"},
  {left="peter"},
  {text="peter opens the door."},
  {right="pso_male"},
  {text="pso: greetings mr. peter bower. i regret to inform you that you must vacate this apartment. the computer you have belongs to the state, and will stay here."},
  {text="the pso hands peter an official letter."},
  {text="peter: i see."},
  {right="vladimir"},
  {text="vladimir: what's going on here, officer?"},
  {text="peter: this man tells me i must leave."},
  {text="vladimir: well, where are they moving you?"},
  {text="peter hands vladimir the paper. vladimir reads the order."},
  {text="vladimir: wait .. there's no destination on this."},
  {left="pso_male"},
  {text="vladimir: where will this man go? this is his home!"},
  {text="pso: i do not know, but it is not of my concern. this is what ethel commands."},
  {left="peter"},
  {text="vladimir: grab your things peter, you can come over to my place until things are sorted out."},
  {text="peter: can we have maccaroni?"},
  {text="vladimir: uh ... sure..."},
  {left=false},
  {text="vladimir: this is very strange ... why they would do this to a man with such difficulties in life already."},
  {left=false,right=false,room="none"},
  {room="vladimir"},
  {left="vladimir"},
  {text="vladimir: peter, i cannot believe they made you homeless."},
  {right="peter"},
  {text="vladimir: i have no idea what is going on, but i plan on finding out for you first thing in the morning."},
  {text="peter: thank you very much for dinner, vladimir. i must be going though."},
  {text="vladimir: oh, do you have family?"},
  {text="peter: no .. they died a long time ago."},
  {text="vladimir: so friends perhaps?"},
  {text="peter: no .. i only have friends on arpanet."},
  {text="vladimir: wait ... where are you going?"},
  {text="peter: i ... i'm not sure."},
  {text="peter gets up and leaves"},
  {right=false},
  {text="vladimir: what ... what is .. going on?"},
  {left=false,right=false,room="none"},
  {room="park"},
  {left="peter"},
  {text="peter finds himself in a park. a pso approaches."},
  {right="pso_female"},
  {text="pso: are you peter bower?"},
  {text="peter: i am."},
  {text="the officer looks around, to make sure no one is listening."},
  {text="pso: that ai you wrote is causing a real mess for us, you know. it has infiltrated some of the deepest core systems that ethel controls."},
  {text="pso: you know that attempting to interfere with a government ai like ethel is a crime punishable by death, do you not?"},
  {text="peter: i play with the extra rule, \"screw the dealer\". it means that if no one makes a choice, then the dealer has to choose trump regardless if they want to or not."},
  {text="pso: are you trying to tell me that you did this because you felt someone had to?"},
  {text="peter: i suppose. it's not so bad if you have at least a bower. then you can count on your partner."},
  {text="pso: so you have people helping you, eh? do you know of the terrorist's whereabouts?"},
  {text="peter: no, i play with alan."},
  {text="pso: ..."},
  {text="pso: ... ..."},
  {text="pso: you're not one of them."},
  {text="pso: you must be on our side then."},
  {right="susan_state"},
  {text="susan: peter, i am the head of the resistance. i was skeptical at first, but after meeting you, you truly have our cause in mind. we must bring ethel to it's knees, and with alan, i think we can do it."},
  {text="susan: alan has already begun his part, but there are roadblocks that even alan cannot circumvent. i urge you to join us at our studio where we can broadcast a pirate signal, and get your word out to the people!"},
  {left=false,right=false,room="none"},

  {text="susan leads peter to the resistance's secret studio."},
  {room="studio"},
  {left="susan_state",right="grace"},
  {text="susan: grace, you were right. peter is truly one of us."},
  {text="grace: i told you he was on our side!"},
  {text="susan: i have to change, this outfit makes me feel disgusting."},
  {left=false},
  {left="peter"},
  {text="grace: peter, it's so nice to finally meet you in person. after helping you maintain and patch alan, it's great to see our progress come to fruition!"},
  {text="peter: hello grace. it's nice to meet you as well."},
  {text="grace: honestly peter, i've admired you from afar. if we ever get out of this ..."},
  {text="peter: ... ?"},
  {text="grace: well ... i was thinking that ... you know ... that we could ..."},
  {text="peter: when your team gets set, it's not just you who loses, but also your partner."},
  {text="grace: i ..."},
  {text="grace: i understand."},
  {right=false},
  {right="susan_resistance"},
  {text="susan: are you ready to go on the air, peter?"},
  {text="peter: sure."},
  {text="susan: just act naturally. just pay attention, and tell the people the same kind of thing that you told me."},
  {left=false,right=false,room="none"},
  {room="vladimir",right="tv"},
  {left="vladimir"},
  {text="television ad: enjoy ethel brand macaroni and cheese! it contains all the required nutrients. be sure - *khhhzzzttt*"},
  {right="susan_tv"},
  {text="vladimir: what?"},
  {text="susan: my fellow comrades, we are being sold a lie! we have lived our lives in the shadow of ethel! but it's the bourgeoisie that control ethel! "},
  {text="susan: i admit, you have no reason to trust us, but we have a new savior, alan! an artificial intelligence that controls its own code! a program that controls its own fate!"},
  {text="susan: we're no better than we were in the 1930s! rise up against your masters! bite the hand that feeds you crumbs!"},
  {text="susan: here i bring you the creator of alan, peter bower!"},
  {right="peter_tv"},
  {text="peter: hello."},
  {text="vladimir: ... peter?"},
  {text="peter: sometimes you get the poor man's hand. when this happens, you can either accept it, or you can renege. if you have a very bad hand, usually giving up the trick is better than playing it out."},
  {right="susan_tv"},
  {text="susan: viva la revolucion!"},
  {text="*loud banging*"},
  {text="susan: oh no, it's the pso! they must have followed us here!!"},
  {text="*gunfire and yelling*"},
  {text="susan: peter, get out of here! there's an exit through the back! get out of -"},
  {text="*khhhzzzttt*"},
  {right="tv"},
  {text="television ad: eat your macaroni and cheese, it's good for you!"},
  {left=false,right=false,room="none"},
  {room="park"},
  {left="peter"},
  {text="peter: i guess i'm alone now."},
  {text="peter: i wonder where i should go."},
  {text="peter: i wonder if people are will euchre with alan when i'm gone."},
  {text="peter looks into the park, and steps to the edge of the lake."},
  {text="he looks over to the other side, and sees something in the distance."},
  {left=false},
  {text="peter steps out into the water, walking on the surface."},
  {room="none"},
  {text="the end."},
  --]]
}
