function H = stabile_transform(leftI,rightI,ptThresh)

if nargin < 3 || isempty(ptThresh)
    ptThresh = 0.1;
end

pointsA = detectFASTFeatures(leftI, 'MinContrast', ptThresh);
pointsB = detectFASTFeatures(rightI, 'MinContrast', ptThresh);

[featuresA, pointsA] = extractFeatures(leftI, pointsA);
[featuresB, pointsB] = extractFeatures(rightI, pointsB);

indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

tform = ransacRigid(pointsB, pointsA);
H = tform;

end