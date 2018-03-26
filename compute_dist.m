function res = compute_dist(inputImage)
%function to get distance matrix, taken from my previous cw, heliotrope
[~, ~, ~, imageN] = size(inputImage);

d_storage = zeros(imageN, imageN);
for x= 1:imageN-100
    disp(x);
    for y = x+1:x+100
        m1 = sum(sum((inputImage(:,:,1,x) - inputImage(:,:,1,y)).^2));
        m2 = sum(sum((inputImage(:,:,2,x) - inputImage(:,:,2,y)).^2));
        m3 = sum(sum((inputImage(:,:,3,x) - inputImage(:,:,3,y)).^2));
        
        d_storage(x,y) = sqrt(m1 + m2 + m3);
    end
end

d_storage = (d_storage - min(d_storage(:)))/max(d_storage(:))-min(d_storage(:));
res = d_storage;

end