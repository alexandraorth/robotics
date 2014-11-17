function [ ] = follow_path( serPort )
  
    i = 1;
    coordinates = {};
    
    fid = fopen('path.txt');
    line = fgetl(fid);
%     disp(line)
%     coordinates[i] = [];
%     coordinates[i][1] = int(line[1]);
%     coordinates[i][2] = int(line[2]);
    while ischar(line)
        line = regexp(line, '\s+','split');
       
        coordinates{i, 1} = str2num(line{1});
        coordinates{i, 2} = str2num(line{2});
        
        line = fgetl(fid);
        i = i + 1;
    end
    fclose(fid);
    
    for i = 1:length(coordinates) - 1       
       x1 = coordinates{i, 1};
       y1 = coordinates{i, 2};
       
       x2 = coordinates{i + 1, 1};
       y2 = coordinates{i + 1, 2};
%        
%         disp(x1)
%         disp(y1)
%         disp(x2)
%         disp(y2)
       
       dist = get_distance(x1, y1, x2, y2);
       [angle, direction] = calculate_angle(x1, y1, x2, y2);
       
       turnAngle(serPort, 0.1, angle*direction); %add something to this
       travelDist(serPort, 0.1, dist);
       turnAngle(serPort, 0.1, angle*direction*-1);
       pause(0.1);
       disp('one loop');
    end
    
    disp(coordinates)
end

function s = get_distance(x1, y1, x2, y2)
    diff = (x1-x2)^2 + (y1-y2)^2;
    s = sqrt(diff)
%     disp(s)
end

function [a, dir] = calculate_angle(x1, y1, x2, y2)
    diff = abs(y2-y1) / abs(x2 - x1);
    a = 90 - atand(diff);
    
    if x2 > x1
        dir = -1;
    else
        dir = 1;
    end
    
    if y2 < y1
       a = 90 + a; 
    end
    
    disp(a)
    disp(dir)
end