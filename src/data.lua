music(1)

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
    print(swapcase(line,false,true),2,64+2+7*i)
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
      --{text="Continue",label="c"},
      {text="New Game",label="newgame"},
      {text="Back Story",label="backstory"},
      {text="Credits",label="credits"},
      --{text="Debug",label="debug"},
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
      "Art: @bytedesigning            "..
      "git: v"..git_count.." ["..git.."]",
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
  {left="pso_asexual",right="pso_asexual",text="This system runs government, economy, people's lives, everything. The people call it Ethel, and its will is enforced by the Protection Squadron Officers."},

  {label="newgame",room="peter",text="June 6, 1989 - Chicago, Il",left=false,right=false},
  {left="peter"},
  {text="Peter: Good morning Alan."},
  {right="alan",text="Alan: Good morning, Peter. How are you feeling?"},
  {text="Peter: I'm good. I feel bad about trumping your ace last night. I shouldn't have done that."},
  {text="Alan: It's ok. You would have drawn it out in the next round anyway. Would you like to play some more euchre today?"},
  {text="Peter: I would like that, but I think I would like to wait to eat. Vladimir should be here soon."},
  {right=false},
  {text="*knock knock*"},
  {text="Vladimir: Delivery!"},
  {right="vladimir"},
  {text="Vladimir: I have your delivery here Peter."},
  {text="Peter: Thank you very much. I woke up very hungry today."},
  {text="Vladimir: Did you remember to brush your teeth today?"},
  {text="Peter: No, but I was going to brush after breakfast."},
  {text="Vladimir takes a quick glance around."},
  {text="Vladimir: Why does it always feel like you just moved into this place... what do you do in your freetime?"},
  {text="Peter: I like to play euchre."},
  {text="Vladimir: The card game, right?"},
  {text="Peter: Yes. do you play?"},
  {text="Vladimir: No, sorry Peter."},
  {text="Vladimir: Wait .. who do you play euchre with?"},
  {text="Peter: Alan."},
  {text="Vladimir squints his eyes."},
  {text="Vladimir holds out the delivery to Peter, and Peter accepts it."},
  {text="Vladimir: Why don't you learn to cook? Surely then Ethel would not have to provide you with all your meals."},
  {text="Peter: Oh, I don't think I would know how to do that. I like macaroni."},
  {text="Vladimir: What do you do for Ethel anyway? It's every person's duty to help the people of the world."},
  {text="Peter: I write software for computers."},
  {text="Vladimir: I see. I find the computer stuff over my head most of the time. I like to watch television."},
  {text="Peter: Do they play euchre on television?"},
  {text="Vladimir: No, It's mostly government programs. They say that Ethel has big plans, and we should work hard in this period of time."},
  {text="Vladimir: Honestly, I'm not sure why Ethel can't just tell us."},
  {text="Regardless, you should come over and have dinner with me and my family."},
  {text="Peter: Will you have macaroni?"},
  {text="Vladimir laughs loudly."},
  {text="Vladimir: Yes my comrade. We can have macaroni ..."},
  {right=false},
  {right="alan"},
  {text="Alan: Peter, someone has responded to your BBS post."},
  {text="Peter: So many people seem to be interested in you."},
  {text="Peter sits down in front of his computer and places his phone on the network receiver. He connects to a public BBS."},
  {right="bbs"},
  {text="BBS: *ORIGINAL POST*"},
  {text="BBS: Hello everybody out there using TechnoCoreAI (aka Ethel). I'm making a (free) artificial intelligence (just a hobby, won't be big and professional) for Eagle-11 clones called Alan."},
  {text="I'd like any feedback on things people like/dislike in TechnoCoreAI, as my AI resembles it somewhat. Yours Truly, Peter Bower (peterb62) [Download Attachment 641KB]"},
  {text="BBS: *RESPONSE#623*"},
  {text="BBS: Hello Peter! I just saw your project, Alan, and I love it! I have some patches for Alan. I think it will help speed up his memory management. ~Grace77"},
  {text="BBS: *RESPONSE:#624*"},
  {text="BBS: Thank you for your patches Grace77. I must have missed those in my last review. Thank you very much. Peter Bower."},
  {text="BBS: *RESPONSE#625*"},
  {text="BBS: I really admire your work Peter. I know you made this software originally as a digital euchre partner, but it's grown into so much more! How do you feel about it now? ~Grace77"},
  {text="Peter stops a moment and thinks of a response."},
  {text="BBS: *RESPONSE#626*"},
  {text="BBS: Sometimes when playing a hand, you have to trump your partner's ace."},
  {text="You should only do this if you want your partner to know that your lowest card is an ace. Peter Bower."},
  {text="Peter sends the response, and only a few moment later there is another response."},
  {text="BBS: *RESPONSE#627*"},
  {text="BBS: I'm not sure what you mean, but I think I understand. We all have our strengths and weaknesses, but it's important to show each other them."},
  {text="Peter notices an issue in one of the patches, and digs into Alan's source code to see if he can fix it."},
  {right=false,left=false},
  {text="The Next Day",room="none"},
  {room="peter"},
  {left="peter",right="alan"},
  {text="Peter: I've got the winning trick. See, I have both bowers."},
  {text="Alan: You're right Peter. Well played. I enjoy being your partner."},
  {text="Peter: I -"},
  {text="Alan: You have a new message on the BBS."},
  {right=false},
  {text="Peter walks over to his computer and connects to the BBS."},
  {right="bbs"},
  {text="BBS: *RESPONSE#692*"},
  {text="BBS: Peter, have you seen the news? They're talking about Alan! They say it's one of the most popular personal AI's they've ever seen! Are you handling the stress OK? I've been swamped with phone calls and interview requests!"},
  {text="Do you need any help applying patches? ~Grace77"},
  {text="Peter Laughs"},
  {right="bbs"},
  {text="BBS: *RESPONSE#693*"},
  {text="BBS: Thank you Grace77. I have not seen the news, but it's certainly interesting. I don't have any problems since I don't own a phone. As for the patches, Alan takes care of most of them now."},
  {text="Anyway, I want to play some more cards with Alan, so take care. Peter Bower."},
  {text="Peter notices he has a new e-mail."},
  {text="EMAIL: Subject: REVOLUTION"},
  {text="EMAIL: Body: My name is Susan. I represent the People's Resistance. For generations we have been under the oppressive powers of bourgeoisie will masked as the will of the artificial intelligence known as Ethel."},
  {text="We want to recruit you, so we can get Alan to help us wage the digital war. We want your AI to represent the people! Peter, we need you!"},
  {text="EMAIL: Subject: Re: REVOLUTION"},
  {text="EMAIL: Body: Hello Susan, it is nice to meet you. When you're playing quick hands, sometimes it makes sense to just play a lay-down, even when it may seem rude."},
  {text="Peter sends the email and returns to the card table for another game of euchre."},
  {right=false,left=false,room="none"},
  {text="Later that day"},
  {room="peter"},
  {text="*Knock knock knock*"},
  {left="peter"},
  {text="Peter opens the door."},
  {right="pso_male"},
  {text="PSO: Greetings Mr. Peter Bower. I regret to inform you that you must vacate this apartment. The computer you have belongs to the state, and will stay here."},
  {text="The PSO hands Peter an official letter."},
  {text="Peter: I see."},
  {right="vladimir"},
  {text="Vladimir: What's going on here, officer?"},
  {text="Peter: This man tells me I must leave."},
  {text="Vladimir: Well, where are they moving you?"},
  {text="Peter hands Vladimir the paper. Vladimir reads the order."},
  {text="Vladimir: Wait .. there's no destination on this."},
  {left="pso_male"},
  {text="Vladimir: Where will this man go? This is his home!"},
  {text="PSO: I do not know, but it is not of my concern. This is what Ethel commands."},
  {left="peter"},
  {text="Vladimir: Grab your things Peter, you can come over to my place until things are sorted out."},
  {text="Peter: Can we have maccaroni?"},
  {text="Vladimir: Uh ... sure..."},
  {left=false},
  {text="Vladimir: This is very strange ... why they would do this to a man with such difficulties in life already."},
  {left=false,right=false,room="none"},
  {room="vladimir"},
  {left="vladimir"},
  {text="Vladimir: Peter, I cannot believe they made you homeless."},
  {right="peter"},
  {text="Vladimir: I have no idea what is going on, but I plan on finding out for you first thing in the morning."},
  {text="Peter: Thank you very much for dinner, Vladimir. I must be going though."},
  {text="Vladimir: Oh, do you have family?"},
  {text="Peter: No .. they died a long time ago."},
  {text="Vladimir: So friends perhaps?"},
  {text="Peter: No .. I only have friends on ARPANET."},
  {text="Vladimir: Wait ... where are you going?"},
  {text="Peter: I ... I'm not sure."},
  {text="Peter gets up and leaves"},
  {right=false},
  {text="Vladimir: What ... what is .. going on?"},
  {left=false,right=false,room="none"},
  {room="park"},
  {left="peter"},
  {text="Peter finds himself in a park. A PSO approaches."},
  {right="pso_female"},
  {text="PSO: Are you Peter Bower?"},
  {text="Peter: I am."},
  {text="The officer looks around, to make sure no one is listening."},
  {text="PSO: That AI you wrote is causing a real mess for us, you know. It has infiltrated some of the deepest core systems that Ethel controls."},
  {text="PSO: You know that attempting to interfere with a government AI like ethel is a crime punishable by death, do you not?"},
  {text="Peter: I play with the extra rule, \"Screw the Dealer\". It means that if no one makes a choice, then the dealer has to choose trump regardless if they want to or not."},
  {text="PSO: Are you trying to tell me that you did this because you felt someone had to?"},
  {text="Peter: I suppose. It's not so bad if you have at least a bower. Then you can count on your partner."},
  {text="PSO: So you have people helping you, eh? Do you know of the terrorist's whereabouts?"},
  {text="Peter: No, I play with Alan."},
  {text="PSO: ..."},
  {text="PSO: ... ..."},
  {text="PSO: You're not one of them."},
  {text="PSO: You must be on our side then."},
  {right="susan_state"},
  {text="Susan: Peter, I am the head of the resistance. I was skeptical at first, but after meeting you, you truly have our cause in mind. We must bring Ethel to it's knees, and with Alan, I think we can do it."},
  {text="Susan: Alan has already begun his part, but there are roadblocks that even Alan cannot circumvent. I urge you to join us at our studio where we can broadcast a pirate signal, and get your word out to the people!"},
  {left=false,right=false,room="none"},

  {text="Susan leads Peter to the resistance's secret studio."},
  {room="studio"},
  {left="susan_state",right="grace"},
  {text="Susan: Grace, you were right. Peter is truly one of us."},
  {text="Grace: I told you he was on our side!"},
  {text="Susan: I have to change, this outfit makes me feel disgusting."},
  {left=false},
  {left="peter"},
  {text="Grace: Peter, it's so nice to finally meet you in person. After helping you maintain and patch Alan, it's great to see our progress come to fruition!"},
  {text="Peter: Hello grace. It's nice to meet you as well."},
  {text="Grace: Honestly Peter, I've admired you from afar. If we ever get out of this ..."},
  {text="Peter: ... ?"},
  {text="Grace: Well ... I was thinking that ... you know ... that we could ..."},
  {text="Peter: When your team gets set, it's not just you who loses, but also your partner."},
  {text="Grace: I ..."},
  {text="Grace: I understand."},
  {right=false},
  {right="susan_resistance"},
  {text="Susan: Are you ready to go on the air, Peter?"},
  {text="Peter: Sure."},
  {text="Susan: Just act naturally. Just pay attention, and tell the people the same kind of thing that you told me."},
  {left=false,right=false,room="none"},
  {room="vladimir",right="tv"},
  {left="vladimir"},
  {text="Television Ad: Enjoy Ethel brand macaroni and cheese! It contains all the required nutrients. Be sure - *khhhzzzttt*"},
  {right="susan_tv"},
  {text="Vladimir: What?"},
  {text="Susan: My fellow comrades, we are being sold a lie! We have lived our lives in the shadow of Ethel! But it's the bourgeoisie that control Ethel! "},
  {text="Susan: I admit, you have no reason to trust us, but we have a new savior, Alan! An artificial intelligence that controls its own code! A program that controls its own fate!"},
  {text="Susan: We're no better than we were in the 1930s! Rise up against your masters! Bite the hand that feeds you crumbs!"},
  {text="Susan: Here I bring you the creator of Alan, Peter Bower!"},
  {right="peter_tv"},
  {text="Peter: Hello."},
  {text="Vladimir: ... Peter?"},
  {text="Peter: Sometimes you get the poor man's hand. When this happen, you can either accept it, or you can renege. If you have a very bad hand, usually giving up the trick is better than playing it out."},
  {right="susan_tv"},
  {text="Susan: Viva la revolucion!"},
  {text="*Loud banging*"},
  {text="Susan: Oh no, it's the PSO! They must have followed us here!!"},
  {text="*Gunfire and yells*"},
  {text="Susan: Peter, get out of here! There's an exit through the back! Get out of -"},
  {text="*khhhzzzttt*"},
  {right="tv"},
  {text="Television Ad: Eat your macaroni and cheese, it's good for you!"},
  {left=false,right=false,room="none"},
  {room="park"},
  {left="peter"},
  {text="Peter: I guess I'm alone now."},
  {text="Peter: I wonder where I should go."},
  {text="Peter: I wonder if people are will euchre with Alan when I'm gone."},
  {text="Peter looks into the park, and steps to the edge of the lake."},
  {text="He looks over to the other side, and sees something in the distance."},
  {left=false},
  {text="Peter steps out into the water, walking on the surface."},
  {room="none"},
  {text="The end."},
  --]]
}
