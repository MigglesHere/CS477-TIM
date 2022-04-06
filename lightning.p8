pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
function _init()
  init_player()
  mx = 0
  my = 0
 
  cx = 0
  cy = 0
  map_x = 0
  hill_x = 0
  mnt_x = 0
  map_spd = 1
  hill_spd = 0.5
  mnt_spd = 0.25
  
  state = "game"
  
  score = 0
end

function _update()
  if state == "game" then
		  move_player()
		  map_x -= map_spd
		  if map_x<- 127 then map_x = 0 end
		  hill_x -= hill_spd
		  if hill_x<- 127 then hill_x = 0 end
		  mnt_x -= mnt_spd
		  if mnt_x<- 127 then mnt_x = 0 end
		  
		  if pl.x > 127 then
		    cx = 128
		  else 
		    cx = 0
		  end
		  
		  //mnt_spd += .0005
		  //map_spd += .0005
		  //hill_spd += .0005
		
  elseif state == "over" then
    mnt_spd = 0
    map_spd = 0
    hill_spd = 0
  end
end

function _draw()
  if state == "game" then
		  cls(12)
		  print("score: " .. score, 7)
		  camera(cx,cy)
		  -- map(mx,my)
		  map(32,0,mnt_x,0,16,16)
		  map(32,0,mnt_x+128,0,16,16)
		  map(16,0,hill_x,0,16,16)
		  map(16,0,hill_x+128,0,16,16)
		  map(0,0,map_x,0,16,16)
		  map(0,0,map_x+128,0,16,16)
		  draw_player()
		
		elseif state == "over" then
		  print("game over", 50, 40, 7)
		  print("press ❎ to restart", 30,48,7)
		  if btn(❎) then
		    _init()
		  end
		end
 
end


function c_collide(x, y, w, h)

  s1 = mget(x/8, y/8)
  s2 = mget((x+w-1)/8, y/8)
  s3 = mget(x/8, (y+w-1)/8)
  s4 = mget((x+w-1)/8, (y+w-1)/8)
  
  if fget(s1, 2) then
    return true
  elseif fget(s2, 2) then
    return true
  elseif fget(s3, 2) then
    return true
  elseif fget(s4, 2) then
    return true
  end
  return false
  
end
-->8
---movement---
function init_player()
  pl = {}
  pl.x = 0
  pl.y = 80
  pl.ox = 0
  pl.oy = 80
  pl.w = 16
  pl.h = 16
  
  //jump stuff
  pl.jf = 0 //jump force
  pl.jt = true //jump allowed
  pl.jm = 12 //jump max
  
  x = 1
  
  grav = 2
  
end

function draw_player()
  spr(8,pl.x,pl.y)
  spr(9,pl.x+8,pl.y)
  spr(24,pl.x,pl.y+8)
  spr(25,pl.x+8,pl.y+8)
end

function move_player()
  //
  //jump handling
  //
  
  //jump held
  if btn(⬆️) and pl.jt then
    pl.jf =  -3 
  end
  
  //max height reached
  if pl.y > 80-pl.jm or not pl.jt then
    pl.jt = false
    pl.jf += .1
  end
  
  //player is on ground
  if pl.y == 80 and not btn(⬆️) then
    pl.jt = true
    pl.jf = 0
  end
  
  //move player
  pl.y += pl.jf
  
  //enforce boundarys
  if pl.y > 80 or pl.y < 0 then
    pl.y = 80
  end
  
  if c_collide(x, pl.y, pl.w, pl.h) then
    
    state = "over"
    
  end
  
  
  if x >= 128 then
    x = 1
    score += 1
  else
    x += 1
  end
  
end
-->8


__gfx__
00000000000000000000000008888888888880004444444400000000000000000000000008888880000000000000000000000000000000000000000000000000
00000000000000000000000008888888888880004444444400000000000000000000000088188888000000000000000000000000000000000000000000000000
00700700000000000000000888088888888888804444444400000000000000000000000088888888000000000000000000000000000000000000000000000000
00077000000000000000000888888888888888804444444400000000000000000000000088888888000000000000000000000000000000000000000000000000
00077000000000000000000888888888888888804444444400000000000000008000000088888888000000000000000000000000000000000000000000000000
00700700000000000000000888888888888888804444444400000055500000008000000a88888000000000000000000000000000000000000000000000000000
00000000000000000000000888888888888888804444444400000555550000008800008a88888880000000000000000000000000000000000000000000000000
000000000000000000000008888888888888888044444444000005555500000088800a8a88880000000000000000000000000000000000000000000000000000
000000000000000000000008888888888888888000000000000005555500050088888a8a88880000000000000000000000000000000000000000000000000000
00000000000000000000000888888800000000000055550000000555550055508888888888888800000000000000000000000000000000000000000000000000
00000000000000000000000888888888888000000544445000000555550055500888888888880800000000000000000000000000000000000000000000000000
00000000000800000000000a88888888888000005444444505000555550055500088888888880000000000000000000000000000000000000000000000000000
0000000000080000000000aa88888000000000004444554455500555550055500008888888800000000000000000000000000000000000000000000000000000
00000000000800000000a8aa88888000000000004444444455500555550055500000888888000000000000000000000000000000000000000000000000000000
0000000000088000008aa8aa88888000000000004454444455500555550055500000800080000000000000000000000000000000000000000000000000000000
00000000000888000a8aa8aa88888880000000004444444455500555550555500000880088000000000000000000000000000000000000000000000000000000
0000000000088888aa8aa8aa88888080000000000000000055500555555555000000000b00000000bbbbbbbb0000000000000000000000000000000000000000
0000000000088888aa8aa8aa8888800000000000000000005550055555555000000000bbb00b0000bbbbbbbb0000000000000000000000000000000000000000
00000000000888888a88a88a8888800000000000000000005550055555000000000000bbb0bbb000bbbbbbbb0000000000000000000000000000000000000000
00000000000888888a88a88a8888800000000000000000005555055555000000000000bbb0bbb000bbbbbbbb0000000000000000000000000000000000000000
0000000000008888888888888888800000000000555555550555555555000000000000bbb0bbb000bbbbbbbb0000000000000000000000000000000000000000
0000000000000888888888888888800000000000445444440055555555000000000b00bbbbbbb000bbbbbbbb0000000000000000000000000000000000000000
000000000000008888888888888800000000000044445544000005555500000000bbb0bbbbbb0000bbbbbbbb0000000000000000000000000000000000000000
000000000000000888888888888800000000000045444445000005555500000000bbb0bbb0000000bbbbbbbb0000000000000000000000000000000000000000
000000000000000088888888888000000000000000000000000005555500000000bbb0bbb0000000000000000000000000000000000000000000000000000000
000000000000000008888888880000000000000000000000000005555500000000bbbbbbb0000000000000000000000000000000000000000000000000000000
0000000000000000088800000888000000000000000000000000055555000000000bbbbbb0000000000000000000000000000000000000000000000000000000
0000000000000000088000000000000000000000000000000000055555000000000000bbb0000000000000000000000000000000000000000000000000000000
00000000000000000800000000000000000000005555555500000555550000005555555555555555000000000000000000000000000000000000000000000000
00000000000000000888000000000000000000004444444400000555550000004444444554444544000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000005444445500000555550000004544454444444454000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000004444544400000555550000004445444445554444000000000000000000000000000000000000000000000000
00000006600000000000000dd0000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000006666000000000000dddd000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000006666660000000000dddddd00000000005555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006666666600000000dddddddd0000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006666666666000000dddddddddd000000555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
006666666666660000dddddddddddd00005555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666666666666600dddddddddddddd0055555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666666666666dddddddddddddddd555555555555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666600000000dddddddd00000000555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000c0c0c000000000000000000000000000c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000040505041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000004050505050410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000004041000000000000000000000000000000445454545454544500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000405050410000000000000000000000000044545454545454545445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000c0000000042525252524300000040410000000000004454545454545454545454450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000c0000004252525252525243004252524300000000445454545454545454545454544500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000282900425252525252525252525252525243000044545454545454545454545454545445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2515252525152525251525252525383942525252525252525252525252525252434454545454545454545454545454545454450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
