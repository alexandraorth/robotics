function finished= circumnavigate(serPort)
    forceContact(serPort)
    while true 
        res = orientToWall(serPort)
        if res == 0
            turnCorner(serPort)
        else
            traverseWall(serPort)
            turnCorner(serPort)
        end 
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
        pause(.1)
    end

function traverseWall(serPort)
    inCorner = false
    SetFwdVelAngVelCreate(serPort, .1, 0)
    while true
        disp('traverseWall')
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort)
        disp(BumpLeft)
        disp(BumpFront)
        disp(BumpRight)
        if WallSensorReadRoomba(serPort) == 1 && (BumpFront || BumpRight || BumpLeft) 
            inCorner = true
        end
        if WallSensorReadRoomba(serPort) == 0 || inCorner
            SetFwdVelAngVelCreate(serPort, 0, 0)
            disp('=================== should be breaking ===============')
            break
        end
        pause(.1)
    end

function result = orientToWall(serPort) 
    AngleSensorRoomba(serPort)
    totalAngle = 0
    result = 0
    SetFwdVelAngVelCreate(serPort, 0, 0.5)
    while totalAngle <= 6.28
        disp('orientToWall')
        if WallSensorReadRoomba(serPort) == 1
            SetFwdVelAngVelCreate(serPort, 0, 0)
            result = 1
            break
        end
        totalAngle = totalAngle + AngleSensorRoomba(serPort)
        pause(.1)
    end
        
function turnCorner(serPort) 
    SetFwdVelAngVelCreate(serPort, .05, -.2);
    while true
        disp('turnCorner')
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort)
        
        if BumpFront || BumpRight || BumpLeft
            SetFwdVelAngVelCreate(serPort, 0, 0)
            break
        end
        pause(.1)
    end
