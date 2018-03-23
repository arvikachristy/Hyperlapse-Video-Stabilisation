path = 'road-camden';
inputImage = load_sequence_color(path,'op',1,100,5,'png');
inputImage = imresize(inputImage, 0.3);

[height,width,~,imageN] = size(inputImage);

cm_storage = [];

for x = 1:imageN-1
    holder_model = [];
    holder_perc = 0;
    hodler_diff = 0;
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

    for ran = 1:200
        
        
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
            holder_diff = diff;
        end
    end

    cost1 = mean(holder_diff);

    [x,y] = transformPointsForward(model, width/2, height/2); 

    distx = (x - width/2).^2;
    disty = (y - height/2).^2;

    diff = distx + disty;

    cost2 = diff;
    d = height^2 + width^2;
    tc = 0.1*d;
    g = 0.5*d;

    cm = 0;
    if(cost1<tc)
        cm = cost2; 
    else
        cm = g;  
    end
end
implay(inputImage);