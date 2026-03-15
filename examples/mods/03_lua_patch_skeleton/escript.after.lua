function approach(value, target, speed)
    if value < target then
        value = value + speed
        if value > target then
            value = target
        end
    elseif value > target then
        value = value - speed
        if value < target then
            value = target
        end
    end

    return value
end
