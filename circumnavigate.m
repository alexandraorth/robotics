function finished= circumnavigate(serPort)    
    error = .04;
    cumulativeAngle = 0;
    totalx = 0;
    totaly = 0;
    totaldist = 0;
    
    num_zeros = 1;
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
    
    function updateTravelHistory(serPort)
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
        
        disp('xpow')
        disp(power(totalx, 2))
        disp('ypow')
        disp(power(totaly, 2))
        disp('totalpow')
        disp(power(totaldist * error, 2))
        disp(power(totalx, 2) + power(totaly, 2) >= power(totaldist * error, 2))
        
        if (power(totalx, 2) + power(totaly, 2) <= power(totaldist * error, 2)) && (num_zeros >=3)
            arrived = true; 
        elseif power(totalx, 2) + power(totaly, 2) <= power(totaldist * error, 2)
            num_zeros = num_zeros + 1;
        end
    end

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
