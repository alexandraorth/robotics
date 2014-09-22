function finished= circumnavigate(serPort)
    forward= .2;
    angle= 0;
    finished= 0;
    forceContact()
    orientToWall()
    goStraight()

function forceContact()
    BumpFront = 0
    BumpRight = 0
    BumpLeft = 0
    while ~(BumpFront || BumpRight || BumpLeft)
        SetFwdVelAngVelCreate(serPort, .1, 0)
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster BumpFront] = BumpsWheelDropsSensorsRoomba(serPort)
    end

function goStraight()
    wallSensor = WallSensorReadRoomba(serPort)
    while wallSensor == 1
        SetFwdVelAngVelCreate(serPort, .1, 0)
    end
    SetFwdVelAngVelCreate(serPort, 0, 0)

function orientToWall()
    wallSensor = WallSensorReadRoomba(serPort) 
    while true
        if WallSensorReadRoomba(serPort) == 1
            break
        end
        turnAngle(serPort, .2, 5); %turn 5 degree increments
        pause(.5)
    end

