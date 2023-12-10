% Description: Extract individual characters from segmented image
% while separating neighboring characters that were contiguous
% and normalising the output to 128x128 black foreground on
% white background as required by the classifier
function characters = separate_segment_v(original_row, segmented_row, visualize_split)
    % pixels to the left and right from mid of image to consider
    % for further splitting characters that are joint
    split_window_offset = 10;

    % Reshape the image to list of colors
    img_2d = reshape(segmented_row, [], size(segmented_row, 3));
    
    % Get the unique rows/colors
    segment_colors = unique(img_2d, 'rows');
    
    mask = zeros(size(segmented_row), 'uint8');

    characters = {};
    regions = [];
    
    % for each segment (color) extract the character
    for i = 1:size(segment_colors,1)
        % ignore the segment background
        if isequal(segment_colors(i,:), [255,255,255])
            continue
        end
        color = segment_colors(i,:);

        % Find the indices of the pixels that match the color
        mask(:,:,1) = color(1);
        mask(:,:,2) = color(2);
        mask(:,:,3) = color(3);

        matched = all(segmented_row == mask,3);
        [row_indices, col_indices] = find(matched);
        
        % Determine the bounding box of the sub-region
        min_row = min(row_indices);
        max_row = max(row_indices);
        min_col = min(col_indices);
        max_col = max(col_indices);

        % assume if width > 100 pixels that 2 characters are
        % errorneously contiguous
        if max_col - min_col > 100
            % split at the column within the window
            % with the least total pixel values

            % first calculate the window region
            mid = min_col + (max_col - min_col)/2;
            mid_left = mid - split_window_offset;
            mid_right = mid + split_window_offset;

            % extract the region
            window_region = segmented_row(min_row:max_row, mid_left:mid_right, :);

            % segmented background is white, i.e. 255 255 255
            % all other colors are < 255 in R G or B
            % therefore it is suffice to find the max column
            % i.e. the column with the most background color
            window_sum = sum(sum(window_region, 3), 1);
            [~, idx] = max(window_sum);

            % visualize where we split continuous neighbors
            if visualize_split
                window_region(:,idx,1) = 255;
                window_region(:,idx,2) = 0;
                window_region(:,idx,3) = 0;
                figure
                imshow(window_region)
            end

            % add left and right regions (i.e. the separated characters)
            split_idx = mid_left + idx;
            regions = [regions;[min_row max_row min_col split_idx]];
            regions = [regions;[min_row max_row split_idx max_col]];

        else
            % sub-regions (the character)
            regions = [regions;[min_row max_row min_col max_col]];
        end
    end

    % it was ordered by unique colors
    % we want it ordered by column i.e. left to right
    regions = sortrows(regions, 3);

    % extract the characters defined by the regions
    for i = 1:size(regions,1)
        region = regions(i,:);
        min_row = region(1);
        max_row = region(2);
        min_col = region(3);
        max_col = region(4);
        sub_region = original_row(min_row:max_row, min_col:max_col, :);
        % training set uses black characters with white background
        characters{i} = 255 - sub_region;
        
        % and normalized to 128x128
        s = size(characters{i}); % current size
        n = 128; % normalized target size
        rowsPad = floor((n - s(1))/2);
        collsPad = floor((n - s(2))/2);

        padded = padarray(characters{i}, [rowsPad, collsPad], 255, 'both');
        padded(n, :) = 255;
        padded(:, n) = 255;
        characters{i} = padded;
    end
