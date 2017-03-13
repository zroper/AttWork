function [rndInt]=randInt(myMin, myMax)
%randInt(myMin, myMax)
%finds a random integer between myMin and myMax
%myMin must be less than myMax

rangeList = myMin:myMax;
mySize = size(rangeList,2);
indexList = randperm(mySize);
myIndex = indexList(1);
rndInt = rangeList(myIndex);