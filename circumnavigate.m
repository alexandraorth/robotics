function finished= circumnavigate(serPort)
    forward= .2;
    angle= 0;
    finished= 0;
    SetFwdVelAngVelCreate(serPort, forward, angle);
    while finished == 0
        frontBump= checkFrontBump(serPort);
        if frontBump %if front bump, this triggers into circumnavigation mode
           finished=nav(serPort);
        end
        pause(0.01);
    end
 
function frontBumped= checkFrontBump(serPort)
    forward= .2;
    [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
        BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    frontBumped= BumpFront;
    right= BumpRight;
    if right
        SetFwdVelAngVelCreate(serPort, forward, -1); %turns right if bump right
    end
    left= BumpLeft
    if left
        SetFwdVelAngVelCreate(serPort, forward, 1); %turns left if bump left
    end
 
function [totalx, totaly] = caculatedist(distance, angle, totalx, totaly)
    totalx = totalx + distance*cos(angle)
    totaly = totaly + distance*sin(angle)

function hvalue= heuristicsError(complexity)
 hvalue= (power(complexity,1.05)/2500)

function finished= nav(serPort)
    circled= 0;
    finished= 0;
    SetFwdVelAngVelCreate(serPort, 0, 0); %stop the robot
    wallSensor= WallSensorReadRoomba(serPort);
 
    fprintf('Turning left until wall detected\n');
    %if not detecting wall, turn left until wall detected
    if wallSensor == 0
        while wallSensor == 0
            turnAngle(serPort, .2, 5); %turn 5 degree increments
            pause(.5);
            wallSensor = WallSensorReadRoomba(serPort);
        end    
    end
    pause(1);
 
 
    fprintf('Robot is detecting wall- will begin circumnavigating\n');
%     circumnavigation loop
    err = 0
    ERR_RATE = 0.1
    en_route = false
    turnMax = 180;
    totalx = 0;
    totaly = 0; 
    totalAngle = 0
    totalDistTravelled = 0
    complexity = 100;
    DistanceSensorRoomba(serPort);
    AngleSensorRoomba(serPort);
    while true
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
        BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        angle = 0;
    
        disp('----')
        if BumpLeft
            disp('in bump left');
            SetFwdVelAngVelCreate(serPort, 0, 0);
            turnAngle(serPort, .2, 90)

        elseif BumpFront
            disp('in bump front');
            SetFwdVelAngVelCreate(serPort, 0, 0);
            turnAngle(serPort, .2, 50)

        elseif BumpRight 
            disp('in bump right');
            SetFwdVelAngVelCreate(serPort, .1, 0);

        else
            disp('in the else');
            SetFwdVelAngVelCreate(serPort, 0, 0);
            while angle < turnMax
                turnAngle(serPort, .2, -10);
                travelDist(serPort, .2, .005);
                [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort)

                if BumpRight || BumpLeft || BumpFront
                   break; 
                end
                angle = angle + 10; 
            end
        end
        pause(.5);
        totalAngle = totalAngle + AngleSensorRoomba(serPort)
        distTravelled = DistanceSensorRoomba(serPort)
        [totalx, totaly] = caculatedist(distTravelled, totalAngle, totalx, totaly)
        totalDistTravelled = totalDistTravelled + abs(distTravelled)
        err = ERR_RATE * totalDistTravelled
        if totalDistTravelled > err
            en_route = true;
        end
        disp(totalx)
        disp(totaly)

        if abs(totalx) <= err & abs(totaly) <= err & en_route == true
            finished = 1;
            break
        end
    end
