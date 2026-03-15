local timer = 0.0

function init()
    timer = 0.0
end

function step()
    timer = timer + 1.0

    -- Add your NPC-like scripted behavior here.
    -- Current modding support treats this as a scripted entity,
    -- not as a native built-in creature class.
end
