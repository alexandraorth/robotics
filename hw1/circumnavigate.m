% COMS W4733 Computational Aspects of Robotics 2014
%
% Homework 1
%
% Team number: 17
% Team leader: Alexandra Orth (alo2117)
% Team members: Tony Ling (tl2573) and Emily Chen (ec2805)
% Parameters: This program does not work on the simulator, 
%             but it does work correctly on the robot.

% To run: circumnavigate(r) , where r is the robot object

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function hw1_team_17(serPort)    
%     declare variables
    error = .04; % the error by which we are determining when to stop 
    cumulativeAngle = 0;
    totalx = 0;
    totaly = 0;
    totaldist = 0;
    
    num_zeros = 1; % the number of 'zero' conditions encountered. 
                   % encountering two means you should stop the robot
    arrived = false;
  
    forceContact(serPort);
    
    DistanceSensorRoomba(serPort)
    AngleSensorRoomba(serPort)
    
    while power(totalx, 2) + power(totaly, 2) >= power(totaldist * error, 2) && arrived == false
       updateTravelHistory(serPort);
         
        res = orientToWall(serPort);
        if res == 0
             turnCorner(serPort);

        else
            traverseWall(serPort);
  
            turnCorner(serPort);

        end
    end
    
    
%     Modifies the x, y, and distance varibles based on the amount traveled
%     since the last time this function was called. Checks to see if the robot 
%     has arrived at its starting location
    function updateTravelHistory(serPort)
%         update global variables
        cumulativeAngle = cumulativeAngle + AngleSensorRoomba(serPort);
        distance = DistanceSensorRoomba(serPort);
        totaldist = totaldist + distance;
        totalx = totalx + distance*cos(cumulativeAngle);
        totaly = totaly + distance*sin(cumulativeAngle);

        disp('angle')
        disp(cumulativeAngle)
        disp('totaldist')
        disp(totaldist)
        disp('totalx')
        disp(totalx)
        disp('totaly')
        disp(totaly)
        
%         check ending conditions
        if (power(totalx, 2) + power(totaly, 2) <= power(totaldist * error, 2)) && (num_zeros >=2)
            arrived = true; 
        elseif power(totalx, 2) + power(totaly, 2) <= power(totaldist * error, 2)
            num_zeros = num_zeros + 1;
        end
    end

%     Drives the robot straight until a wall is hit and then resets the odometers
    function forceContact(serPort)
        SetFwdVelAngVelCreate(serPort, .1, 0)
        while true 
            [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

            if BumpFront == 1 || BumpRight == 1 || BumpLeft == 1
                
                % Reset odometers
                DistanceSensorRoomba(serPort);
                AngleSensorRoomba(serPort);

                SetFwdVelAngVelCreate(serPort, 0, 0);
                break
            end
            pause(.1)
        end
    end


%     Spins the robot until it has spun an entire circle or the robot has 
%     found the wall. 
    function result = orientToWall(serPort)
        AngleSensorRoomba(serPort);
        totalAngle = 0;
        result = 0;
        SetFwdVelAngVelCreate(serPort, 0, 0.5)
        while totalAngle <= 6.28
            if WallSensorReadRoomba(serPort) == 1
                SetFwdVelAngVelCreate(serPort, 0, 0);
                result = 1;

                % Reset odometers
                DistanceSensorRoomba(serPort);
                AngleSensorRoomba(serPort);

                break
            end
            totalAngle = totalAngle + AngleSensorRoomba(serPort);
            pause(.1)
        end
    end

%     Tranverses the wall until the wall sensor is no longer activated
%     Updates the travel history frequently
    function traverseWall(serPort)
        SetFwdVelAngVelCreate(serPort, .1, 0);
        while true
            if WallSensorReadRoomba(serPort) == 0
                
                updateTravelHistory(serPort);
                
                SetFwdVelAngVelCreate(serPort, 0, 0);
                break
            end 
            pause(.1)
        end
    end

%     Turns the corner in a clockwise circle, until a wall is found
%     Updates the travel history frequently
    function turnCorner(serPort)
        SetFwdVelAngVelCreate(serPort, .05, -.2);
        while true
            [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

            updateTravelHistory(serPort);

            if BumpFront || BumpRight || BumpLeft || WallSensorReadRoomba(serPort) == 1
                SetFwdVelAngVelCreate(serPort, 0, 0);
                pause(.25)
                break
            end 
            pause(.1)
        end
    end

end    