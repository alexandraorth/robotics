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
    right= BumpRight;
    if right
        SetFwdVelAngVelCreate(serPort, forward, -1); %turns right if bump right
    end
    left= BumpLeft
    if left
        SetFwdVelAngVelCreate(serPort, forward, 1); %turns left if bump left
    end
end
 
function [totalx, totaly] = caculcatedist(distance, angle, totalx, totaly)
    disp('THIS IS THE ANGLE');
    disp(angle);
    
    disp('vals')
    disp(totalx + distance*cos(angle));
    disp(totaly + distance*sin(angle));

    totalx = totalx + distance*cos(angle);
    totaly = totaly + distance*sin(angle);
    
    
    %     
%     
%     if angle < -.3 & angle > -1.5
%         disp('1');
%         totalx = totalx + distance;
%         totaly = totaly;
% %         RIGHT
%     elseif angle > 1.5 & angle < 3.5
%         disp('2')
%         totalx = totalx - distance;
%         totaly = totaly;
% %         LEFT
%     elseif angle > .3 & angle <= 1.5
%         disp('3')
%         totalx = totalx;
%         totaly = totaly + distance;
% %         UP
%     elseif angle <= -1.5 & angle > -3.5
%         disp('4')
%         totalx = totalx;
%         totaly = totaly - distance;
% %         DOWN
%     else
%         totalx = totalx;
%         totaly = totaly;
%     end
    
end

% function won=havewon(xval, yval)
%   if xval < abs(.2) && yval < abs(.2)
%     won = 1;
%   else
%       won = 0;
%   end
%   
% end
 
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
            
            totalAngle = totalAngle + AngleSensorRoomba(serPort);
            [totalx, totaly] = caculcatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);
           
        elseif BumpFront
            disp('in bump front');
            SetFwdVelAngVelCreate(serPort, 0, 0);
            turnAngle(serPort, .2, 50);
            
            totalAngle = totalAngle + AngleSensorRoomba(serPort);
            [totalx, totaly] = caculcatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);

        elseif BumpRight 
            disp('in bump right');
            SetFwdVelAngVelCreate(serPort, .1, 0);
            
            totalAngle = totalAngle + AngleSensorRoomba(serPort);
            [totalx, totaly] = caculcatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);

        else
            disp('in the else');
            SetFwdVelAngVelCreate(serPort, 0, 0);
            while angle < turnMax
                turnAngle(serPort, .2, -10);
                travelDist(serPort, .2, .005);
                [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            
            
                totalAngle = totalAngle + AngleSensorRoomba(serPort);
                [totalx, totaly] = caculcatedist(DistanceSensorRoomba(serPort), totalAngle, totalx, totaly);

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
            
        if abs(totalx) <= error & abs(totaly) <= error & en_route == true
            break
        end
    end
end

