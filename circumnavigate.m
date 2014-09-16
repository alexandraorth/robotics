function pos= circumnavigate(serPort)
    forward= .2;
    angle= 0;
    pos= 0;
    SetFwdVelAngVelCreate(serPort, forward, angle);
    while pos < 1
        frontBump= checkFrontBump(serPort);
        if frontBump %if front bump, this triggers into circumnavigation mode
            nav(serPort);
        end
        pause(0.01);
    end
end

function frontBumped= checkFrontBump(serPort)
    forward= .2;
    [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
        BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    frontBumped= BumpFront;
    right= BumpRight
    if right
        SetFwdVelAngVelCreate(serPort, forward, -1); %turns right if bump right
    end
    left= BumpLeft
    if left
        SetFwdVelAngVelCreate(serPort, forward, 1); %turns left if bump left
    end
end

function finished= nav(serPort)
    circled= 0;
    finished= 0;
    SetFwdVelAngVelCreate(serPort, 0, 0); %stop the robot
    wallSensor= WallSensorReadRoomba(serPort);
    display(wallSensor);
    %if not detecting wall, turn left until wall detected
    if wallSensor == 0
        while wallSensor == 0
            turnAngle(serPort, .2, 5); %turn 5 degree increments
            pause(.5);
            wallSensor = WallSensorReadRoomba(serPort);
            display(wallSensor);
        end    
    end
    pause(1);
    ping= 1;
    display(wallSensor);
    display(ping);
    %robot should be detecting wall by this point
    while wallSensor > 0
        display(wallSensor);
        turnAngle(serPort, .2, 5); %turn 5 degree increments
        wallSensor = WallSensorReadRoomba(serPort);
    end
    display(ping);
    display(wallSensor);
    %robot not detecting wall anymore
    while wallSensor == 0
        turnAngle(serPort, .2, -5);
        wallSensor =  WallSensorReadRoomba(serPort);
    end
    display(ping);
    display(wallSensor);    
    while circled < 1 
        pause(0.1);
    end
end
