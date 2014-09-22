function finished= circumnavigate(serPort)
    forward= .2;
    angle= 0;
    finished= 0;
    forceContact()
    orientToWall()
    traverseWall()

function forceContact(serPort)
    BumpFront = 0
    BumpRight = 0
    BumpLeft = 0
    while true 
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort)

        if BumpFront == 1 || BumpRight == 1 || BumpLeft == 1
            break
        end
        SetFwdVelAngVelCreate(serPort, .1, 0)
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
    SetFwdVelAngVelCreate(serPort, 0, 0.1)
    while true
        if WallSensorReadRoomba(serPort) == 1
            SetFwdVelAngVelCreate(serPort, 0, 0)
            break
        end 
        %turnAngle(serPort, .2, 5); %turn 5 degree increments
        pause(.5)
    end

