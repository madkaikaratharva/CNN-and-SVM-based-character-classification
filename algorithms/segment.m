function img_rgb = segment(img)

    [H, W] = size(img);
    bool_img = boolean(img);
    img_rgb = 255 * ones(H, W, 3); % create an RGB image to be colored later
    img_rgb = uint8(img_rgb);

    % detect the edge
%     g1 = bool_img - circshift(bool_img, 1, 1);
%     g1 = max(g1, 0);
%     g2 = bool_img - circshift(bool_img, 1, 2);
%     g2 = max(g2, 0);
%     edge_map = g1 | g2;
% 
%     imshow(uint8(edge_map)*255);

    uf = WeightedQuickUnion(H*W);
    % find out the 
    target_idx = find(bool_img' == 1);
    
    % connect the ajacent pixels with value 
    for idx = target_idx'
        [x, y] = idx2px(idx);
        for k = [x-1 y; x y-1; x-1 y-1]'
            ii = k(1); jj = k(2);
            if  ii <= 0 || jj <= 0
                break;
            end
            if  img(ii, jj)>0
                uf.connect(idx, px2idx(ii, jj));
            end
        end
    end

    % get the number of seperate regions
    num_region = size(uf.data(uf.data < -1));
    
    % assign random color to each part
    par_idx = find(uf.data < -1); % idx is the position of the parent pixel
    clr_radn = uint8(randi([32 223], [num_region(2) 3]));
     
    
    for idx = target_idx'
        [x, y] = idx2px(idx);
        par = uf.find(idx);
        if not(ismember(par, par_idx))
            continue
        end
        
        clr_num = find(par_idx == par);
        
        clr = clr_radn(clr_num, :);
        img_rgb(x, y, :) = clr;
    end
    
    

    imshow(img_rgb)

end

function idx = px2idx(x, y)
    H = 267; W = 990;
    idx = W*x + y;
end

function [x, y] = idx2px(idx)
    H = 267; W = 990;
    px = ones(1, 2);

    y = mod(idx, W);
    if y == 0
        y = W;
    end
    x = (idx - y) / W;

    if x == 0
        x = 1;
    end
end