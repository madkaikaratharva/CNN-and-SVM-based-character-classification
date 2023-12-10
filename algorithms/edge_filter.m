% Description: Extract edge from image using sobel operator with optional
% edge linking
function target = edge_filter(img, link)
    % define sobel operator kernel for edge detection
    h_kernel = int16([-1 -2 -1; 0 0 0; 1 2 1]);
    v_kernel = int16([-1 0 1; -2 0 2; -1 0 1]);
    kernel_size = 3;
    edge_linking_angle = 15; % degrees
    magnitude_threshold = 25;

    % determine the basic parameters
    pd_size = (kernel_size - 1)/2;
    [H, W] = size(img);

    gradient_cache = zeros(H, W);
    links = zeros(H, W);

    % add padding
    target = zeros(H, W);
    padding_img = zeros(H + 2*pd_size, W + 2*pd_size);
    padding_img = uint8(padding_img);
    padding_img(pd_size+1:end-pd_size, pd_size+1:end-pd_size) = img;

    % apply sobel filters
    for i = (1 + pd_size): (H + pd_size)
        for j = (1 + pd_size): (W + pd_size)
            region = int16(padding_img(i-pd_size:i+pd_size, j-pd_size:j+pd_size));
            h_result = sum(region.*h_kernel, 'all');
            v_result = sum(region.*v_kernel, 'all');
            target(i - pd_size, j - pd_size) = int16(abs(h_result) + abs(v_result));
            gradient_cache(i, j) = atand(v_result/h_result);
        end
    end

    % edge linking using local processing
    if link == true
        % iterate through each pixel
        for i = 1 : H
            for j = 1 : W
                % iterate through pixel's neighbours
                for offsetx = -1:1
                    for offsety = -1:1
                        x = j + offsetx;
                        y = i + offsety;
                        % skip over edge cases
                        if x<1 || x>W || y<1 || y>H
                            continue
                        end
   
                        % only link if similar magnitude (within
                        % magnitude_threshold)
                        % AND similar angle (within edge_linking_angle)
                        if abs(target(i, j) - target(y, x)) <= magnitude_threshold ...
                            && abs(gradient_cache(i, j) - gradient_cache(y, x)) < edge_linking_angle
                            links(i,j) = 255;
                        end
                    end
                end
            end
        end
        % combine extracted edge from sobel filters with 
        % linked edges
        target = target + links;
    end


    target = uint8(target);

end