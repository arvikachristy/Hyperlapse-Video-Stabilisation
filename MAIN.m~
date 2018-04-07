%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Courtesy of Vika Christy 2018 for Computational Photography Coursework UCL
%Hyperlapse - Project 2(Submission)
%Student Number: 14049380
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

runme()

function runme()
tic
path = 'shaky-holloway';

%%%%%%%%%%%%%%%%%%%%%%%%Part 1 - Frame Filtering %%%%%%%%%%%%%%%%%%%%%%%%%%
chosenFrames = frameFiltering(path, 1, 2000);

if ~exist('resInputImg.mat')
    %produces filtered image
    resInputImg = playFrame(chosenFrames, path);
else
    load('resInputImg.mat', 'resInputImg');
end

start_f = 1; until_f = size(resInputImg,4);
w = 11;
totalN = until_f-start_f;
cm_storage = zeros(totalN, totalN);

inputImage = resInputImg;
[height,width,~,imageN] = size(inputImage);

%%%%%%%%%%%%%%%%%%%%%%%%Part 2 - Frame Matching %%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('cm_storage.mat')
    for i = 1:imageN-1
        disp('Ransac no:');
        disp(i);
        if(imageN-i > w-2)
            last = i+(w-1);
        else
            last = imageN;
        end

        for j = i+1:last
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
            
            try
                [x,y] = transformPointsForward(holder_model, width/2, height/2); 
            catch
                continue
            end

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
        end
        if ~exist('cm_storage.mat') 
            save('cm_storage.mat', 'cm_storage');
        else
            save('cm_storage.mat', 'cm_storage', '-append');
        end
    end
else
    load('cm_storage.mat', 'cm_storage');
end

%%%%%%%%%%%%%%%%%%%%Part 3 - Frame Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = 4;v = 8;
ts = 200;
ls = 5;
la = 2;

Dv = zeros(imageN, imageN);
for i = 1:g
    for j = i+1:i+w
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

%Put the final path together
finale = zeros(height, width, 3, 3);
origin = zeros(height, width, 3, 3);
% store = [];
for r = 1:size(path_chosen,2)
    finale(:,:,:,r) = inputImage(:,:,:,path_chosen(r));
    if(8*r<imageN)
%         store = [store, 8*r];
        origin(:,:,:,r) = inputImage(:,:,:,8*r);
    else
%         store = [store, imageN];
        origin(:,:,:,r) = inputImage(:,:,:,imageN);
    end
end


% Process all frames in the video
movMean = rgb2gray(finale(:,:,:,1));
imgB = movMean;
imgBp = imgB;
correctedMean = imgBp;
ii = 2;
Hcumulative = eye(3);
pom = zeros(size(movMean,1),size(movMean,2),size(path_chosen,2));
counter =1;

while ii <= size(path_chosen,2)
    % Read in new frame
    
    imgA = imgB; % z^-1
    imgAp = imgBp; % z^-1
    imgB = rgb2gray(finale(:,:,:,ii));
    movMean = movMean + imgB;

    % Estimate transform from frame A to frame B, and fit as an s-R-t
    H = cvexEstStabilizationTform(imgA,imgB);
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    imgBp = imwarp(imgB,affine2d(HsRt),'OutputView',imref2d(size(imgB)));
    pom(:,:,counter) = imgBp;
    counter = counter+1;
    % Display as color composite with last corrected frame
    correctedMean = correctedMean + imgBp;
    
    ii = ii+1;
end
correctedMean = correctedMean/(ii-2);
movMean = movMean/(ii-2);




%%%%%%%%%%%%%%%%%%%%%%%%Part 4 - Frame Stabilisation %%%%%%%%%%%%%%%%%%%%%%
% after_stable = zeros(height,width,3,size(path_chosen,2));
% stable_store = [];
% for v=2:size(path_chosen,2)
%     disp('Stabilising:');
%     disp(v);
%     imgA = rgb2gray(inputImage(:,:,:,path_chosen(v)));
%     imgB = rgb2gray(inputImage(:,:,:,path_chosen(v-1)));
%     
%     pointsA = detectHarrisFeatures(imgA);
%     pointsB = detectHarrisFeatures(imgB); 
%     
%     [featuresA, pointsA] = extractFeatures(imgA, pointsA);
%     [featuresB, pointsB] = extractFeatures(imgB, pointsB);
%     
%     % Extract Descriptor from Feature Point
%     indexPairs = matchFeatures(featuresA, featuresB);
%     stable_store = [stable_store, size(indexPairs,1)];
%     %If there are more than 3 matched points
%     if(size(indexPairs,1)>13)
%         pointsA = pointsA(indexPairs(:, 1), :);
%         pointsB = pointsB(indexPairs(:, 2), :);
% 
% %         figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
% %         legend('A', 'B');
% 
%         [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
%         pointsB, pointsA, 'affine');
% 
%         % Extract scale and rotation part sub-matrix.
%         H = tform.T;
%         R = H(1:2,1:2);
% 
%         % Compute theta from mean of two possible arctangents
%         theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
%         % Compute scale from mean of two stable mean calculations
%         scale = mean(R([1 4])/cos(theta));
%         % Translation remains the same:
%         translation = H(3, 1:2);
%         % Reconstitute new s-R-t transform:
%         HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
%           translation], [0 0 1]'];
%         tformsRT = affine2d(HsRt);
% 
%     %     imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
%         imgBsRt = imwarp(inputImage(:,:,:,path_chosen(v-1)), tformsRT, 'OutputView', imref2d(size(imgB)));
% 
%         crop = 20;
%         after_stable(:,:,:,v-1) = imresize(imgBsRt(crop:height-crop,crop:width-crop,:), [height, width]);
%     else
%         after_stable(:,:,:,v-1) = imresize(inputImage(crop:height-crop,crop:width-crop,:,path_chosen(v-1)), [height,width]);
%     end
% end
% 
% after_stable(:,:,:,size(path_chosen,2)) = imresize(inputImage(crop:height-crop,crop:width-crop,:,path_chosen(size(path_chosen,2))), [height,width]);
% % checkmean
% mean = 0;
% stab = 0;
% for ind = 100: 110
%     mean = mean + origin(:,:,:,ind);
%     stab = stab + after_stable(:,:,:,ind);
% end
% imshow([mean/10, stab/10]);

%Convert to video...
videoFinal = VideoWriter('final_video.mp4','MPEG-4');
open(videoFinal);

after_stable(after_stable>1)=1;
after_stable(after_stable<0)=0;

for index = 1: size(path_chosen,2)
    disp(index);
    writeVideo(videoFinal,finale(:,:,:,index));
end
close(videoFinal);

implay(finale);
toc

end

function res = c_a(h, i, j)
    ta = 200;
    res = min(((j-i)-(i-h))^2, ta);
end

