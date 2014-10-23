% COMS W4733 Computational Aspects of Robotics 2014
%
% Homework 3
%
% Team number: 17
% Team leader: Alexandra Orth (alo2117)
% Team members: Tony Ling (tl2573) and Emily Chen (ec2805)
%
% To run: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function mapping(serPort)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Declare variables
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Initialize map
    map = containers.Map;
    
    diameter = 1; %really, unknown. set like this for testing
    x_dist = .5*diameter;
    y_dist = .5*diameter;
    x_temp_dist = 0;
    y_temp_dist = 0;
    prev_move = [0,0];
    direction = 'north';
    ang = 0;
    
    % c(['2','-1']) note: the '2' is the x and the '-1' is the y

    %initalize orientation hash tables
    north = containers.Map;
    north(['0_','-1']) = ['180_', 'south'];
    north(['-1_','0']) = ['90_', 'west'];
    north(['1_','0']) = ['-90_', 'east'];
    north(['0_','1']) = ['0_','north'];
    
    south = containers.Map;
    south(['0_','-1']) = ['180_', 'north'];
    south(['0_', '1']) = ['0_', 'south'];
    south(['1_','0']) = ['-90_', 'west'];
    south(['-1_','0']) = ['90_', 'east'];
    
    west = containers.Map;
    west(['0_','-1']) = ['180_', 'east'];
    west(['0_', '1']) = ['0_', 'west'];
    west(['1_','0']) = ['-90_', 'north'];
    west(['-1_','0']) = ['90_', 'south'];
    
    east = containers.Map;
    east(['0_','-1']) = ['180_', 'west'];
    east(['0_', '1']) = ['0_', 'east'];
    east(['1_','0']) = ['-90_', 'south'];
    east(['-1_','0']) = ['90_', 'north'];
    
    
    %main while loop
    while(true) %need to change to ~ending_direction
      next_cell = decide_move();
      turn(next_cell);
      disp('MOVING')
      SetFwdVelAngVelCreate(serPort, .2, 0); %MOVE

      while(true)
         updateDistance();

         [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

        if(BumpRight || BumpLeft || BumpFront)
            disp('BUMPED')
            x_temp_dist = 0;
            y_temp_dist = 0;
            SetFwdVelAngVelCreate(serPort, 0, 0); %STOP
            respond_to_bump();
            backtrack();
            break;
        end

        if(in_middle_of_cell())
            disp('IN MIDDLE OF CELL')
            x_temp_dist = 0;
            y_temp_dist = 0;
            SetFwdVelAngVelCreate(serPort, 0, 0); %STOP
            respond_to_empty();
            break;
        end
        pause(.1);
      end
    end

    function respond_to_bump()
       x_cell = floor(x_dist/diameter);
       y_cell = floor(y_dist/diameter);
        
       map([x_cell + '-', y_cell]) = 1;
    end
    
    function respond_to_empty()
       x_cell = floor(x_dist/diameter);
       y_cell = floor(y_dist/diameter);
        
       map([strcat(x_cell + '-'), y_cell]) = 0;
    end
    
    function in_middle = in_middle_of_cell()
       in_middle = false;
       error = 0.1;
  
       if(x_temp_dist >= diameter || y_temp_dist >= diameter)
          in_middle=true; 
       end
   end

    function backtrack()
       turnAngle(serPort, 0.025, 180);
       SetFwdVelAngVelCreate(serPort, .1, 0);
       while(true)
          updateDistance();
          if(in_middle_of_cell())
              SetFwdVelAngVelCreate(serPort, 0, 0); %STOP
              break;
          end
       end
    end

    function chosen_cell = decide_move()
       chosen_cell =  false;
        
       emptyspots = [];
       x_cell = floor(x_dist/diameter);
       y_cell = floor(y_dist/diameter);
       
       try %get north cell
           cell = [strcat(num2str(x_cell), '_'), num2str(y_cell + 1)];
           disp('this is the cell')
           disp(cell);
           is_occupied_n = map(cell);
           
           if(is_occupied_n == 0)
              emptyspots(end+1) = cell;
           elseif(strcmp(is_occupied_n, 'X'))
               chosen_cell = cell;
           end
       catch
           map(cell) = 'X';
           chosen_cell = cell;
       end
       
       try %get south cell
           cell = [strcat(num2str(x_cell), '_'), num2str(y_cell - 1)];
           is_occupied_s = map(cell);
           
           if(is_occupied_s == 0)
              emptyspots(end+1) = cell;
           elseif(strcmp(is_occupied_s, 'X'))
               chosen_cell = cell;
           end
       catch
           map(cell) = 'X';
           chosen_cell = cell;
       end
       
       try %get east cell
           cell = [strcat(num2str(x_cell + 1), '_'), num2str(y_cell)];
           is_occupied_e = map(cell);
           
           if(is_occupied_e == 0)
              emptyspots(end+1) = cell;
           elseif(strcmp(is_occupied_e, 'X'))
               chosen_cell = cell;
           end
       catch
           map(cell) = 'X';
           chosen_cell = cell;
       end
       
       try %get west cell
           cell = [strcat(num2str(x_cell - 1), '_'), num2str(y_cell)];
           is_occupied_w = map(cell);
           
           if(is_occupied_w == 0)
              emptyspots(end+1) = cell;
           elseif(strcmp(is_occupied_w, 'X'))
               chosen_cell = cell;
           end
       catch
           map(cell) = 'X';
           chosen_cell = cell;
       end
       
       disp('x coordinate')
       disp(x_dist)
       
       disp('y coordinate')
       disp(y_dist)
   
       
       disp('chosen cell')
       disp(chosen_cell)
       
       if(chosen_cell ~= false)
           prev_move = [x_cell, y_cell]; 
          return;
       end
       
       chosen_cell = emptyspots(rand(length(emptyspots)));
       prev_move = [x_cell, y_cell];
       return;        
    end

    function turn(next_cell)
        disp(next_cell);
        disp('next cell above')
        disp(str2double(strsplit(next_cell, '_')))
        disp(prev_move)
       direction_to_move = str2double(strsplit(next_cell, '_')) - prev_move;
       direction_to_move = [strcat(num2str(direction_to_move(1)), '_'), num2str(direction_to_move(2))];
       
       if( strcmp(direction, 'north'))
           disp('north');
           disp(strsplit(north(direction_to_move), '_'));
           holder = strsplit(north(direction_to_move), '_');
           direction = holder(2);
           angle = str2double(holder(1));
       elseif( strcmp(direction, 'south'))
           disp('south');
           holder = strsplit(south(direction_to_move), '_');
           direction = holder(2);
           angle = str2double(holder(1));
       elseif(strcmp(direction, 'east'))
           disp('east');
           holder = strsplit(east(direction_to_move), '_');
           direction = holder(2);
           angle = str2double(holder(1));
       elseif(strcmp(direction, 'west'))
           disp('west');
           holder = strsplit(west(direction_to_move), '_');
           direction = holder(2);
           angle = str2double(holder(1));
       end
       
       disp('this is the angle')
       disp(angle);
       disp('this is the direction')
       disp(direction);
       turnAngle(serPort, 1, angle);
    end
    
    function updateDistance()
        distance = DistanceSensorRoomba(serPort);        
        x_dist = x_dist + distance*sin(ang);
        y_dist = y_dist + distance*cos(ang);
        
        x_temp_dist = x_temp_dist + distance*sin(ang);
        y_temp_dist = y_temp_dist + distance*cos(ang);
    end
end