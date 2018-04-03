%Simple function to show video based on given path
function origin = playFrame(selected_frame, path)

%     videoFinal = VideoWriter('final_video.mp4','MPEG-4');
%     open(videoFinal);

    origin = zeros(360, 640, 3, 3);
    count = 1;
    
    for r = 1:size(selected_frame,2)
%          if(mod(r,8) == 1)
            disp(r);
            if(path(end)=='/')
                slash='';
            else
                slash='/';
            end

            % Create the filename
            filename = strcat(path,slash,'op_',int2str(selected_frame(r)),'.','png');

            % Load image and convert it to gray level
            gotimg = im2double(imresize(imread(filename), 0.5));        

            origin(:,:,:,count) = gotimg;
%             writeVideo(videoFinal,origin(:,:,:,count));
            
            count = count+1;
%          end
    end
%     close(videoFinal);
    implay(origin);
    
end

