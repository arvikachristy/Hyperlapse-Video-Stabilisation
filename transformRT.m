function H = transformRT(H)

% Obtain rotation and translation
R = H(1:2,1:2);
t = H(3, 1:2);

tht = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);

R = [cos(tht) -sin(tht); sin(tht) cos(tht)];
H = [[R; t], [0 0 1]'];

end
