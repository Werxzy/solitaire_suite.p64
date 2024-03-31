--[[pod_format="raw",created="2024-03-29 08:45:43",modified="2024-03-31 21:35:44",revision=116]]
function get_info()
    return {
        {
            sprite = card_back_art, artist = "Fletch", id = 333, -- consistent, but unique id
            lore = "This duck has somewhere to be!",
            -- animation table
            step=0,
            steps_per_frame=6,
            current_frame=1,
            frames={
                unpod("b64:bHo0ADQAAAAyAAAA8CNweHUAQyANDgSQB4AngDeAFwAXcIcgRyCXMAcAZzAXAEdQFyAXYEeAF4AXEAdwBzAXMA=="),
                unpod("b64:bHo0ADMAAAAxAAAA8CJweHUAQyANDgTwBweAJ4A3gBcAF3CHIEcglzAHAGcwFwBHUBcgF2BHgAcAB4AHEBdA"),
                unpod("b64:bHo0AC8AAAAtAAAA8B5weHUAQyANDgTwBDdwN4AXABdwhyBHIJcwBwBnMBcAR1AXIBdgR4AXoBewF1A="),
                unpod("b64:bHo0ADQAAAAyAAAA8CNweHUAQyANDgSQB4AngDeAFwAXcIcgRyCXMAcAZzAXAEdQFyAXYEeABwAHkAcAF4AXYA=="),
            }
        }
    }
end

function card_back_art(init, data)
	local anim_width, anim_height = 13,14

    -- check if we're updating the displayed frame on this call
    data.step += 1
    data.step %= data.steps_per_frame
    if data.step == 0 then
        -- advance the animation, looping back to beginning if we go off the end
        data.current_frame %= #data.frames
        data.current_frame += 1
    end

    -- center the animation inside of the card
    local draw_x = card_art_width \ 2 - anim_width \ 2
    local draw_y = card_art_height \ 2 - anim_height \ 2

    -- draw a blue background... should this be cls(1) instead?
    rectfill(0,0,card_art_width,card_art_height,19)
	
    -- draw the animation frame
    spr(data.frames[data.current_frame], draw_x, draw_y)

    -- return true if the card art has been updated (this adds the card border)
    return true
end