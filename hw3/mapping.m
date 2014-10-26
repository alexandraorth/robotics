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
    map('0_0') = 0;
    
    diameter = 0.5; %really, unknown. set like this for testing
    x_dist = .5*diameter;
    y_dist = .5*diameter;
    x_temp_dist = 0;
    y_temp_dist = 0;
    next_move = [0,0];
    prev_move = [0,0];
    real_prev_move = [0,0];
    direction = 'east';
    ang = 0;
    
    % c(['2','-1']) note: the '2' is the x and the '-1' is the y

    %initalize orientation hash tables
    % 6.28 = 360 deg, 3.14 = 180, 1.57 = 90, 4.71 = -90
    north = containers.Map;
    north(['0_','-1']) = ['314_', 'south'];
    north(['-1_','0']) = ['1.57_', 'west'];
    north(['1_','0']) = ['4.71_', 'east'];
    north(['0_','1']) = ['0_','north'];
    
    south = containers.Map;
    south(['0_','-1']) = ['0_', 'south'];
    south(['0_', '1']) = ['3.14_', 'north'];
    south(['1_','0']) = ['1.57_', 'east'];
    south(['-1_','0']) = ['4.71_', 'west'];

    west = containers.Map;
    west(['0_','-1']) = ['1.57_', 'south'];
    west(['0_', '1']) = ['4.71_', 'north'];
    west(['1_','0']) = ['3.14_', 'east'];
    west(['-1_','0']) = ['0_', 'west'];
    
    east = containers.Map;
    east(['0_','-1']) = ['4.71_', 'south'];
    east(['0_', '1']) = ['1.57_', 'north'];
    east(['1_','0']) = ['0_', 'east'];
    east(['-1_','0']) = ['3.14_', 'west'];
    
    
    %main while loop
    while(true) %need to change to ~ending_direction
      next_move = decide_move();
      
      turn(next_move);
      disp('MOVING')
      SetFwdVelAngVelCreate(serPort, .2, 0); %MOVE

      while(true)
         updateDistance();

         [BumpRight BumpLeft WheDropRight WheDropLeft WheDropCaster ...
            BumpFront] = BumpsWheelDropsSensorsRoomba(serPort);

        if(BumpRight || BumpLeft || BumpFront)
            disp('BUMPED')
            SetFwdVelAngVelCreate(serPort, 0, 0); %STOP
            respond_to_bump();
            backtrack();
            break;
        end

        if(in_middle_of_cell())
            disp('IN MIDDLE OF CELL')
            x_temp_dist = 0;
            y_temp_dist = 0;
            prev_move = str2double(strsplit(next_move, '_'));
            SetFwdVelAngVelCreate(serPort, 0, 0); %STOP
            respond_to_empty();
            break;
        end
        pause(.1);
      end
    end

    function respond_to_bump()
       disp('respond to bump')
        
       map(next_move) = 1;
       disp(keys(map));
       disp(values(map));
    end
    
    function respond_to_empty()
       disp('respond to empty')

       map(next_move) = 0;
       
       disp(keys(map));
       disp(values(map));
    end
    
    function in_middle = in_middle_of_cell()
       in_middle = false;
       error = 0.1;
  
       if(abs(x_temp_dist) >= diameter || abs(y_temp_dist) >= diameter)
          in_middle=true; 
       end
    end

    function in_middle = backtrack_to_middle()
       in_middle = false;
       error = 0.05;
       
       if(abs(x_temp_dist) <= (0 + error) && abs(y_temp_dist) <= (0 + error))
          in_middle = true; 
       end
    end

    function backtrack()
       disp('in backtrack');

       do_turn(3.14);
      
       pause(1);
       
       if(strcmp(direction, 'north') == 1)
           direction = 'south';
       elseif(strcmp(direction, 'south') == 1)
           direction = 'north';
       elseif(strcmp(direction, 'east') == 1)
           direction = 'west';
       elseif(strcmp(direction, 'west') == 1)
           direction = 'east';
       end
       
       SetFwdVelAngVelCreate(serPort, .1, 0);
       while(true)
          disp('backtrack loop')
          updateDistance();
          if(backtrack_to_middle())
              SetFwdVelAngVelCreate(serPort, 0, 0); %STOP
              break;
          end
          pause(.1);
       end

      x_temp_dist = 0;
      y_temp_dist = 0;
    end

    function chosen_cell = decide_move()
       disp('decide move')

       chosen_cell =  false;
       emptyspots = []; % 0 = north, 1 = east, 2 = south, 3 = west
       
       x_cell = prev_move(1);
       y_cell = prev_move(2);
       pref = 0; %set to 1 if direction of unknown is same as current direction
       real_prev_move_str = [strcat(num2str(real_prev_move(1)), '_'), num2str(real_prev_move(2))];

       try %get north cell
           cell = [strcat(num2str(x_cell), '_'), num2str(y_cell + 1)];
           is_occupied_n = map(cell);
       catch
           map(cell) = 'X';
           is_occupied_n = map(cell);
           chosen_cell = cell;
       end
       
       if(is_occupied_n == 0)
           disp(cell);
           empty_cell = cell;
           if (strcmp(empty_cell,real_prev_move_str) ~= true)
               emptyspots(end+1) = 0;
           end
       elseif(strcmp(is_occupied_n, 'X'))
           chosen_cell = cell;
           if (strcmp(direction,'north'))
               pref = 1;
               pref_cell = cell;
           end 
       end
       
       try %get south cell
           cell = [strcat(num2str(x_cell), '_'), num2str(y_cell - 1)];
           is_occupied_s = map(cell);
       catch
           map(cell) = 'X';
           is_occupied_s = map(cell);
           chosen_cell = cell;
       end
        
       if(is_occupied_s == 0)
           disp(cell);
           empty_cell = cell;
           if (strcmp(empty_cell,real_prev_move_str) ~= true)
               emptyspots(end+1) = 2;
           end
       elseif(strcmp(is_occupied_s, 'X'))
           chosen_cell = cell;
           if (strcmp(direction,'south'))
               pref = 1;
               pref_cell = cell;
           end 
       end
       
       try %get east cell
           disp(cell);
           cell = [strcat(num2str(x_cell + 1), '_'), num2str(y_cell)];
           is_occupied_e = map(cell);
       catch
           map(cell) = 'X';
           is_occupied_e = map(cell);
           chosen_cell = cell;
       end
       
       if(is_occupied_e == 0)
           empty_cell = cell;
           if (strcmp(empty_cell,real_prev_move_str) ~= true)
               emptyspots(end+1) = 1;
           end
       elseif(strcmp(is_occupied_e, 'X'))
           chosen_cell = cell;
           if (strcmp(direction,'east'))
               pref = 1;
               pref_cell = cell;
           end 
       end
       
       try %get west cell
           disp(cell);
           cell = [strcat(num2str(x_cell - 1), '_'), num2str(y_cell)];
           is_occupied_w = map(cell);
       catch
           map(cell) = 'X';
           is_occupied_w = map(cell);
           chosen_cell = cell;
       end
       
       if(is_occupied_w == 0)
           empty_cell = cell;
           if (strcmp(empty_cell,real_prev_move_str) ~= true)
               emptyspots(end+1) = 3;
           end
%           emptyspots(end+1) = strcat(cell(1), cell(2));
       elseif(strcmp(is_occupied_w, 'X'))
           chosen_cell = cell;
           if (strcmp(direction,'west'))
               pref = 1;
               pref_cell = cell;
           end 
       end
       
       disp(keys(map));
       disp(values(map));

       if(chosen_cell ~= false)
           disp('next cell')
           disp(chosen_cell)
           if (pref == 1)
              chosen_cell = pref_cell;
           end
%            prev_move = [x_cell, y_cell]; 
          return;
       end

       disp(emptyspots)
       chosen_spot = emptyspots(datasample(emptyspots,1));
       if (chosen_spot == 0) %north
           chosen_cell = [strcat(num2str(x_cell), '_'), num2str(y_cell + 1)];
       elseif (chosen_spot == 1) %east
           chosen_cell = [strcat(num2str(x_cell + 1), '_'), num2str(y_cell)];
       elseif (chosen_spot == 2) %south
           chosen_cell = [strcat(num2str(x_cell), '_'), num2str(y_cell - 1)];
       else %west
           chosen_cell = [strcat(num2str(x_cell - 1), '_'), num2str(y_cell)];
       end
       
       % prev_move only set after already in middle of cell robot moves to
       % before this assignment, real_prev_move is the previous move
       real_prev_move = prev_move;    
       return;        
    end


    function turn(next_move)
       direction_to_move = str2double(strsplit(next_move, '_')) - prev_move;
       direction_to_move = [strcat(num2str(direction_to_move(1)), '_'), num2str(direction_to_move(2))];

       disp('direction to move')
       disp(direction_to_move);
              
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
           disp(east(direction_to_move));
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
       do_turn(angle);
    end
    
    function do_turn(rad)
       totalAngle = 0;
       last_pos_angle = 0;
       SetFwdVelAngVelCreate(serPort, 0, 0.1);
       % 6.28 = 360 deg, 3.14 = 180, 1.57 = 90, 4.71 = -90
       while totalAngle <= rad 
            % Have to update global angle as well
            angle_change = AngleSensorRoomba(serPort);
            % Store last known postive angle value
            if (angle_change > 0)
                last_pos_angle = angle_change;
            end
            % Only add to totalangle if the angle value is positive
            if (angle_change >= 0)
                totalAngle = totalAngle + angle_change;
            else
                totalAngle = totalAngle + last_pos_angle;
            end
            pause(.01)
        end
    end    
    function updateDistance()
        difference = DistanceSensorRoomba(serPort);         
        
        if( strcmp(direction, 'north'))
           change_in_move = [0,1];
        elseif( strcmp(direction, 'south'))
           change_in_move = [0,-1];
        elseif(strcmp(direction, 'east'))
           change_in_move = [1,0];
        elseif(strcmp(direction, 'west'))
           change_in_move = [-1,0];
        end
        
        x_dist = x_dist + (change_in_move(1) * difference);
        y_dist = y_dist + (change_in_move(2) * difference);
        x_temp_dist = x_temp_dist + (change_in_move(1) * difference);
        y_temp_dist = y_temp_dist + (change_in_move(2) * difference);
        

    end
end
