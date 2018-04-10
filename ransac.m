function [holder_diff, holder_model] = ransac(matchedPoints1, matchedPoints2)

holder_model = [];
holder_perc = 0;
holder_diff = 0;

for ran = 1:200
    try
        %Do RANSAC steps here
        index_st = randperm(size(matchedPoints1,1),4);

        pnt1 = matchedPoints1(index_st, :).Location;
        pnt2 = matchedPoints2(index_st, :).Location;      

        model = fitgeotrans(pnt1, pnt2, 'projective');
        warning off;
    catch
        continue; 
    end 

    [x,y] = transformPointsForward(model, matchedPoints1.Location(:,1),...
        matchedPoints1.Location(:,2)); 

    distx = (x - matchedPoints2.Location(:,1)).^2;
    disty = (y - matchedPoints2.Location(:,2)).^2;

    diff = distx + disty;

    threshold = 1;
    percentage = mean(diff<threshold); %Percentage of inliers

    if(percentage >holder_perc)
        holder_perc = percentage;
        holder_model = model;
        holder_diff = diff;
    end
end

end