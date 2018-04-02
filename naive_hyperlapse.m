
%This is to produce naive hyperlapse video selection in order to compare
%our result to (benchmark video). Take each 8 frame and produce hyperlapse

path = 'road-camden-rename';

origin = zeros(360, 640, 3, 3);
count = 1;
for r = 1:2000
    disp(r);
    if(mod(r,8) == 1) %if true
        if(path(end)=='/')
            slash='';
        else
            slash='/';
        end

        % Create the filename
        filename = strcat(path,slash,'op_',int2str(r),'.','png');

        % Load image and convert it to gray level
        gotimg = im2double(imresize(imread(filename), 0.5));        
        
        origin(:,:,:,count) = gotimg;
        count = count+1;
    end
end

implay(origin);