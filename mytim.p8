pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- main
function _init()
  cls()  
  ts = 0  
  Tstage = 0
  state = "start"
  init_game() 
  init_pickups() 
  level = 1  
end

function startup()
  cls()
  ts = 0  
  Tstage = 0
  state = "game"
  init_game() 
  init_pickups() 
  level = 1 
  generate_map()
end

function _update() 
  if state == "start" then
    update_start()
  elseif state == "game" then
    dmg = 0
    update_game()
    updateparts()
    update_pickups()
    pl_dmg()
    portal_collision()
  elseif state == "inv" then
  	 drawind()
  	 update_inv()
  elseif state == "travel" then
    update_travel()
  elseif state == "over" then
    game_over()
  end

  
end

function _draw() 
  if state == "start" then
    draw_start()
  elseif state == "game" then
    draw_map()
    draw_player()
    draw_pickups()
  elseif state == "inv" then
    drawind()
  elseif state == "travel" then
    draw_map()
    draw_player()
    draw_pickups()
    iris()
  elseif state == "over" then
    draw_over()
  end 
  
  if false then
    rect(box.x,box.y,
         box.x2,box.y2,8)
  end 
  
  if pl.delay > 0 then
    print('cd:'..pl.delay/30,2,2,8)
  end
   
end

-->8
-- updates
function init_game()
  pl = {}
  pl.x = 60
  pl.y = 60
  pl.ox = 60
  pl.oy = 60
  pl.w = 8
  pl.h = 8
  pl.s = 1
  pl.tle = 0
  pl.hp = 3
  pl.delay = 0
  pl.dash = 6
  pl.basic = 10
  t = 0
  
  inv,eqp={},{}

  eqp[1] = "health potion"
  eqp[2] = "stamina potion"
  hpp = 0
  spp = 0
  hpmax = 3
  sp = 2
  spmin = 0
  iframe = 0
  timer = 0
  sptimer = 0
  txt,col={},{}
  
  skel = 0
  hurt = {}

  itm_name={"broad sword","leather armor","red potion"}
  
  wind={}
  
  
  camdash = pl.dash+3
  
  hpwind=addwind(5,5,28,13,{pl.hp.."/"..hpmax.."♥"})
  
  part={}
  
  mob = {}
  mob_hp ={2,1}
  mob_atk = {1,1}
  
  
  
  gridx = 0
  gridy = 0
  
  speed = 2
  cooldown = 60
  
  cx = 0
  cy = 0
  
  box = {}
  box.x = 32
  box.y = 32
  box.x2 = 88
  box.y2 = 88
end

function update_start()
  if btnp(🅾️) then
    level = 0
    state = "game"
    generate_map()
  end  
end

function update_game()
  pl.s = 3
  t += 1
  pl.ox = pl.x
  pl.oy = pl.y
  gridx = flr(pl.x/8)
  gridy = flr(pl.y/8)  
  pl.tle = mget(gridx,gridy)
  camdelay = pl.delay
  
  move_player()
  cam_movement()
 
  if pl.hp == 0 then
    ts = 0
    cls()
    state = "over"
  end
end

function update_travel()
  if Tstage == 0 then
    irisd = -4
    Tstage = 1
  elseif Tstage == 1 then
    if irisi <= 1 then
      Tstage = 2
    end
  elseif Tstage == 2 then
    generate_map()
    Tstage = 3
  elseif Tstage == 3 then
    irisd = 4
    Tstage = 4
  elseif Tstage == 4 then
    if irisi >= 90 then
      Tstage = 5
    end
  else
    Tstage = 0
    state = "game"
  end
end

function game_over()
  if btn(🅾️) then
    startup()
  end
end

function update_inv()
 --inventory
 move_mnu(invwind)
 if btnp(❎) then
  _upd=update_game
  state = "game"
  invwind.dur=0
  statwind.dur=0
  timer = 5
 end
end

function mob_dmg()

   if(dmg == 0) then
    px = pl.x + cx
    py = pl.y + cy

    for m in all(mob) do
      if mobcollide(
         px, py, pl.w, pl.h,
         m.x*8,m.y*8,8 ,8) and
         m.typ == "s" then
        m.hp -= 1
        dmg = 1
        if(m.hp <= 0) then
          del(mob,m)
        elseif(m.var == 3) then
          m.ani = {60,61,62,63}
          add(hurt,m)
          skel = 15
        else
          m.ani = {37,37,37,37}
          add(hurt,m)
          skel = 15
        end
         
      elseif mobcollide(
         px, py, pl.w, pl.h,
         m.x*8,m.y*8,8 ,8) then
        m.hp -= 1
        dmg = 1
        if(m.hp <= 0) then
          del(mob,m)
        end
      end
     end
   end

end

function pl_dmg()
  if(iframe <= 0) then
    px = pl.x + cx
    py = pl.y + cy

    for m in all(mob) do
      if mobcollide(
         px, py, pl.w, pl.h,
         m.x*8,m.y*8,8 ,8) then
        pl.hp -= 1
        addwind(5,5,28,13,{pl.hp.."/"..hpmax.."♥"})
        iframe = 32
      end
    end
   else
     iframe -= 1
   end
end
-->8
-- collision and draw
function draw_map()
  cls()
  camera(cx,cy)
  map(mx,my)
  camera(0,0)
  for m in all(mapGen) do
    drawspr( 09 , m.x*1 , m.y*1 , 20 , false ) //  -- For debug
    drawspr( 07 , m.x*8 , m.y*8 , 20 , false )
  end
  for m in all(mob) do
    drawspr(getframe(m.ani),m.x*8,m.y*8,20,false)
  end
  drawspr(getframe(por.ani),por.x*8,por.y*8,20,false)
  drawind()
end

function draw_player()
  drawpart()
  camera(0,0)
  spr(pl.s, pl.x, pl.y)
end

function draw_start()

  while (ts<60) do
    if (ts>30) then
    spr(69,71,48)
    spr(70,79,48)
    spr(85,71,56)
    spr(86,79,56)
    elseif (ts>15) then
    spr(67,55,36)
    spr(68,63,36)
    spr(83,55,44)
    spr(84,63,44)
    else
    spr(65,39,24)
    spr(66,47,24)
    spr(81,39,32)
    spr(82,47,32)
    end
    
    if (ts>45) then
      print("press 🅾️ to start!",35,80,7,8)    
    end
    
    flip() 
    ts+=1
  end
end

function draw_over()
  while (ts<60) do
    if (ts>45) then
      spr(15,60,40)
      print("click 🅾️ to restart", 28, 76, 8)
        
    elseif (ts>30) then
      spr(14,60,40)
    elseif (ts>15) then
      spr(13,60,40)
    else
      print("you are dead",40,60,8)
      print("you made it to level "..level,22,68,8)
      spr(12,60,40)
    end    
    flip() 
    ts+=1
  end
end


--add particle
function addpart(_x,_y,_type,_maxage,_col)  
  local _p = {}
  _p.x = _x
  _p.y = _y
  _p.tpe = _type
  _p.mage = _maxage
  _p.age = 0
  _p.col = _col
  add(part,_p) 
end

--spawn dash trail
function spawntrail(_x,_y)
  local _ang = rnd()
  local _ox = sin(_ang)*4*0.6
  local _oy = cos(_ang)*4*0.6
  addpart(_x+_ox,_y+_oy,0,10+rnd(10),8)
end

function updateparts()
  local _p
  for i=#part,1,-1 do 
    _p = part[i] 
    _p.age += 1
    if _p.age > _p.mage then
      del(part,part[i])
    else
    
    end
  end
end

function drawpart()
  for i=1,#part do
    _p = part[i]
    if _p.tpe == 0 then
      pset(_p.x,_p.y,10)
    end 
  end
end

function bump()  
  if pl.x > pl.ox then
    pl.x = pl.ox - 0.9999
  elseif pl.x < pl.ox then
    pl.x = pl.ox + 0.9999
  end 
     
  if pl.y > pl.oy then
    pl.y = pl.oy - 0.9999
  elseif pl.y < pl.oy then
    pl.y = pl.oy + 0.9999
  end  
end

function map_collide(x,y,w,h)
  x += cx 
  y += cy
  
  s1 = mget(x/8,y/8)
  s2 = mget((x+w-1)/8,y/8)            
  s3 = mget(x/8,(y+w-1)/8)
  s4 = mget((x+w-1)/8,(y+w-1)/8)
            
  if fget(s1,3) then                      
    return true
  elseif fget(s2,3) then
    return true
  elseif fget(s3,3) then
    return true
  elseif fget(s4,3) then
    return true
  end
    
  //collision for procedurally generated walls
  for i in all(mapGen) do
    if i.x*8-7 <= x and i.x*8+7 >= x then
      if i.y*8-7 <= y and i.y*8+7 >= y then
        return true
      end
    end
  end
  return false
end

function item_collide(tle,x,y)
  if tle == 23 or tle == 24 then
    --health
    mset(x,y,8)
  elseif tle == 39 or tle == 40 then
    --damageboost
    mset(x,y,8)
  end  
end


function tile_hit(
               x1,y1,w1,h1,
               x2,y2,w2,h2)
  
  local hit = false
  
  local xs=w1*0.5+w2*0.5
  local ys=h1*0.5+h2*0.5
  local xd = abs((x1+(w1/2))-(x2+(w2/2)))
  local yd = abs((y1+(h1/2))-(y2+(h2/2)))
  
  if xd<xs and yd<ys then
    hit = true
  end

  return hit
end


function portal_collision()
  x = pl.x + cx
  y = pl.y + cy
  if por.x*8-3 <= x and por.x*8+3 >= x then
    if por.y*8-3 <= y and por.y*8+3 >= y then
      level += 1
      state = "travel"
    end
  end
end

function mobcollide(
              x1, y1, w1, h1,
              x2, y2, w2, h2)

  if x1 < x2 + w2 and
     x1 + w1 > x2 and
     y1 < y2 + h2 and
     y1 + h1 > y2 then
   return true
  end

  return false
end

-->8
-- pickups
function init_pickups()
  pu = {}
end

function update_pickups()

  px = pl.x + cx
  py = pl.y + cy

  for p in all(pu) do
    if aabb_collide(
      px, py, pl.w, pl.h,
      p.x*8,p.y*8,8 ,8) then
      if(p.v == 1) then
        hpp += 1
      elseif(p.v == 2) then
        hpp += 2
      elseif(p.v == 21) then
        spp += 1
      else
        spp += 2
      end
      del(pu,p)
    end
  end

end

function draw_pickups()
  camera(cx,cy)
  for p in all(pu) do 
    spr(p.s,p.x*8,p.y*8)
  end
  camera(0,0)
  drawind()
end

function aabb_collide(x1, y1, w1, h1, x2, y2, w2, h2)

  if x1 < x2 + w2 and
     x1 + w1 > x2 and
     y1 < y2 + h2 and
     y1 + h1 > y2 then
   return true
  end

  return false
end
-->8
-- mobs
function addmob(typ,mobx,moby,variant)
  slani = {}
  skani = {}
  if variant == 1 then
    slani = {17,18,19,20} //slime - green
    skani = {33,34,35,36} //skele - skeleton
  elseif variant == 2 then
    slani = {28,29,30,31} //smile - blue
    skani = {33,34,35,36} //skele - skeleton
  else
    slani = {44,45,46,47} //smile - red
    skani = {49,50,51,52} //skele - ghost
  end
  local m = {
    x  = mobx,
    y  = moby,
    hp = 1,
    atk = 1,
    var = variant,
    ani = slani,
    typ = "m"
  }
  local s = {
    x = mobx,
    y = moby,
    hp = 2,
    atk = 2,
    var = variant,
    ani = skani,
    typ = "s"
  }
  if typ == 0 then
    add(mob,m)
  else
    add(mob,s) 
  end
end

function getframe(ani)
  return ani[flr(t/8)%#ani+1]
end

function drawspr(_spr,_x,_y,_c)
   camera(cx,cy)
   spr(_spr,_x,_y)
   camera(0,0)
end

function mobwalk(mob,dx,dy)
  mob.x += dx
  mob.y += dy
end
-->8
-- player & cam movement
function move_player()
  
  --top right dash
  if (btn(➡️) and btn(⬆️)) then
    if (btn(🅾️) and pl.delay == 0) then
     pl.delay = cooldown
     iframe = 32
     for dashx = pl.x,pl.x+pl.dash do
      for dashy = pl.y,pl.y-pl.dash,-1 do
       mob_dmg()
       if not map_collide(dashx,dashy,pl.w,pl.h) then
         pl.x = dashx
         pl.y = dashy 
         spawntrail(pl.x-2,pl.y+4) 
         spawntrail(pl.x+4,pl.y+2)             
       end
      end
     end
    end
  end
  
  --top left dash
  if (btn(⬅️) and btn(⬆️)) then
    if (btn(🅾️) and pl.delay == 0) then
     pl.delay = cooldown
     iframe = 32
     for dashx = pl.x,pl.x-pl.dash,-1 do
      for dashy = pl.y,pl.y-pl.dash,-1 do
       mob_dmg()
       if not map_collide(dashx,dashy,pl.w,pl.h) then
         pl.x = dashx
         pl.y = dashy 
         spawntrail(pl.x+2,pl.y+4)       
         spawntrail(pl.x+4,pl.y+2)          
       end
      end
     end
    end
  end
  
  --bottom right dash
  if (btn(➡️) and btn(⬇️)) then
    if (btn(🅾️) and pl.delay == 0) then
     pl.delay = cooldown
     iframe = 32
     for dashx = pl.x,pl.x+pl.dash do
      for dashy = pl.y,pl.y+pl.dash do
       mob_dmg()
       if not map_collide(dashx,dashy,pl.w,pl.h) then
         pl.x = dashx
         pl.y = dashy 
         spawntrail(pl.x-2,pl.y+4) 
         spawntrail(pl.x+4,pl.y-2)          
       end
      end
     end
    end
  end
  
  --bottom left dash
  if (btn(⬅️) and btn(⬇️)) then
    if (btn(🅾️) and pl.delay == 0) then
     pl.delay = cooldown
     iframe = 32
     for dashx = pl.x,pl.x-pl.dash,-1 do
      for dashy = pl.y,pl.y+pl.dash do
       mob_dmg()
       if not map_collide(dashx,dashy,pl.w,pl.h) then
         pl.x = dashx
         pl.y = dashy 
         spawntrail(pl.x+2,pl.y+4) 
         spawntrail(pl.x+4,pl.y-2)    
       end
      end
     end
    end
  end
  
  --basic movement
  if btn(➡️) then  
    pl.s = 1
    for newx = pl.x,pl.x+speed do
     if not map_collide(newx,pl.y,pl.w,pl.h) then
       pl.x = newx      
     else 
       sfx(0)
     end    
    end  
              
    if (btn(🅾️) and pl.delay == 0)
    then   
      pl.delay = cooldown
      iframe = 32
      for dashx = pl.x,pl.x+pl.basic do
        mob_dmg()
        if not map_collide(dashx,pl.y,pl.w,pl.h) then
          pl.x = dashx 
          spawntrail(pl.x-2,pl.y+4)     
        end    
      end
    end 
       
  elseif btn(⬅️) then
    pl.s = 2
    for newx = pl.x,pl.x-speed,-1 do
      if not map_collide(newx,pl.y,pl.w,pl.h) then
        pl.x = newx       
      else
        sfx(0)
      end
    end
   
    if (btn(🅾️) and pl.delay == 0)
    then
      pl.delay = cooldown
      iframe = 32
      for dashx = pl.x,pl.x-pl.basic,-1 do
       mob_dmg()
       if not map_collide(dashx,pl.y,pl.w,pl.h) then
         pl.x = dashx 
         spawntrail(pl.x+2,pl.y+4)                    
       end                    
      end
    end
  end
    
  
  if btn(⬆️) then
    pl.s = 4
    for newy = pl.y,pl.y-speed,-1 do
      if not map_collide(pl.x,newy,pl.w,pl.h) then  
         pl.y = newy
         
      end
    end 
    
    if (btn(🅾️) and pl.delay == 0)
    then
      pl.delay = cooldown
      iframe = 32
      for dashy = pl.y,pl.y-pl.basic,-1 do
       mob_dmg()
       if not map_collide(pl.x,dashy,pl.w,pl.h) then
         pl.y = dashy        
         spawntrail(pl.x+4,pl.y+2)
       end
      end 
    end
         
  elseif btn(⬇️) then    
    pl.s = 3
    for newy = pl.y,pl.y+speed do
     if not map_collide(pl.x,newy,pl.w,pl.h) then
         pl.y = newy
 
     end 
    end 
    
    if (btn(🅾️) and pl.delay == 0)
    then
      pl.delay = cooldown
      iframe = 32
      for dashy = pl.y,pl.y+pl.basic do
        mob_dmg()
        if not map_collide(pl.x,dashy,pl.w,pl.h) then
          pl.y = dashy 
          spawntrail(pl.x+4,pl.y-2)
        end
      end
    end    
  end  

  pl.delay = max(0, pl.delay-1)
  
  --inventory
  if(timer <= 0) then
    if(btn(❎)) then
      invmenu()
      state = "inv"
    end
  else
    timer -= 1
  end
  
  --sptimer
  if(sptimer <= 0) then
    cooldown = 60
  else
    sptimer = max(0, sptimer-1)
  end
  
  if(skel <= 0) then
   for m in all(mob) do
    if(m.typ == "s") and
      (m.var == 3)then
     m.ani = {49,50,51,52}
     del(hurt, m)
    elseif(m.typ == "s") then
     m.ani = {33,34,35,36}
     del(hurt,m)
    end
   end
  else
   skel = max(0, skel-1)
  end
  
    
end

function cam_movement()
  
  if pl.x < box.x then
    pl.x = box.x
    if (btn(🅾️) and camdelay == 0) then
      cx -= camdash 
    else
      cx -= speed
    end
    
  elseif pl.x > box.x2 then
    pl.x = box.x2
    if (btn(🅾️) and camdelay == 0) then
      cx += camdash   
    else
      cx += speed
    end
  end
  
  if cx <= 0 then
    cx = 0
    box.x = 0
  elseif cx >= 896 then
    cx = 896    
    box.x2 = 127
  else 
    box.x = 32
    box.x2 = 88 
  end
  
  if pl.y < box.y then
    
    pl.y = box.y
    if (btn(🅾️) and camdelay == 0) then
      cy -= camdash   
    else          
      cy -= speed
    end
   
  elseif pl.y > box.y2 then
    
    pl.y = box.y2
    if (btn(🅾️) and camdelay == 0) then
      cy += camdash    
    else          
      cy += speed
    end
    
  end
  
  if cy <= 0 then
    cy = 0
    box.y = 0
  elseif cy >= 385 then
    cy = 385
    box.y2 = 127
  else 
    box.y = 32
    box.y2 = 88
  end

end







-->8
--procedural generation
//draw map once generated
mapGen = {} //locations of walls
allRooms = {} //room data for playable rooms
por = {} //portal location

holes = {
  { {003,011} , {025,002} , {045,003} , {050,013} , {067,002} , {088,008} , {099,003} , {123,002} },
  { {002,026} , {028,018} , {035,029} , {060,018} , {071,024} , {094,030} , {104,024} , {126,017} },
  { {003,035} , {018,045} , {044,035} , {051,035} , {065,046} , {088,040} , {108,035} , {123,040} },
  { {001,062} , {029,061} , {040,059} , {054,062} , {076,061} , {085,061} , {100,050} , {120,058} }
}




//call to generate new map
function generate_map()
  mapGen = {}
  allRooms = {}
  por={}
  mob = {}
  pu = {}
  //create set of rooms
  rooms = {}
  //set values for each room
  for _y=1,4 do
  		for _x=1,8 do
  		room={}
          room.id = #rooms+1
  				room.x = _x
  				room.y = _y
          //doorway settings  0:random  1:border  2:open  3:closed
  				room.up = 0
  				room.left = 0
  				room.right = 0
  				room.down = 0
          room.handled = 0 //if 1, skip when assigning room types
  				add(rooms,room,#rooms+1)
  		end
  end
  

  //
  //main generation code
  //
  //pick starting room & push to stack
  mystack = {}
  st = flr(rnd(32))+1//choose starting room
  while st == 6 or st == 7 or st == 29 or st == 30 or st == 31 do st = flr(rnd(32))+1 end
  cx   = flr((rooms[st].x-1) *132 )
  cy   = flr((rooms[st].y-1) *132 )
  box.x= cx
  box.y= cy
  pl.x = cx+60
  pl.y = cy+60
  
  
  add(mystack,st) 
  //while the stack is not empty
  while next(mystack) != nil do
    
    //pop room & flag as handled
    cr = pop(mystack)
    if rooms[cr].handled == 1 then goto continue end
    rooms[cr].handled = 1
    add(allRooms,cr)

    //update border constraints of room
    setConstrains(cr)
    
    //select room layout
    setLayout(cr)

    //spawn walls
    setWalls(cr)

    //spawn mobs
    setMobs(cr)

    //spawn items
    setItems(cr)
    

    ::continue::
  end

  //spawn end of floor portal
  setEnd(por)

end

function setConstrains(cr)
  if rooms[cr].y == 1 then rooms[cr].up    = 1 end
  if rooms[cr].y == 4 then rooms[cr].down  = 1 end
  if rooms[cr].x == 1 then rooms[cr].left  = 1 end
  if rooms[cr].x == 8 then rooms[cr].right = 1 end
end

function setLayout(cr)
  doorChance = 45
  if rooms[cr].up == 0 and (rnd(100) <= doorChance) then 
    rooms[cr].up    = 2 
    rooms[cr-8].down= 2
    add(mystack,cr-8)
  elseif rooms[cr].up == 0 then
    rooms[cr].up    = 3 
    rooms[cr-8].down= 3
  end

  if rooms[cr].down == 0 and (rnd(100) <= doorChance) then 
    rooms[cr].down  = 2 
    rooms[cr+8].up  = 2
    add(mystack,cr+8)
  elseif rooms[cr].down == 0 then
    rooms[cr].down  = 3 
    rooms[cr+8].up  = 3
  end

  if rooms[cr].left == 0 and (rnd(100) <= doorChance) then 
    rooms[cr].left  = 2 
    rooms[cr-1].right=2
    add(mystack,cr-1)
  elseif rooms[cr].left == 0 then
    rooms[cr].left  = 3 
    rooms[cr-1].right=3
  end

  if rooms[cr].right == 0 and (rnd(100) <= doorChance) then 
    rooms[cr].right = 2 
    rooms[cr+1].left= 2
    add(mystack,cr+1)
  elseif rooms[cr].right == 0 then
    rooms[cr].right = 3
    rooms[cr+1].left= 3 
  end
end

function setWalls(cr)
  //get top-left corner coords of room
  rcY = (16*rooms[cr].y) -16
  rcX = (16*rooms[cr].x) -16
  
  for wran=5,10 do
    if rooms[cr].up == 3 then
      tile = {}
      tile.x = rcX+wran
      tile.y = rcY
      add(mapGen, tile)
    end

    if rooms[cr].down == 3 then
      tile = {}
      tile.x = rcX+wran 
      tile.y = rcY+15
      add(mapGen, tile)
    end

    if rooms[cr].left == 3 then
      tile = {}
      tile.x = rcX
      tile.y = rcY+wran
      add(mapGen, tile)
    end

    if rooms[cr].right == 3 then
      tile = {}
      tile.x = rcX+15
      tile.y = rcY+wran
      add(mapGen, tile)
    end
  end
end

function setMobs(cr)
  //get top-left corner coords of room
  rcY = (16*rooms[cr].y) -15
  rcX = (16*rooms[cr].x) -15
  for i=1,2+level do
    if flr(rnd(10)+1) > 3 then
      GM = {}
      GM.t = flr(rnd(2))
      GM.x = flr(rnd(14)+rcX)
      GM.y = flr(rnd(14)+rcY)
      GM.v = flr(rnd(3)+1)
      if mget(GM.x,GM.y) == 8 then
        addmob(GM.t,GM.x,GM.y,GM.v)
      end
    end
  end

end

function setItems(cr)
  //get top-left corner coords of room
  rcY = (16*rooms[cr].y) -15
  rcX = (16*rooms[cr].x) -15
  for i=1,3 do
    if flr(rnd(10)+1) > 8 then
      foo = {}
      foo.x = flr(rnd(14)+rcX)
      foo.y = flr(rnd(14)+rcY)
      //determine if stamina or health
      if flr(rnd(5)+1) >= 3 then //stamina
        if flr(rnd(5)+1) >= 3 then //half
          foo.s = 41
          foo.v = 21
        else //full
          foo.s = 42
          foo.v = 22
        end
      else // health
        if flr(rnd(5)+1) >= 3 then //half
          foo.s=25
          foo.v = 1
        else //full
          foo.s = 26
          foo.v = 2
        end
      end
      if mget(foo.x,foo.y) == 8 then
        add(pu,foo)
      end
    end
  end
end

function setEnd(por)
  tmp = rooms[rnd(allRooms)]
  if #allRooms > 1 then
    while tmp == rooms[st] do tmp = rooms[rnd(allRooms)] end
  end
  --tmp = rooms[st]
  por.x = holes[ tmp.y][ tmp.x][ 1 ]
  por.y = holes[ tmp.y][ tmp.x][ 2 ]
  por.ani = {55,56,57,58}
end

//Pico-8 stack structure sourced from https://www.lexaloffle.com/bbs/?tid=3389
function pop(stack)
    local v = stack[#stack]
    stack[#stack]=nil
    return v
end

//Pico-8 fade sourced from https://www.lexaloffle.com/bbs/?tid=36250
irisd=0
irisi=92
function iris()
  for i=91,irisi,-1 do
    for j=63,65 do
      circ(j,64,i,0)
    end
  end
  circ(64,64,irisi-1,5)
  irisi+=irisd
  if (irisi<0) irisd=0 irisi=0
  if (irisi>92) irisd=0 irisi=92
end

-->8
-- inventory
function rectfill2(_x,_y,_w,_h,_c)
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function addwind(_x,_y,_w,_h,_txt)
 local w={x=_x,
          y=_y,
          w=_w,
          h=_h,
          txt=_txt}
 add(wind,w)
 return w
end

function drawind()
 for w in all(wind) do
  local wx,wy,ww,wh=w.x,w.y,w.w,w.h
  rectfill2(wx,wy,ww,wh,0)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  if w.curmode then
   wx+=6
  end
  for i=1,#w.txt do
   local txt,c=w.txt[i],6
   if w.col and w.col[i] then
    c=w.col[i]
   end
   print(txt,wx,wy,c)
   if i==w.cur then
    spr(5,wx-5+sin(time()),wy)
   end
   wy+=6
  end
  clip()
 
  if w.dur then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/4
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  else
   if w.butt then
    oprint8("❎",wx+ww-15,wy-1+sin(time()),6,0)
   end
  end
 end
end

function invmenu()
 state="inv"
 txt,col={},{}
 _upd=update_inv
 eqt="wood shield"
 add(col,6)
 add(txt,eqt)
 eqt="leather armor"
 add(col,6)
 add(txt,eqt)
 add(txt,"……………………")
 add(col,5)
 --add potion stuff
 add(txt,"health potion("..hpp..")")
 add(col,8)
 add(txt,"stamina potion("..spp..")")
 add(col,11)
 for i=3,6 do
  local itm=inv[i]
  if itm then
   add(txt,itm_name[itm])
   add(col,6)
  else
   add(txt,"...")
   add(col,5)
  end
 end
 
 invwind=addwind(5,29,84,62,txt)
 invwind.curmode=true
 invwind.cur=4
 invwind.col=col
 
 statwind=addwind(5,17,84,13,{"def: 1  stamina: 1"})
 
end

function move_mnu(wnd)
 if btnp(2) then
  wnd.cur=max(1,wnd.cur-1)
 elseif btnp(3) then
  wnd.cur=min(#wnd.txt,wnd.cur+1)
 elseif btnp(4) and
        wnd.cur == 4 and
        hpp > 0 and
        pl.hp < hpmax then
  hpp -= 1
  pl.hp  += 1
  addwind(5,5,28,13,{pl.hp.."/"..hpmax.."♥"})
  txt[4] = "health potion("..hpp..")"
 elseif btnp(4) and
        wnd.cur == 5 and
        spp > 0 then
  spp -= 1
  sptimer += 60
  cooldown = 30
  txt[5] = "stamina potion("..spp..")"
 end
end
__gfx__
0000000000550000000055000005500000055000700000003535d6535555d6551000000100000000000000000000000000000000000000000000000000000000
0000000005999000000999500099950000555500770000005355d6555555d6550000000000000000000000000000000000000000000000000000000000880000
007007000919100000019190001919000055550077700000dd3dd6ddddddd6dd0000000000000000000000000000000000000000000000000808800008888800
0007700004fff550055fff4000fff40000555500777000006663666666666666000000000000000000000000000000004254f0904254ff904254ff904254ff98
0007700042222650056222240455554004222240770000005556ddd35556dddd0000000000000000000000000000000002f5f99502f5f99582f5f99582f5f995
00700700f55657500575655f0f5665f00f5665f0700000003556d5355556d555000000000000000000000000000000000265f0950265ff950265ff958265ff95
0000000002222500005222200025520000222200000000003dd65355ddd655550000000000000000000000000000000042554950425549504255495042554958
00000000040040000004004000400400004004000000000066666666666666661000000100000000000000000000000000f4000000f4000008f4080008f48800
00000000000000000000000000000000000000000000000000000000007770000777777000000000000000000000000000000000000000000000000000000000
000000000000000000bbb00000bbb00000000000000000000000000007000700700000070666660006666600000000000000000000ccc00000ccc00000000000
0000000000bbb0000b0bbb000b0bbb00000000000000000000000000070007007000000700606000006060000000000000ccc0000c6ccc000c6ccc0000000000
000000000b0bbb000b0bbb00b0bbbbb00bbbbbb0000000000000000000777000077777700600060006888600000000000c6ccc000c6ccc00c6ccccc00cccccc0
00000000b0bbbbb00bbbbb00bbbbbbb0b00bbbbb00000000000000000788870077888877607000606878886000000000c6ccccc00ccccc00ccccccc0c66ccccc
00000000bbbbbbb00bbbbb000bbbbb00bbbbbbbb00000000000000007888887078888887678888606788886000000000ccccccc00ccccc000ccccc00cccccccc
000000000bbbbb0000bbb000000000000bbbbbb0000000000000000078888870778888776888886068888860000000000ccccc0000ccc000000000000cccccc0
00000000000000000000000000000000000000000000000000000000077777000777777006666600066666000000000000000000000000000000000000000000
00000000007700000077000000770000007700000088000000000000007770000777777000000000000000000000000000000000000000000000000000000000
00000000070707000707070007070700070707000808080000000000070007007000000706666600066666000000000000000000008880000088800000000000
0000000007777700077777000777770007777700088888000000000007000700700000070060600000606000000000000088800008e8880008e8880000000000
0000000077000700070007007700070077000700880008000000000000777000077777700600060006bbb6000000000008e8880008e888008e88888008888880
0000000070777070707770707077707570777070808880800000000007aaa70077aaaa77607000606b7bbb60000000008e88888008888800888888808ee88888
000000000700075007000705070007000700075008000850000000007aaaaa707aaaaaa767bbbb6067bbbb600000000088888880088888000888880088888888
000000000777770077777700077777000777770008888800000000007aaaaa7077aaaa776bbbbb606bbbbb600000000008888800008880000000000008888880
00000000070007000700070007000700070007000800080000000000077777000777777006666600066666000000000000000000000000000000000000000000
000000000077770000777700007777000077770000000000000000000002200880220000001110000c0000080000000000888800008888000088880000888800
000000000777777007777770077777700777777000000000000000000c236208086321000c631c00c00022000000000008888880088888800888888008888880
000000000707077007777770077070700707077000000000000000001c366680263666cc013661c000c166800000000008080880088888800880808008080880
00000000070707700777777007707070070707700000000000000000163666202636661c263666c001c666620000000008080880088888800880808008080880
00000000077777700777777007777770077777700000000000000000136663622366636123666361136663620000000008888880088888800888888008888880
000000000777777007777770077777700777777000000000000000000c55555282555551085555510c5555200000000008888880088888800888888008888880
00000000077077700770777007707770077077700000000000000000c01555100c55551080255520c01555200000000008808880088088800880888008808880
000000000700070707000700070707000707070700000000000000000c0111000c111100000222000c0112000000000008000808080008000808080008080808
00000000000777777777776000777777777777600077760000077760000000000000000000000000000000000000000000000000000000000000000000000000
000000000007888888888760007bbbbbbbbbb760007cc760007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000007888888888760007bbbbbbbbbb760007ccc7607ccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000007888888888760007bbbbbbbbbb760007cccc77cccc760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777788877776000777bbbbbb77760007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888766660000077bbbb776660007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb766000007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb760000007cccccccccc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb760000007cc7cccc7cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000007bbbb760000007cc77cc77cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000000077bbbb776660007cc707767cc760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000788876000000777bbbbbb77760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000007bbbbbbbbbb760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000007bbbbbbbbbb760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
000000000000007888760000007bbbbbbbbbb760007cc700007cc760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000777776000000777777777777600077770000777760000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000877880000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008880000878880008788800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000087888000888880087888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000878888800888880088888880088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888800888880088888880877888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888800888880008888800888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888000088800000000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000c77cc0000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ccc0000c7ccc000c7ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c7ccc000ccccc00c7ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c7ccccc00ccccc00ccccccc00cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccc00ccccc00ccccccc0c77ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccc00ccccc000ccccc00cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ccccc0000ccc000000000000cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70707070707080808080807070707070707070707070808080808070707070707070707070808080707070707070707060707070707080808080806070707070
70707070707070808080707070707070707070707070808080808070707070707070707070808080808070707070707070707070707080808080707070707070
70808080808080808080808080808070708080808080808080808080808080707080808080808080706060808080807070808080808080808080808080808070
70808080808080808080708080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080706080808080807070808080808080808080808080808070
70808080808080808080708080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080608080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080608080808080807070808080807080808080708080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808070808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808070706060608080808080807070808080707080808080707080808070
70808080808080808080808060606060708080808080808080808080808080707080808080808080808070707070707070808080808080606080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808060708080808080808080808080808080707080808080808080808080808080807070808080808080607080808080808070
70707070707080808080808080808080808080808080707070708080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808080808080808080607070708080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808080808080808080606060708080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080707080808080707080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080707080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080708080808080807080808070
70707060606080808080808080808070708080808080808080808080808080607080808070808080808080808080808070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080806080808070808080808080808080808060808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080806080806080808070808080808080808080808060808080808080808080808080808070
70707070707080808080807070707070707070707070808080808070707070707070707070708080808080707070707070707070707080808080807070707070
70707070707080808080807070707070707070707070808080808070707070607070707070708080808080708080808070707070707080808080807070707070
70707070707080808080807070707070707070707070808080808070707070707070707070708080808080707070707070707070707080808080807070707070
70707070707080808080807070707070706070707070808080808070707060707060707070708080808080707070707070707070707080808080807070707070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070608080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070
70808080807080808080808080808070708080707080808080808070708080707080808080808080808080808080807070808080808080808080808080808070
70808080808080808080808080808070708080808080808080808080808080707080808070708080808070708080807070808080808080808080808080808070
70707070707080808080808080808070708080708080808080808080708080707080808080808080808080808080807070808080707080808080807070808070
70808080807080808080608080808070708080808080808080808080808080707080808070808080808080708080807070808080808080808080808080808070
60808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080708070808080708070808070
70808080808070706060808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080708070808070808070
70808080808070707060808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080807080808070808070
70808080808070707070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080808080808070808070
70808080807080808080708080808080808080807070708080707070808080808080808080808080808080808080808080808080808080808080808080808080
80808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080708080808080808060808070
70808080808080808080808080808070708080808080708080708080808080707080808070808080808080708080806060808080707080808080707080808070
70808080808080808070808080808070708080807070708080707070808080707080808070808080808080708080807070808080708080808080808060808070
60808080808080808080808080808070708080808080708080608080808080707080808070708080808070708080806060808080708080808080807080808070
70808080808080808070808080808070708080708080808080808080708080707080807080808080808080807080807070808080708080808080808060808070
70808080808080808080808080808070708080808080708080608080808080707080808080808080808080808080806070808080708080808080807080808070
70808080808080808070808080808070708080708080808080808080708080707080708080808080808080808070807070808080808080808080808080808070
60808080808080808080808080808070708080808080707070608080808080707080808080808080808080808080806070808080708080808080807080808070
70808080808080808070808080808070707070708080808080808080707070707070808080808080808080808080707070808080808080808080808080808070
60607070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
70707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
__gff__
0000000000000808000000000000000000000000000000040400000000000000000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0606060707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070606060707070707070707
0608080808080808080808070808080607080808080808070808080808080807070808080707070707070606080808070708080808080808080808080808080707080808080807080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0608080808080808080808070808080707080808080808070808080808080807070808080807070707060608080808070708080808080808080808080808080707080808080806080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0708080808080808080808070808080707080808080808060808080808080807070808080807070707060608080808070708080808080808080808080808080707080808080806080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0707070707070808080808070808080707080807070706060606070808070707070808080807070707070608080808070708080807080808080808060808080707080808080806080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808070808080808080807
0708080808080808080808070808080707080808080808070808080808070807070808080808080808080808080808070708080808080808080808080808080707080808080807080808080808080807070808080808080808080808080808070708080808080807070808080808080707080808080808080808080808080807
0708080808080808070707070808080707080808080808070808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080606080808080808070708080808080807070808080808080707080808080808080808080808080807
0708080808080808080808080808080808080808080808070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070706070808080808080808080808080807060808080808080808080808080808060808080808080807
0708080808080808080808080808080808080808080808070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080807070808070708080808080808080808060606060707080808080808080808080808060808080808080807
0707070707070708080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080707070808070707080808080808080808080807070808080808080808080808080808060606060707070707
0708080808070708080808080808080707080808080808080808080808080808080808080808080808080808080808080808080806080808080808070808080808080808080808080808080808080808080808080808080808080808080808080808080808080807070808080808080808080808080808080808080808080807
0708080808070708080808080808080707080808080808080808080808080807070808080808080808080808080808060708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080807070808080808080707080808080808080808080808080807
0708080808070708080707080807070707070706060608080808080808080807070808080808080808080808080808060708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080708080808070707080808080608080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808070707070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080708080808070707080808080808080808080808080807060808080808080808080808080808070708080808080808080808080808080707080808080808080808080808070707070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080806
0607070707070808080707070707070707070707070707080808070707070707060606070708080808080807070707070707070707070708080807070707070707070707070707080807070707070707070707070707080808080807070707070707070707070708080807070707070707070707070707080808070707070606
0606070707070808080707070707070707070707070707080808070707070707070707070708080808080807070707070707070707070708080807070707070707070707070707080807070707070707070707070707080808080807070707070707070707070708080807070707070707070707070707080808070707070707
0608080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0608080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808070708080808080806060808070708080808080808080808080808080707080808080808080808080808080807
0708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080807080808080707080808080808080808080808080807070808070708080808080806070808070708080808080708080807080808080707080808080808080808080808080807
0708080808080808080808080707070707080808080808080806060606070707070808080808080808080808080808070708080808080808080807070808080707080808080808080808080808080807070808080808080808080808080808070708080808070808080808070808080707080808080707070707070808080807
0708080808080808080808080808080707080808080808080808080808080807080808080808080808080808080808080808080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080807080808080808080708080707080808080808070708080808080807
0708080808080808080808080808080808080808080808080808080808080808080808080808070707070808080808080808080808080808080808080808080808080808080807070707080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070708080808080807
0707070707070808080808080808080808080808080808080808080808080808080808080707070707070707080808080808080808080808080808080808080808080808080807080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070708080808080807
0708080807070808080808080808080808080808080808080808080808080808080808080808070707070808080808080808080808080808080808080808080808080808080807070708080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808070708080808080807
0708080807070808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080806080808080808080708080707080808080808070708080808080807
0708080807070808080808080808080707080808070708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808070708080808080807070808070708080808060808080808070808080707080808080808080808080808080807
0708080808080808080808080808080707080808080708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808070708080808080807070808080708080808080608080807080808080807080808080808080808080808080807
0708080808080808080808080808080707080808080708080808080808080807070808080808080808080808080808070708080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808080708080808080808080808080808080807080808080808080808080808080807
0708080808080808080808080808080707080808080708080808080808080807070808080808080808080808080808070608080808080808080808080808080707080808080808080808080808080807070808080808080808080808080808070708080808080808080808080808080807080808080808080808080808080807
0707070707070808080808070707070707070707070708080808080707070707070707070707080808070707070707070606060707070808080808070707070707070707070707080808070707070707070707070707080808080807070707070707070707080808080807070707070707070606060708080808070707070707
__sfx__
0001000008010080100a01008010090100d010110200e0200f0201202003020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
