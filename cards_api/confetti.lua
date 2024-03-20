--[[pod_format="raw",created="2024-03-20 00:52:48",modified="2024-03-20 14:38:52",revision=2549]]

-- TODO change to user data?

confetti_all = {}
confetti_color_sets = {
	{21,2,24,8},
	{4,25,9,10},
	{1,16,12,28},
	{19,3,27,11}
}

function confetti_new(x, y, n, vel)
	for i = 1,n do
		local a, s = rnd(), rnd(vel)+0.1
		add(confetti_all, {
			x = x, y = y,
			dx = cos(a)*s, dy = sin(a)*s,
			f = rnd(0.2)+1, f2 = rnd(),
			size = rnd(1.5)+1.5,
			a = rnd(),
			c = rnd(4)\1+1
		})
	end
end

local mlx, mly = mouse()

function confetti_update()
	local mx, my = mouse()
	local mdx, mdy = mx - mlx, my - mly
	mlx, mly = mx, my
	
	local t = time() * 0.25
	for c in all(confetti_all) do
		
		-- swing
		local t = t * c.f + c.f2
		c.dx += sin(t) * 0.06
		c.dy -= abs(cos(t + 0.1)) * 0.06
		
		-- drag
		c.dx *= 0.94
		c.dy *= 0.94
		
		--gravity
		c.dy += 0.06
		
		-- mouse interaction
		local mdist = max(1/(0.5+sqrt((c.x-mx)^2+(c.y-my)^2)) - 0.02)
		c.dx += mdx * mdist
		c.dy += mdy * mdist
		
		-- movement
		c.x += c.dx
		c.y += c.dy
		
		-- rotate based on velocity
		c.a += 0.01 + c.dx * 0.02
		
		if c.y > 280 then
			del(confetti_all, c)
		end
	end
end

function confetti_draw()
	for c in all(confetti_all) do
		local col = confetti_color_sets[c.c][c.a*8%4\1 + 1]
		local w = sin(c.a) * c.size
		
		-- cheaper draw
		--rectfill(c.x-w, c.y, c.x+w, c.y+c.size*2, col)
		
		local dy = cos(c.a)*0.5
		local y = c.y - dy*abs(w)/2
		for x = c.x-w,c.x+w,sgn(w) do
			rectfill(x, y, x, y+c.size*2, col)
			y += dy
		end
	end
end


