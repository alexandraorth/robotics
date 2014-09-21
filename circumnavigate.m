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
end
 
function [totalx, totaly] = caculatedist(distance, angle, totalx, totaly)
    disp('THIS IS THE ANGLE');
    disp(angle);
    
%    disp('vals')
%    disp(totalx + distance*cos(angle));
%    disp(totaly + distance*sin(angle));

%    totalx = totalx + distance*cos(angle);
%    totaly = totaly + distance*sin(angle);
    
    
    %     
     
     if angle < -.15 & angle > -1.5
         disp('1 right');
         totalx = totalx + distance;
         totaly = totaly;
 %         RIGHT
     elseif angle >= 5 & angle < 6.1
         disp('6 right');
         totalx = totalx + distance;
         totaly = totaly;
 %         RIGHT
     elseif angle >= 1.5 & angle < 3
         disp('2 left')
         totalx = totalx - distance;
         totaly = totaly;
 %         LEFT
     elseif angle >= -4.8 & angle < -3.5
         disp('2 left')
         totalx = totalx - distance;
         totaly = totaly;
 %         LEFT
     elseif angle > .15 & angle <= 1.5
         disp('3 up')
         totalx = totalx;
         totaly = totaly + distance;
 %         UP
     elseif angle <= -1.5 & angle > -3.5
         disp('4 down')
         totalx = totalx;
         totaly = totaly - distance;
 %         DOWN
     elseif angle >= 3 & angle < 5
         disp('5 down')
         totalx = totalx;
         totaly = totaly - distance;
 %         DOWN
     else
         totalx = totalx;
         totaly = totaly;
     end
     
    disp('vals')
    disp(totalx);
    disp(totaly);
    
end

function hvalue= heuristicsError(complexity)
 hvalue= (power(complexity,1.05)/2500)
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
    error = .2
    en_route = false
    turnMax = 180;
    totalx = 0;
    totaly = 0;
    totalAngle = 0;
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
            turnAngle(serPort, .2, 90);
            if en_route
                complexity = complexity + 9;
            end
            totalAngle = totalAngle + AngleSensorRoomba(serPort);
            [totalx, totaly] = caculatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);
           
        elseif BumpFront
            disp('in bump front');
            SetFwdVelAngVelCreate(serPort, 0, 0);
            turnAngle(serPort, .2, 50);
            if en_route
                complexity = complexity + 5;
            end
            totalAngle = totalAngle + AngleSensorRoomba(serPort);
            [totalx, totaly] = caculatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);

        elseif BumpRight 
            disp('in bump right');
            SetFwdVelAngVelCreate(serPort, .1, 0);
            complexity = complexity + 1;
            totalAngle = totalAngle + AngleSensorRoomba(serPort);
            [totalx, totaly] = caculatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);

        else
            disp('in the else');
            SetFwdVelAngVelCreate(serPort, 0, 0);
            while angle < turnMax
                turnAngle(serPort, .2, -10);
                travelDist(serPort, .2, .005);
                [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            
                complexity = complexity + 1;
                totalAngle = totalAngle + AngleSensorRoomba(serPort);
                [totalx, totaly] = caculatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);

                if BumpRight || BumpLeft || BumpFront
                   break; 
                end
                angle = angle + 10; 
            end
%            travelDist(serPort, .2, .05);
        end
        pause(.5);
        
        if totalx > error || totaly > error
            en_route = true;
        end
        disp('complexity')
        disp(complexity)
        %disp(heuristicsError(complexity))
        disp('!----!')
        if abs(totalx) <= heuristicsError(complexity) & abs(totaly) <= heuristicsError(complexity) & en_route == true
            finished = 1;
            break
        end
    end
end

