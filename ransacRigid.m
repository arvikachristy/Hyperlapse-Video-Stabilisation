function holder_model = ransacRigid(matchedPoints1, matchedPoints2)

holder_model = [];
holder_perc = 0;

for ran = 1:200
    %Do RANSAC steps here
    index_st = randperm(size(matchedPoints1,1),4);

    pointsA = matchedPoints1(index_st, :);
    pointsB = matchedPoints2(index_st, :);      

    pointsA = pointsA.Location;
    pointsB = pointsB.Location;

    pointsN = size(pointsA, 1); dimension = size(pointsA, 2);
    ctrA = sum(pointsA, 1)./pointsN;
    ctrB = sum(pointsB, 1)./pointsN;

    centered1 = pointsA - repmat(ctrA, pointsN, 1);
    centered2 = pointsB - repmat(ctrB, pointsN, 1);
    [U,~, V] = svd(centered1'* eye(pointsN, pointsN) *centered2);

    M = eye(dimension, dimension);
    M(dimension, dimension) = det(V*U');

    model = eye(3,3);
    model(1:2, 1:2) = V*M*U';
    model(1:2, 3) = ctrB' - (V*M*U')*ctrA';

    [x,y] = transformPointsForward(affine2d(model'), matchedPoints1.Location(:,1),...
        matchedPoints1.Location(:,2)); 

    distx = (x - matchedPoints2.Location(:,1)).^2;
    disty = (y - matchedPoints2.Location(:,2)).^2;

    diff = distx + disty;

    threshold = 50;

    %Percentage of inliers
    percentage = mean(diff<threshold); 

    if(percentage >holder_perc)
        holder_perc = percentage;
        holder_model = model;
    end
end

end