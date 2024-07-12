--[[pod_format="raw",created="2024-07-12 05:05:08",modified="2024-07-12 07:38:18",revision=521]]

-- x, y, z, dx, dy, dz, drx, dry, lx, ly
local particles = {}
local colors = {32,20,4,25,9,10,7}

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
