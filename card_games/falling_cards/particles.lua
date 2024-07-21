--[[pod_format="raw",created="2024-07-12 05:05:08",modified="2024-07-16 08:09:55",revision=2635]]

-- x, y, z, dx, dy, dz, drx, dry, lx, ly
local particles = {}
local colors = {32,20,4,25,9,10,7}

-- {x, y, time_left, {{sp, sx, sy, sw, sh, x2, y2}, ...}, extra_time}
local text_particles = {}
local total_life = 150

-- {x, y, start_t}
local explode_particles = {}

local dither = {
	0b1111111111111111,
	0b1111111111110111,
	0b1111110111110111,
	0b1111110111110101,
	0b1111010111110101,
	0b1111010110110101,
	0b1110010110110101,
	0b1110010110100101,
	0b1010010110100101,
	0b1010010110100001,
	0b1010010010100001,
	0b1010010010100000,	
	0b1010000010100000,
	0b1010000000100000,
	0b1000000000100000,
	0b1000000000000000,
	0b0000000000000000,
}

function particles_draw()
	for p in all(particles) do	
		--local c = abs(p[6])*7+1
		local c = p[11]/15
		c = colors[mid(c, 1, 7)\1]
		
		line(p[7], p[8], p[9], p[10], c)
		
		if p[11] > 122 then
			circfill(p[7], p[8], 2, c)
		elseif p[11] > 90 then
			circfill(p[7], p[8], 1, c)
		end
		
	end
	
	for p in all(explode_particles) do
		local t2 = time() - p[3]
		draw_explosion(p[1], p[2], t2)
		if t2 > 2 then
			del(explode_particles, p)
		end
	end

--	local mx, my = mouse()
--	draw_explosion(mx, my, (time() - 5))

	local oldp = peek(0x5f33)
	poke(0x5f33, 2)
	for p in all(text_particles) do
		local x, y = p[1], p[2]
		
		local pat1 = mid((1-p[3]/total_life)*17*5\1, 1, 17)	
		local pat2 = mid(((p[3]+p[5])/total_life)*17*4\1, 1, 17)	
		
		fillp(dither[min(pat1, pat2)])
		for s in all(p[4]) do
			sspr(s[1], s[2],s[3], s[4],s[5], x+s[6], y+s[7])
		end
		
	end
	poke(0x5f33, oldp)
	fillp()
end

function particles_update()
	for p in all(particles) do		
		
		local x,y,z = p[1], p[2], p[3]
		
		p[6] -= 0.1 -- gravity
		
		-- move
		x += p[4]
		y += p[5]
		z += p[6]
		
		-- hit ground
		if z < 0 and p[6] < 0 then
			p[4] *= 0.8
			p[5] *= 0.8
			p[6] *= -0.7	
			z = 0
		end
		
		p[7], p[8], p[9], p[10] = x, y-z*4, p[7], p[8]
		
		p[1], p[2], p[3] = x,y,z
		
		p[11] -= 1
		if p[11] <= 0 then
			del(particles, p)
		end
		
	end
	
	for p in all(text_particles) do
		p[2] -= 0.1 + ((max(p[3]) / total_life) ^ 2) * 0.7
		p[3] -= 1
		if p[3] + p[5] <= 0 then
			del(text_particles, p)
		end
	end
end


function new_particles(x, y, n, v)
	v = v or 1.5
	for i = 1,n do
		add(particles, {
			x+rnd(4)-2,y+rnd(4)-2,0, 
			rnd(v*2)-v,rnd(v*2)-v,1+rnd(0.5) * v/1.5, 
			x,y,x,y, 
			100+rnd(40)
		})
	end
end

function sparks_on_change(x, y, old, new)
	old = tostr(old)
	new = tostr(new)
	for i = 1, max(#old, #new) do
		if sub(old,i,i) ~= sub(new,i,i) then
			new_particles(x-(i-1)*7, y, 7, 0.8)
		end
	end
end

-- value can be a number or a sprite
function new_text_particle(x, y, val, extra_time)
	
	local ty = type(val)
	if ty == "number" then
		val, ty = get_spr(val), "userdata"
	end
	
	if ty == "userdata" then
		x -= val:width()\2
		y -= val:height()\2
		
		add(text_particles, {
			x, y, total_life,
			{{val, 0, 0, val:width(), val:height(), 0, 0}},
			extra_time or 20
		})
		
	elseif ty == "string" then -- only accepts number characters here
		local p = add(text_particles, {
			x - #val*4 - 4, y - 7, total_life,
			{},
			extra_time or 20
		})[4]
		
		-- + sign
		add(p,{
			283,
			0,0, 8,15,
			0,0
		})
			
		for i = 1,#val do
			local n = tonum(sub(val, i, i))
			add(p,{
				282,
				n*8,0, 8,15,
				i*8, 0
			})
		end
		
	end
end


-- colors to be used for the smoke
local exp_cols = {get_spr(15+256):get(0,0,13)}

-- generate extra puffs of smoke
local old_rand = rnd()
srand(2)-- set seed
local exp_pufs = {}
for i = 1,30 do
	local a = rnd()
	local am = rnd(60) + 20
	add(exp_pufs, {sin(a)*am, cos(a)*am * 0.7})
end
srand(old_rand*0xffffffff)

function draw_explosion(x, y, t)
	if(t < 0) return
	t *= 5
	local sp = userdata("u8", 41, 41)
	
	-- draw to the new sprite
	set_draw_target(sp)
	
	-- base circle
	local r = min((t^0.5)*15, 20)
	circfill(20, 20, r, 2)
	
	-- dithering color overlapping the upper color
	poke(0x8040, 0)
	fillp(0xf5f5)
	circfill(20, 30, r, 1)
	fillp(0xa5a5)
	circfill(20, 35, r, 1)
	fillp(0xa0a0)
	circfill(20, 35, r-6, 1)
	fillp()
	circfill(20, 35, r-12, 1)
	poke(0x8040, 1)
	
	-- clear inside circle
	local old = peek(0x550b)
	poke(0x550b, 0)
	circfill(20, 30, (t - 2)*10, 0)
	poke(0x550b, old)
	
	set_draw_target()
	
	-- prepare colors for the puffs
	local c = mid(t*4 - 2, 2, 13)\1
	pal(2, exp_cols[c])
	pal(1, exp_cols[c-1])
	
	local t2 = 1 + (t^0.6) * 0.7 - 0.8
	local y2 = (t^2) * 2
	
	-- extra puffs of smoke shoot out
	local r = 5-t
	for p in all(exp_pufs) do
		circfill(x + p[1]*t2+20, y + p[2]*t2+30 - y2*0.5, r, 2)
	end
	--circfill(x + 70*t2, y + 70*t2, 3, 2)

	-- main puffs of smoke
	spr(sp, x+5*t2, y - 20*t2 - y2*1.15)
	spr(sp, x - 20*t2, y - 15*t2 - y2*1.15)
	spr(sp, x + 20*t2, y - 10*t2 - y2*1.15)
	spr(sp, x, y - y2*1.3)
	spr(sp, x - 25*t2, y + 10*t2 - y2)
	spr(sp, x + 20*t2, y + 15*t2 - y2)
	spr(sp, x-5*t2, y + 20*t2 - y2)
	
	-- reset palette
	pal(2, 2)
	pal(1, 1)
end

function new_explode_particle(x, y)
	add(explode_particles, {x-20, y - 20, time()})
end

