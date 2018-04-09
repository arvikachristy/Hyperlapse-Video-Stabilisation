function transformation = rigidTransform(pointsA, pointsB)

    pointsA = pointsA.Location;
    pointsB = pointsB.Location;

    pointsN = size(pointsA, 1);
    dimension = size(pointsA, 2);
    
    ctrA = sum(pointsA, 1)./pointsN;
    ctrB = sum(pointsB, 1)./pointsN;
    
    centered1 = pointsA - repmat(ctrA, pointsN, 1);
    centered2 = pointsB - repmat(ctrB, pointsN, 1);
    
    [U, ~, V] = svd(centered1'* eye(pointsN, pointsN) *centered2);
    
    M = eye(dimension, dimension);
    M(dimension, dimension) = det(V*U');
    
    rtt = V*M*U';
    
    transformation = eye(3,3);
    transformation(1:2, 1:2) = rtt;
    transformation(1:2, 3) = ctrB' - rtt*ctrA';

end