function [mydist]=getDistance(point1, point2)
%[mydist]=getDistance(point1, point2)
%find the distance between point1 and point2
p1X = point1(1,1);
p1Y = point1(1,2);
p2X = point2(1,1);
p2Y = point2(1,2);
x = p1X - p2X;
y = p1Y - p2Y;
x = x ^ 2;
y = y ^ 2;
mydist = (x + y) ^ 0.5;