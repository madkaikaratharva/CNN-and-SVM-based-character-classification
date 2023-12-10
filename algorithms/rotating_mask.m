function target = rotating_mask(img, kernel_size)
    assert(mod(kernel_size, 2) == 1);
    
    % determine the basic parameters
    pd_size = (kernel_size - 1)/2;
    [H, W] = size(img);
    img = double(img);

    % add padding
    target = zeros(H + 2*pd_size, W + 2*pd_size);
    target = uint8(target);
    target(pd_size+1:end-pd_size, pd_size+1:end-pd_size, :) = img;
    
    % create the integral image
    mean_map = mean_filter_fast(img, kernel_size, false); % (H, W)
    var_map = zeros(H + 2*pd_size, W + 2*pd_size);  

    % calculate variance for each mask
    vars = mean_filter_fast(img.^2, kernel_size, false) - double(mean_map).^2;
    var_map(pd_size+1:pd_size+H, pd_size+1:pd_size+W) = vars;

    % for each pixel, find the mask with minimum variance
    for i = (1 + pd_size): H + pd_size
        for j = 1 + pd_size: W + pd_size
            var_values = var_map(i-pd_size:i+pd_size, j-pd_size:j+pd_size);
            min_var = min(var_values, [], 'all');
            [bias_h, bias_w] = find(min_var==var_values); % find the place where the variance is minimum
            bias_h = bias_h - pd_size - 1;
            bias_w = bias_w - pd_size - 1;
            
            i_biased = i+bias_h(1)-pd_size;
            j_biased = j+bias_w(1)-pd_size;

            if i_biased <= 0 || j_biased <= 0 || i_biased > H || j_biased > W
                target(i, j) = mean_map(i-pd_size, j-pd_size);
            else
                target(i, j) = mean_map(i+bias_h(1)-pd_size, j+bias_w(1)-pd_size);
            end
        end
    end

    target = target(pd_size+1:end-pd_size, pd_size+1:end-pd_size, :);
end