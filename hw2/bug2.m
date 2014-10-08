% COMS W4733 Computational Aspects of Robotics 2014
%
% Homework 2
%
% Team number: 17
% Team leader: Alexandra Orth (alo2117)
% Team members: Tony Ling (tl2573) and Emily Chen (ec2805)
%
% To run: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bug2(serPort) 
    xarray = [];
    yarray = [];
    anglearray = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DECLARE GLOBALS FOR SIMULATOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     ERROR = 0.01;
%     ROTATION_COMPENSATION = 0;
%     x = 0;
%     y = 0;
%     contactx = 0;
%     contacty = 0;
%     % Local x and y used to track if robot has left the starting area
%     localx = 0;
%     localy = 0;
%     left_starting = false;
%     angle = 0;
%     finished = false;
%     back_on_mline = false; % Used to control when robot breaks out of circumnavigation
%     i = 0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DECLARE GLOBALS FOR ACTUAL ROBOT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     ERROR = 0.02;
     ROTATION_COMPENSATION = 20;
     x = 0;
     y = 0;
     contactx = 0;
     contacty = 0;
     % Local x and y used to track if robot has left the starting area
     localx = 0;
     localy = 0;
     left_starting = false;
     angle = 0;
     finished = false;
     back_on_mline = false; % Used to control when robot breaks out of circumnavigation
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MAIN WHILE LOOP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %disp('TESTING ORIENTTOWALL')
    %orientToWall(serPort)
    %disp('angle')
    %disp(angle)
    %disp('END')
    
    while(~finished)
        disp('not finished')
       mtraverse(serPort);
       
       % set contact coordinates in case robot bumps into object
       contacty = y;
       contactx = x;
       
       if( ~finished )
           circumnavigate(serPort);
       end
       pause(.01);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HELPER FUNCTIONS BELOW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % function traverses the mline
    % returns when robot bumps into an object or reaches the goal
    function mtraverse(serPort)
        SetFwdVelAngVelCreate(serPort, .1, 0);
        while(true)
            %test to see if bumped
            [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            updateYAX(serPort);
            %disp(x)
            %disp(y)
            if(BumpRight || BumpLeft || BumpFront)
                SetFwdVelAngVelCreate(serPort, 0, 0);
                %Return which bump here (may have done this in fn declaration)
                break;
            elseif( y >= 8 )
                figure(1);
                plot(xarray * -1, yarray);
                figure(2);
                plot((1:length(anglearray)), anglearray);
                SetFwdVelAngVelCreate(serPort, 0, 0);
                finished = true;
                figure;
                break;
            end
            pause(.01);
        end
        x = 0;
    end

    % Function rotates robot counterclockwise and returns
    % Updates global angle as well
    function getunstuck(serPort)
        AngleSensorRoomba(serPort);
        totalAngle = 0; % used to prevent robot from spinning forever
        last_pos_angle = 0;
        SetFwdVelAngVelCreate(serPort, 0, 0.5);
        
        % Rotate robot counterclockwise about 10 degrees
        while totalAngle <= 0.175
            
            % Have to update global angle
            angle_change = AngleSensorRoomba(serPort);
            angle = angle + angle_change;
            
            % Store last known postive angle value
            if (angle_change > 0)
                last_pos_angle = angle_change;
            end
            % Only add to totalangle if the angle value is positive
            if (angle_change > 0)
                totalAngle = totalAngle + angle_change;
            else
                totalAngle = totalAngle + last_pos_angle;
            end
            pause(.01)
        end
    end
    % checks if the robot is back on the mline
    % if the robot is back on the mline, then orient the robot to the mline
    function checkmline(serPort)
        % Break and reorient to m line if back on mline after leaving
        % starting area
        disp('checkmline')
        if (abs(localx) > ERROR && abs(localy) > ERROR)
            left_starting = true;
        end
        % mline approximation skewed towards passing the original starting
        % position to account for some drift
        if (left_starting == true && abs(x) <= ERROR && y > contacty)
            back_on_mline = true;
            orientm(serPort);
        end
    end

    % function travels around an object until it reaches the mline
    function circumnavigate(serPort)
        % Once this function is called, it is assumed that x = 0
        % Local x and y reset when a new obstacle is encountered
        localx = 0;
        localy = 0;
        left_starting = false;
        back_on_mline = false;
        while(~back_on_mline)
            found_wall = orientToWall(serPort);
            if (found_wall == 1)
                % Traverse wall
                in_corner = traverseWall(serPort);
                if (in_corner == 1) % If stuck in corner, turn at least 10 degrees
                    getunstuck(serPort);
                else
                    turnCorner(serPort);
                end
                
            else
                % Have not found wall, probably around a corner
                turnCorner(serPort);
            end
            pause(.01)
        end
    end
    
    function updateYAX(serPort) % Update y, angle, x
        % update angle
        angle = angle + AngleSensorRoomba(serPort);
        
        % update x and y
        distance = DistanceSensorRoomba(serPort);        
        x = x + distance*sin(angle);
        y = y + distance*cos(angle);
        
        disp('==========');
        disp('x');
        disp(x);
        disp('y');
        disp(y);
        disp('angle');
        disp(angle);
        
        xarray(end+1) = x;
        yarray(end+1) = y;
        anglearray(end+1) = angle;
        
        % update localx and localy
        localx = localx + distance*sin(angle);
        localy = localy + distance*cos(angle);
    end

    % Rotates robot counterclockwise until the angle is near the starting
    % angle
    function orientm(serPort)
       disp('orient to m')
       actualAngle = mod(angle, 2*pi);
       actualAngleDeg = actualAngle * 360 / (2*pi);
       turnAngle(serPort, 0.1, 360 - ROTATION_COMPENSATION - actualAngleDeg);
       angle = 0;
       updateYAX(serPort);
    end

    % function returns 0 if no wall found, 1 if wall is found
    function result = orientToWall(serPort)
        disp('orient to wall')
        AngleSensorRoomba(serPort);
        totalAngle = 0; % used to prevent robot from spinning forever
        last_pos_angle = 0;
        result = 0;
        SetFwdVelAngVelCreate(serPort, 0, 0.5);
        while totalAngle <= 6.28
            disp('ORIENTTOWALL')
            checkmline(serPort);
            if (back_on_mline)
                break;
            end
            % Found wall, rotate left until wall is no longer found then
            % rotate back until wall is found again
            if WallSensorReadRoomba(serPort) == 1
                while WallSensorReadRoomba(serPort) == 1
                    angle_change = AngleSensorRoomba(serPort);
                    angle = angle + angle_change;
                    pause(0.01)
                end
                SetFwdVelAngVelCreate(serPort, 0, -0.3);
                disp('1')
                WallSensorReadRoomba(serPort)
                while WallSensorReadRoomba(serPort) == 0
                    disp('in LEFT TURN loop')
                    angle_change = AngleSensorRoomba(serPort);
                    angle = angle + angle_change;
                    pause(0.01)
                end
                SetFwdVelAngVelCreate(serPort, 0, 0);
                result = 1;
                disp('2')
                WallSensorReadRoomba(serPort)
                
                %update angle as well
                angle_change = AngleSensorRoomba(serPort);
                angle = angle + angle_change;
                break
            end
            
            % Have to update global angle as well
            angle_change = AngleSensorRoomba(serPort);
            angle = angle + angle_change;
            
            % Store last known postive angle value
            if (angle_change > 0)
                last_pos_angle = angle_change;
            end
            % Only add to totalangle if the angle value is positive
            if (angle_change > 0)
                totalAngle = totalAngle + angle_change;
            else
                totalAngle = totalAngle + last_pos_angle;
            end
            pause(.01)
        end
        % Reset distance in case rotation counts as distance
        DistanceSensorRoomba(serPort); 
    end

    % Tranverses the wall until the wall sensor is no longer activated
    % Updates the travel history frequently
    % Function returns when wall is no longer detected or stuck in corner
    function in_corner = traverseWall(serPort)
        in_corner = 0;
        SetFwdVelAngVelCreate(serPort, .1, 0);
        disp('3 travel')
        WallSensorReadRoomba(serPort)
        while true
            checkmline(serPort);
            if (back_on_mline)
                break;
            end
            [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            updateYAX(serPort);
            
            % If in a corner
            if WallSensorReadRoomba(serPort) == 1 && (BumpFront || BumpLeft || BumpRight)
                SetFwdVelAngVelCreate(serPort, 0, 0);
                updateYAX(serPort);
                in_corner = 1;
                break
            end
            % If wall no longer detected, probably next to corner
            if WallSensorReadRoomba(serPort) == 0
                SetFwdVelAngVelCreate(serPort, 0, 0);
                updateYAX(serPort);
                break
            end
            pause(.01)
        end
        disp('5 corner')
        WallSensorReadRoomba(serPort)
    end

    % function used to turn the corner
    function turnCorner(serPort)
        SetFwdVelAngVelCreate(serPort, .05, -.2);
        while true
            disp('TURNCORNER')
            checkmline(serPort);
            if (back_on_mline)
                break;
            end
            [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            updateYAX(serPort);
            if BumpFront || BumpRight || BumpLeft
                SetFwdVelAngVelCreate(serPort, 0, 0)
                updateYAX(serPort);
                break
            end
            pause(.1)
        end
    end

end

