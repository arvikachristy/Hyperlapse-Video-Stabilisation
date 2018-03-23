path = 'road-camden';
inputImage = load_sequence_color(path,'op',1,100,5,'png');
inputImage = imresize(inputImage, 0.3);

[height,width,~,imageN] = size(inputImage);

% %get distance matrix
% if ~exist('d_matrix.mat')
%     d_matrix = compute_dist(inputImage);
%     save('d_matrix.mat', 'd_matrix');
% else
%     load('d_matrix.mat', 'd_matrix');
% end

holder_model = [];
holder_perc = 0;

for x = 1:imageN-1
    %Find matching points
    img1 = rgb2gray(inputImage(:,:,:,x));
    img2 = rgb2gray(inputImage(:,:,:,x+1));
    
    points1 = detectHarrisFeatures(img1);
    points2 = detectHarrisFeatures(img2);
    
    [features1,valid_points1] = extractFeatures(img1,points1);
    [features2,valid_points2] = extractFeatures(img2,points2);   
    
    indexPairs = matchFeatures(features1,features2);
    
    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:);
    
%     figure; showMatchedFeatures(img1,img2,matchedPoints1,matchedPoints2);

    index_st = randperm(size(matchedPoints1,1),4);
    
    pnt1 = matchedPoints1(index_st, :).Location;
    pnt2 = matchedPoints2(index_st, :).Location;
    
    model = fitgeotrans(pnt1, pnt2, 'projective');
    
    [x,y] = transformPointsForward(model, matchedPoints1.Location(:,1),...
        matchedPoints1.Location(:,2)); 
    
    distx = (x - matchedPoints2.Location(:,1)).^2;
    disty = (y - matchedPoints2.Location(:,2)).^2;
    
    diff = distx + disty;
    
    threshold = 1;
    percentage = mean(diff<1); %PErcentage of inliers
    
    if(percentage >holder_perc)
        holder_perc = percentage;
        holder_model = model;
    end
    
end

implay(inputImage);
