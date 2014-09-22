function finished= circumnavigate(serPort)
    forward= .2;
    angle= 0;
    finished= 0;
    forceContact(serPort)
    while true
        orientToWall(serPort)
        traverseWall(serPort)
        turnCorner(serPort)
    end
        
function forceContact(serPort)
    BumpFront = 0
    BumpRight = 0
    BumpLeft = 0
    SetFwdVelAngVelCreate(serPort, .1, 0)
    while true 
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort)

        if BumpFront == 1 || BumpRight == 1 || BumpLeft == 1
            SetFwdVelAngVelCreate(serPort, 0, 0)
            break
        end
    end

function traverseWall(serPort)
    SetFwdVelAngVelCreate(serPort, .1, 0)
    while true
        if WallSensorReadRoomba(serPort) == 0
            SetFwdVelAngVelCreate(serPort, 0, 0)
            break
        end 
    end

function orientToWall(serPort)
    wallSensor = WallSensorReadRoomba(serPort) 
    SetFwdVelAngVelCreate(serPort, 0, 0.5)
    while true
        if WallSensorReadRoomba(serPort) == 1
            SetFwdVelAngVelCreate(serPort, 0, 0)
            break
        end 
    end
    
function turnCorner(serPort)
    SetFwdVelAngVelCreate(serPort, .05, -.17);
    while true
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort)
        
        if BumpFront || BumpRight || BumpLeft
            SetFwdVelAngVelCreate(serPort, 0, 0)
            break
        end 
    end
        
