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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DECLARE GLOBALS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    x = 0;
    y = 0;
    contactx = 0;
    contacty = 0;
    angle = 0;
    finished = false;
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MAIN WHILE LOOP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %disp('TESTING ORIENTTOWALL')
    %orientToWall(serPort)
    %disp('angle')
    %disp(angle)
    %disp('END')
    
    while(~finished)
       mtraverse(serPort);
       
       % set contact coordinates in case robot bumps into object
       contacty = y
       contactx = x
       
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
            elseif( y >= 10 )
                SetFwdVelAngVelCreate(serPort, 0, 0);
                finished = true;
                break;
            end
            pause(.01);
        end
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
            
            % have to update global angle
            angle_change = AngleSensorRoomba(serPort)
            angle = angle + angle_change
            
            %store last known postive angle value
            if (angle_change > 0)
                last_pos_angle = angle_change;
            end
            %only add to totalangle if the angle value is positive
            if (angle_change > 0)
                totalAngle = totalAngle + angle_change
            else
                totalAngle = totalAngle + last_pos_angle
            end
            pause(.01)
        end
    end

    % function travels around an object until it reaches the mline
    function circumnavigate(serPort)
        while(true)
            % Once this function is entered, it is assumed that x is 0
            found_wall = orientToWall(serPort)
            if (found_wall == 1)
                %traverse wall
                in_corner = traverseWall(serPort);
                if (in_corner == 1) % If stuck in corner, turn at least 10 degrees
                    getunstuck(serPort);
                else
                    turnCorner(serPort);
                end
                
            else
                %have not found wall, probably around a corner
                turnCorner(serPort);
            end
            pause(.01)
        end
        
        %while( x ~= 0 && contacty > y)
            %pause(.1);
           %%OLD CIRCUMNAVIGATE CODE THAT INCLUDES LOGIC TO TEST FOR
           %%DISTANCE. WE MAY HAVE TO INCLUDE OLD CIRCUMNAVIGATE FUNCTIONS.
        %end
    end
    
    function updateYAX(serPort) % Update y, angle, x
        
        % update angle
        angle = angle + AngleSensorRoomba(serPort);
        
        % update x and y
        distance = DistanceSensorRoomba(serPort);        
        x = x + distance*sin(angle);
        y = y + distance*cos(angle);
    end

    function orientm()
       
        %turn in a circle
       SetFwdVelAngVelCreate(serPort, 0, .1) 
       
        while(angle ~= 0) %need to have this take error into account
           updateYAX();
           SetFwdVelAngVelCreate(serPort, 0, 0); %stop turning
        end
    end

    % function returns 0 if no wall found, 1 if wall is found
    function result = orientToWall(serPort)
        AngleSensorRoomba(serPort);
        totalAngle = 0; % used to prevent robot from spinning forever
        last_pos_angle = 0;
        result = 0;
        SetFwdVelAngVelCreate(serPort, 0, 0.5);
        while totalAngle <= 6.28
            % Found wall, rotate left until wall is no longer found then
            % rotate back until wall is found again
            if WallSensorReadRoomba(serPort) == 1
                while WallSensorReadRoomba(serPort) == 1
                    angle_change = AngleSensorRoomba(serPort);
                    angle = angle + angle_change
                    pause(0.01)
                end
                SetFwdVelAngVelCreate(serPort, 0, -0.3);
                disp('1')
                WallSensorReadRoomba(serPort)
                while WallSensorReadRoomba(serPort) == 0
                    angle_change = AngleSensorRoomba(serPort);
                    angle = angle + angle_change
                    pause(0.01)
                end
                SetFwdVelAngVelCreate(serPort, 0, 0);
                result = 1;
                disp('2')
                WallSensorReadRoomba(serPort)
                
                %update angle as well
                angle_change = AngleSensorRoomba(serPort);
                angle = angle + angle_change
                break
            end
            
            % have to update global angle as well
            angle_change = AngleSensorRoomba(serPort)
            angle = angle + angle_change
            
            %store last known postive angle value
            if (angle_change > 0)
                last_pos_angle = angle_change;
            end
            %only add to totalangle if the angle value is positive
            if (angle_change > 0)
                totalAngle = totalAngle + angle_change
            else
                totalAngle = totalAngle + last_pos_angle
            end
            pause(.01)
        end
        %reset distance in case rotation counts as distance
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
            [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            updateYAX(serPort);
            
            % If in a corner
            if WallSensorReadRoomba(serPort) == 1 && (BumpFront || BumpLeft || BumpRight)
                SetFwdVelAngVelCreate(serPort, 0, 0);
                updateYAX(serPort);
                in_corner = 1
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

