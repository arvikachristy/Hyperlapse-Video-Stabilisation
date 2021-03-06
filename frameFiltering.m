function chosenFrames = frameFiltering(path, start_f, end_f)
tic
       
% This is to filter too similar frames
if ~exist('d_matrix.mat')
    inputImage = load_sequence_color(path,'op_',start_f,99+start_f,0,'png', 0.5);

    for e = 99+start_f+1:100:end_f
        disp(e);
        patchImage = load_sequence_color(path,'op_',e,99+e, 0,'png', 0.5);
        inputImage = cat(4,inputImage, patchImage);
    end 
    
    d_matrix = compute_dist(inputImage);
    save('d_matrix.mat', 'd_matrix');
else
    load('d_matrix.mat', 'd_matrix');
end

toc

%Filter Frames thats less than threshold
similarFrames = mean(d_matrix, 2);
binFrames = similarFrames > 0.0050;

chosenFrames = [];

for c = 1:size(binFrames)
    if(binFrames(c))
        chosenFrames = [chosenFrames, c];
    end
end

end