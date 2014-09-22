function finished= circumnavigate(serPort)
    forceContact(serPort)
    departed = false
    arrived = false
    cumulativeAngle = 0
    totalx = 0
    totaly = 0
    AngleSensorRoomba(serPort)
    DistanceSensorRoomba(serPort)
    while true 
        [cumulativeAngle, totalx, totaly] = updateTravelHistory(serPort, cumulativeAngle, totalx, totaly)
        arrived = getArrivalStatus(totalx, totaly)
        if departed and arrived
            SetFwdVelAngVelCreate(serPort, 0, 0)
            break
        end

        res = orientToWall(serPort)
        if res == 0
            turnCorner(serPort)
        else
            traverseWall(serPort)
            turnCorner(serPort)
        end
        departed = true 
    end
          
function arrived = getArrivalStatus(totalx, totaly)
    arrived = false
    if totalx == 0 and totaly == 0
        arrived = true
    end

function [cumulativeAngle, totalx, totaly] = updateTravelHistory(serPort, cumulativeAngle, totalx, totaly)
    cumulativeAngle = cumulativeAngle + AngleSensorRoomba(serPort)
    distance = DistanceSensorRoomba(serPort)
    totalx = totalx + distance*cos(cumulativeAngle)
    totaly = totaly + distance*sin(cumulativeAngle)
    disp('totalx')
    disp(totalx)
    disp('totaly')
    disp(totaly)

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

function result = orientToWall(serPort)
    AngleSensorRoomba(serPort)
    totalAngle = 0
    result = 0
    SetFwdVelAngVelCreate(serPort, 0, 0.5)
    while totalAngle <= 6.28
        if WallSensorReadRoomba(serPort) == 1
            SetFwdVelAngVelCreate(serPort, 0, 0)
            result = 1
            break
        end
        totalAngle = totalAngle + AngleSensorRoomba(serPort)
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
