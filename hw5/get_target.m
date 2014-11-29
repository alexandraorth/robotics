function [  ] = get_target(  )

    image = imread('/Users/alexandraorth/Desktop/image');
%     imshow(image)
    
    selected_pixel = impixel(image)
    hsv_selected_pixel = rgb2hsv(selected_pixel)
    h_thresh = hsv_selected_pixel(1)
    s_thresh = hsv_selected_pixel(2)
    
    mask = mask_image(image, h_thresh, s_thresh);
    
    opened_image = open_image(mask);
    
    get_largest_cc(opened_image);
    
%     hsv_image = rgb2hsv(image);
%     imshow(hsv_image);

end

function mask = mask_image(image, h_thresh, s_thresh)
    hsv_image = rgb2hsv(image);
    mask = hsv_image(:,:,1) > h_thresh*.9 & hsv_image(:,:,1) < h_thresh*1.1 & hsv_image(:,:,2) > s_thresh*.8;
%     figure
%     imshow(mask)
end

function dilated = open_image(mask)
    sel = strel('square',5);
    eroded = imerode(mask, sel);
    dilated = imdilate(eroded, sel);
%     figure
%     imshow(eroded)
%     figure
    imshow(dilated)
end

function get_largest_cc(opened_image)
    original = opened_image;
    comp = 1;
    for i=1:size(opened_image,1)
       for j=1:size(opened_image, 2)
           neighbours = get_neigbours(original, i, j);
           for n=1:neighbours
               if(neighbours(n) > 0)
                  opened_image(i,j) = neighbours(n);
                  break;
               end
           end
           opened_image(i,j) = comp;
           comp = comp+1;
           disp('updating_comp')
       end
    end
    
%     disp(opened_image);
    figure
    imshow(opened_image);
end

function neighbours = get_neigbours(image, row, column)
    neighbours = [];
    if(~ (row-1 < 1))
        neighbours = [neighbours, image(row-1,column)];
    end
    
    if(~ (row+1 > size(image, 1)))
        neighbours = [neighbours, image(row+1,column)];
    end
    
    if(~ (column-1 < 1))
        neighbours = [neighbours, image(row,column-1)];
    end
    
    if(~ (column+1 > size(image, 2)))
        neighbours = [neighbours, image(row,column+1)];
    end
end