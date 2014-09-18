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
    i = 1;
    turnMax = 180;
    while i == 1%need condition- this will eventually be the starting pt
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
        BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
        angle = 0;
    
        disp('----')
        disp(BumpRight)
        disp(BumpLeft)
        disp(BumpFront)
        if BumpLeft
            disp('in bump left');
           turnAngle(serPort, .2, 90);
        elseif BumpFront
            disp('in bump front');
           turnAngle(serPort, .2, 50);
        elseif BumpRight 
            disp('in bump right');
%            travelDist(serPort, .2, .1);
           SetFwdVelAngVelCreate(serPort, .1, 0);
        else
            disp('in the else');
            while angle < turnMax
                turnAngle(serPort, .2, -10);
                travelDist(serPort, .2, .005);
                [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
                if BumpRight || BumpLeft || BumpFront
                   break; 
                end
                angle = angle + 10; 
%                 disp(angle);
            end
%            travelDist(serPort, .2, .05);
        end
        pause(.5);
    end
end
