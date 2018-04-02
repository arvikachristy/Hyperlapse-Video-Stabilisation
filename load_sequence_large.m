 path = 'road-camden';
% 
first=1;
last=5;
% digits=5;
% prefix='op';
% suffix='png';
reduce_image(path,'op',first,last,5,'png', 0.3);

function reduce_image(path,prefix, first, last, digits, suffix, resize)
number = padded_number(first, digits);
% Check for slash at the end of the path
if(path(end)=='/')
    slash='';
else
    slash='/';
end

% Create the filename
filename = strcat(path,slash,prefix,number,'.',suffix);

% Load image and convert it to gray level
current = im2double(imresize(imread(filename), resize));

holder = current;

if ~exist('largeImg.mat')
    save('largeImg.mat', 'holder');
end

filename='largeImg.mat';
output = matfile(filename,'Writable',true);

for i=2:last-first+1

    % Get the padded frame number
    number = padded_number(first+i-1, digits);

    % Create the filename
    filename = strcat(path,slash,prefix,number,'.',suffix);

    % Load image and convert it to gray level
    current = im2double(imresize(imread(filename), resize));

    % Update output matrix
    output.holder(:,:,:,i) = current;

    % Print filename
	% sprintf('file=%s\n',filename)

end

end

function output = padded_number(number, digits)

%
% Add zeros to the left of the number to match the given length
%

% Convert to string
output = num2str(number);

% Get length of string
l = size(output,2);

% Add necessary zeros
for i=l+1:digits

    output=strcat('0', output);

end

end
           
      