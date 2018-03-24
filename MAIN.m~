%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Courtesy of Vika Christy 2018 for Computational Photography Coursework UCL
%Hyperlapse - Project 2(Submission)
%Student Number: 14049380
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


path = 'road-camden';
inputImage = load_sequence_color(path,'op',1,100,5,'png');
inputImage = imresize(inputImage, 0.3);

[height,width,~,imageN] = size(inputImage);

cm_storage = zeros(imageN, imageN);

for p = 1:imageN-1
    
%%%%%%%%%%%%%%%%%%%%Part 1 - Frame Matching %%%%%%%%%%%%%%%%%%%%%%%%%%
    i = p;
    j = p+1;

    img1 = rgb2gray(inputImage(:,:,:,i));
    img2 = rgb2gray(inputImage(:,:,:,j));
    
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
    
    cm_storage(i,j) = cm; %modify the data structure
    
%%%%%%%%%%%%%%%%%%%%Part 2 - Frame Selection %%%%%%%%%%%%%%%%%%%%%%%%%%

%     cost_s(i,j) = min((i+1)-i);
end



function res = frame_selection(i, j, v, h, cm_storage)
    ts = 200; %Dont think this is right
    ta = 200;
    ls = 200;
    la = 80;
    
    c_s = min(abs((j-i)-v)^2, ts);
    
    c_a = min(abs((j-i)-(i-h))^2, ta);
    
    total_c = cm_storage(i,j) + ls*c_s + la*c_a;

end

% implay(inputImage);
