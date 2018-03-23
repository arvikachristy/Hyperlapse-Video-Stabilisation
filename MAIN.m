path = 'road-camden';
inputImage = load_sequence_color(path,'op',1,100,5,'png');
inputImage = imresize(inputImage, 0.3);

[height,width,~,imageN] = size(inputImage);

cm_storage = [];

for i = 1:imageN-1
%     fprintf('%i\n',x);

    %Find matching points
    img1 = rgb2gray(inputImage(:,:,:,i));
    img2 = rgb2gray(inputImage(:,:,:,i+1));
    
    points1 = detectHarrisFeatures(img1);
    points2 = detectHarrisFeatures(img2);
    
    [features1,valid_points1] = extractFeatures(img1,points1);
    [features2,valid_points2] = extractFeatures(img2,points2);   
    
    indexPairs = matchFeatures(features1,features2);
   
    matchedPoints1 = valid_points1(indexPairs(:,1),:);
    matchedPoints2 = valid_points2(indexPairs(:,2),:);
    
%     figure; showMatchedFeatures(img1,img2,matchedPoints1,matchedPoints2);
    [holder_diff, holder_model] = ransac(matchedPoints1, matchedPoints2);
    
    cost1 = mean(holder_diff);

    [x,y] = transformPointsForward(holder_model, width/2, height/2); 

    distx = (x - width/2).^2;
    disty = (y - height/2).^2;

    diff = distx + disty;

    cost2 = diff;
    d = height^2 + width^2;
    tc = 0.1*d;
    g = 0.5*d;

    if(cost1<tc)
        cm = cost2; 
    else
        cm = g;  
    end
    cm_storage = [cm_storage, cm];
end
implay(inputImage);
