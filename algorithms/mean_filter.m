function target = mean_filter(img, kernel_size)
    % this function applies mean filter using convolution
    % input:
    %   img: input image
    %   kernel_size: size of the mean filter kernel
    assert(mod(kernel_size, 2) == 1);
    
    % determine the basic parameters
    pd_size = (kernel_size - 1)/2;
    [H, W] = size(img);

    % add padding
    target = zeros(H, W);
    padding_img = zeros(H + 2*pd_size, W + 2*pd_size);
    padding_img = uint8(padding_img);
    padding_img(pd_size+1:end-pd_size, pd_size+1:end-pd_size) = img;

    % apply average mask
    for i = (1 + pd_size): (H + pd_size)
        for j = (1 + pd_size): (W + pd_size)
            surrounding_data = padding_img(i-pd_size:i+pd_size, j-pd_size:j+pd_size);
            target(i - pd_size, j - pd_size) = uint8(mean(surrounding_data, [1 2]));
        end
    end

    target = uint8(target);

end