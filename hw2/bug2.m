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
    
    while(y <= 0)
       mtraverse()
       
       contacty = y;
       contactx = x;
       
       if( ~finished )
           circumnavigate();
       end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % HELPER FUNCTIONS BELOW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function [BumpRight, BumpLeft, BumpFront] = mtraverse()
        SetFwdVelAngVelCreate(serPort, .1, 0)
        while(true)
            %test to see if bumped
            [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
                BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);
            
            if(BumpRight || BumpLeft || BumpFront)
                %Return which bump here (may have done this in fn declaration)
               break;
            elseif( y > 10 )
               finished = true;
               break;
            end
        
        end
        
    end

    function circumnavigate()
        while( x ~= 0 && contacty > y)
           %%OLD CIRCUMNAVIGATE CODE THAT INCLUDES LOGIC TO TEST FOR
           %%DISTANCE. WE MAY HAVE TO INCLUDE OLD CIRCUMNAVIGATE FUNCTIONS.
        end
    end
    
    function updateYAX() % Update y, angle, x
        
        % update angle
        angle = angle + AngleSensorRoomba(serPort);
        
        % update x and y
        distance = DistanceSensorRoomba(serPort);        
        x = x + distance*cos(angle);
        y = y + distance*sin(angle);
    end

    function orientm()
       
        %turn in a circle
       SetFwdVelAngVelCreate(serPort, 0, .1) 
       
        while(angle ~= 0) %need to have this take error into account
           updateYAX();
           SetFwdVelAngVelCreate(serPort, 0, 0); %stop turning
        end
    end
end

