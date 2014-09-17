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
    while i == 1%need condition- this will eventually be the starting pt
        [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
        BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
    
        if BumpLeft
            turnAngle(serPort, .2, 90);
        end
        if BumpRight || BumpFront
          turnAngle(serPort, .2, 50);
        end
        SetFwdVelAngVelCreate(serPort, .4, -.4);
        pause(.5);
        
%         if wallSensor ==  0
%            if BumpFront
%                turnAngle(serPort, .2, 45);
%            end
%            SetFwdVelAngVelCreate(serPort, .4, -.4);   
%         else
%             turnAngle(serPort, .2, 20); %turn to the left by 5 degrees
%         end
%         wallSensor =  WallSensorReadRoomba(serPort);

    end
end
