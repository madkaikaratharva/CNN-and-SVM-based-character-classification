function target = binary_img(img, th)
    % input:
    %   img: input image
    %   th : threshold value
    [H, W] = size(img);
    target = uint8(zeros(H, W));
    target(img > th) = 255;
    target(img <= th) = 0;
end