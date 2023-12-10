function target = mean_filter_fast(img, kernel_size, to_img)
    % this function applies mean filter using integral map
    % input:
    %   img: input image
    %   kernel_size: size of the mean filter kernel
    %   to_img: decide whether to change the dtype to uint8
    assert(mod(kernel_size, 2) == 1);
    
    % determine the basic parameters
    pd_size = (kernel_size - 1)/2;

    img = double(img);
    [H, W] = size(img);

    % add padding
    target = zeros(H + 2*pd_size, W + 2*pd_size);
    % target = uint(target);
    target(pd_size+1:end-pd_size, pd_size+1:end-pd_size, :) = uint32(img);
    
    % create the integral image
    img_sum = zeros(H + 2*pd_size+1, W + 2*pd_size+1);
    img_sum(2:end, 2:end) = cumsum(cumsum(uint32(target), 1), 2);

    % average mask
    for i = (2 + pd_size): H + pd_size + 1
        for j = 2 + pd_size: W + pd_size + 1
            target_sum = img_sum(i-pd_size-1, j-pd_size-1) + img_sum(i+pd_size, j+pd_size) ...
                - img_sum(i-pd_size-1, j+pd_size) - img_sum(i+pd_size, j-pd_size-1);
            target(i-1, j-1) = target_sum / kernel_size^2;
        end
    end

    target = target(pd_size+1:end-pd_size, pd_size+1:end-pd_size, :);

    if to_img
        target = uint8(target);
    end
end