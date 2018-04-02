%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Courtesy of Vika Christy 2018 for Computational Photography Coursework UCL
%Hyperlapse - Project 2(Submission)
%Student Number: 14049380
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

runme()

function runme()
tic
path = 'road-camden-rename';

chosenFrames = frameFiltering(path, 1, 2000);

resInputImg = playFrame(chosenFrames, path); 
%produces benchmark video by selecting every 8 frames

start_f = 1; until_f = 2000;
stitch_jump = 300;
w = 12;
cur_add = 0;
totalN = until_f-start_f;
cm_storage = zeros(totalN, totalN);

if ~exist('cm_storage.mat')
    for x = start_f:stitch_jump:until_f
        disp(x);
        end_f = x+(stitch_jump-1);
        
        inputImage = load_sequence_color(path,'op',x,end_f,5,'png', 0.5);

        [height,width,~,imageN] = size(inputImage);

        for i = 1:imageN-1
            disp('Ransac no:');
            disp(i);
            if(imageN-i > w-2)
                last = i+(w-1);
            else    
                patchImage = load_sequence_color(path,'op',end_f,end_f+(w-1),5,'png', 0.5);           
                inputImage = cat(4,inputImage, patchImage);
                last = i+(w-1);
            end

            for j = i+1:last
            %%%%%%%%%%%%%%%%%%%%Part 1 - Frame Matching %%%%%%%%%%%%%%%%%%%%%%%%%%

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

                cm_storage(cur_add+i, cur_add+j) = cm; %modify the data structure
            end
        end
        cur_add = cur_add + (stitch_jump-1); %keep track of stitching
        if ~exist('cm_storage.mat') 
            save('cm_storage.mat', 'cm_storage');
        else
            save('cm_storage.mat', 'cm_storage', '-append');
        end
    end
else
    load('cm_storage.mat', 'cm_storage');
end
% 
% inputImage = load_sequence_color(path,'op',start_f,100+start_f,0,'png', 0.5);
% 
% for e = 100+start_f+1:100:1790
%     disp(e);
%     patchImage = load_sequence_color(path,'op',e,99+e,0,'png', 0.5);
%     inputImage = cat(4,inputImage, patchImage);
% end
% 
% [height,width,~,imageN] = size(inputImage);
% 
% origin = zeros(height, width, 3, 3);
% for r = 1:size(path,2)
%     if(8*r<imageN)
%         origin(:,:,:,r) = inputImage(:,:,:,8*r);
%     else
%         origin(:,:,:,r) = inputImage(:,:,:,imageN);
%     end
% end


%%%%%%%%%%%%%%%%%%%%Part 2 - Frame Selection %%%%%%%%%%%%%%%%%%%%%%%%%%
g = 4;v = 8;
ts = 200;
ls = 200;
la = 80;

Dv = zeros(imageN, imageN);
for i = 1:g
    for j = i+1:i+w
        % Initialisation
        c_s = min(abs((j-i)-v)^2, ts);
        Dv(i,j) = cm_storage(i,j) + ls*c_s;
    end
end

%First pass
Tv = zeros(imageN, imageN);
for i = g:imageN
    if(imageN-i >= w)
        last = i+w;
    else
        last = imageN;
    end        

    for j = i+1:last
        c_s = min(abs((j-i)-v)^2, ts);
        c = cm_storage(i,j) + ls*c_s;   
        dv_prev = ones(w,1).*inf;

        for k = 1:w 
            if(i-k>0)
                dv_prev(k) = Dv(i-k,i) + la*c_a(i-k, i, j);
            end
        end

        [val, idx] = min(dv_prev);

        Dv(i,j) = c + val;
        Tv(i,j) = i-idx;
    end
end

%second pass
s=0;d=0;
min_trace = inf;

for i = imageN-g:imageN
    for j = i+1:i+w
        if(j <=imageN)
            if(min_trace > Dv(i,j))
                s=i;d=j;
                min_trace = Dv(i,j);
            end
        end
    end
end

path_chosen = [d];
while(s>g)
    path_chosen = [s,path_chosen];
    b = Tv(s,d);
    d=s; s=b;
end


function res = c_a(h, i, j)
    ta = 200;
    res = min(((j-i)-(i-h))^2, ta);

%     total_c = cm_storage(i,j) + ls*c_s + la*c_a;

end
toc

finale = zeros(height, width, 3, 3);
origin = zeros(height, width, 3, 3);
for r = 1:size(path_chosen,2)
    finale(:,:,:,r) = inputImage(:,:,:,path_chosen(r));
    if(8*r<imageN)
        origin(:,:,:,r) = inputImage(:,:,:,8*r);
    else
        origin(:,:,:,r) = inputImage(:,:,:,imageN);
    end
end

implay([origin,finale]);

    

end
