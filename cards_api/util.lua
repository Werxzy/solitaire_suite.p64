--[[pod_format="raw",created="2024-03-26 04:14:49",modified="2024-03-27 23:01:47",revision=228]]
-- returns the key of a searched value inside a table
-- such that tab[has(tab, val)] == val
function has(tab, val)
	for k,v in pairs(tab) do
		if v == val then
			return k
		end
	end
end

-- returns the key of a searched value inside a table
-- such that tab[has(tab, key, val)][key] == val
function has_key(tab, key, val)
	for k,v in pairs(tab) do
		if v[key] == val then
			return v, k 
		end
	end
end

-- aabb point to box collision
function point_box(x1, y1, x2, y2, w, h)
	x1 -= x2
	y1 -= y2
	return x1 >= 0 and y1 >= 0 and x1 < w and y1 < h 
end 

-- you know what this is
function lerp(a, b, t)
	return a + (b-a) * t
end


-- yields a certain number of times
-- may need to be updated in case low battery mode causes halved update rate
function pause_frames(n)
	for i = 1,n do
		yield()
	end
end

-- maybe stuff these into userdata to evaluate all at once?
function smooth_val(pos, damp, acc, lim)
	lim = lim or 0.1
	local vel = 0
	return function(to, set)
		if to == "vel" then
			if set then
				vel = set
				return
			end
			return vel
			
		elseif to == "pos" then
			if set then
				pos = set
				return
			end
			return pos -- not necessary, but for consistency
		end
		
		if to then
			local dif = (to - pos) * acc
			vel += dif
			vel *= damp
			pos += vel
			if abs(vel) < lim and abs(dif) < lim then
				pos, vel = to, 0
			end
		end
		return pos
	end
end

function smooth_angle(pos, damp, acc)
	local vel = 0
	return function(to)
		if to == "vel" then
			if set then
				vel = set
				return
			end
			return vel
			
		elseif to == "pos" then
			if set then
				pos = set
				return
			end
			return pos -- not necessary, but for consistency
		end
		
		if to then
			local dif = ((to - pos + 0.5) % 1 - 0.5) * acc
			vel += dif
			vel *= damp
			pos += vel
			if abs(vel) < 0.0006 and abs(dif) < 0.007 then
				pos, vel = to, 0
			end
		end
		return pos
	end
end

function quicksort(tab, key)
	local function qs(a, lo, hi)
		if lo >= hi or lo < 1 then
			return
		end
			    
		-- find pivot
		local lo2, hi2 = lo, hi
		local pivot, p = a[hi2], lo2-1
		for j = lo2,hi2-1 do
			if a[j][key] <= pivot[key] then
				p += 1
				a[j], a[p] = a[p], a[j]
			end
		end
		p += 1
		a[hi2], a[p] = a[p], a[hi2]
		    
		-- quicksort next step
		qs(a, lo, p-1)
		qs(a, p+1, hi)
	end
    qs(tab, 1, #tab)
end


-- THE NORMAL PRINT WRAPPING CANNOT BE TRUSTED
function print_wrap_prep(s, width)
	local words = split(s, " ", false)
	local lines = {}
	local current_line = ""
	local final_w = 0
	
	for w in all(words) do
		local c2 = current_line == "" and w or current_line .. " " .. w
		local x = print(c2, 0, -1000)
		if x > width then
			current_line = current_line .. "\n" .. w
		else
			current_line = c2
			final_w = max(final_w, x)
		end
	end
	local _, final_h = print(current_line, 0, -1000)
	final_h += 1000
	
	return final_w, final_h, current_line
end

function double_print(s, x, y, c)
	print(s, x+1, y+1, 6)
	print(s, x, y, c)
end

-- traverses all folders inside a starting folder
-- does not include itself
function folder_traversal(start_dir)

	local current_dir = start_dir
	local prev_folder = nil
	
	function exit_dir()
		current_dir, prev_folder = current_dir:dirname(), current_dir:basename()
	end
	
	return function(cmd, a)
		if cmd then
			if cmd == "exit" then -- exits current directory early
				exit_dir()
			elseif cmd == "find" then -- returns true if a specific file is found
				return has(ls(current_dir), a)
			end
			
			return 
		end
		
		if not prev_folder then
			prev_folder = ""
			return current_dir
		end
		
		while #current_dir >= #start_dir do
			local list = ls(current_dir)
			
			for i, f in next, list, has(list, prev_folder) do
				if not f:ext() then -- folder
					current_dir ..= "/" .. f
					return current_dir
				end
			end
			
			exit_dir()
		end
	end
end