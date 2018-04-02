function res = compute_dist(inputImage)
%function to get distance matrix, taken from my previous heliotrope cw
[~, ~, ~, imageN] = size(inputImage);

d_storage = zeros(imageN, imageN);
for x= 1:imageN
    disp(x);
    if(x<=10)
        for y = x:20+x
            m1 = sum(sum((inputImage(:,:,1,x) - inputImage(:,:,1,y)).^2));
            m2 = sum(sum((inputImage(:,:,2,x) - inputImage(:,:,2,y)).^2));
            m3 = sum(sum((inputImage(:,:,3,x) - inputImage(:,:,3,y)).^2));

            d_storage(x,y) = sqrt(m1 + m2 + m3);
        end 
    elseif(x> imageN-10)
        for y = (imageN-20):imageN
            m1 = sum(sum((inputImage(:,:,1,x) - inputImage(:,:,1,y)).^2));
            m2 = sum(sum((inputImage(:,:,2,x) - inputImage(:,:,2,y)).^2));
            m3 = sum(sum((inputImage(:,:,3,x) - inputImage(:,:,3,y)).^2));

            d_storage(x,y) = sqrt(m1 + m2 + m3);
        end
    else   
        for y = x-10:x+10
            m1 = sum(sum((inputImage(:,:,1,x) - inputImage(:,:,1,y)).^2));
            m2 = sum(sum((inputImage(:,:,2,x) - inputImage(:,:,2,y)).^2));
            m3 = sum(sum((inputImage(:,:,3,x) - inputImage(:,:,3,y)).^2));

            d_storage(x,y) = sqrt(m1 + m2 + m3);
        end        
    end
end

d_storage = (d_storage - min(d_storage(:)))/max(d_storage(:))-min(d_storage(:));
res = d_storage;

end