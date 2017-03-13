function strnumnew=prettyprint(num)
if isnumeric(num)==1
    strnum=num2str(num);
    strnum2=regexprep(fliplr(strnum),' ','');
else
    if ischar(num)==1
        if sum(ismember(num,','))==0
        strnum2=regexprep(fliplr(num),' ','');
        end
    end
end
if isempty(str2num(strnum2))==0
strnum3=[];
for i=1:size(strnum2,2)
    iv=logical(abs(double(logical(i-fix(i/3)*3))-1));
    if iv
        if i~=size(strnum2,2)
            strv=[strnum2(1,i) ','];
        else
            strv=strnum2(1,i);
        end
    else
        strv=strnum2(1,i);
    end
      strnum3=[strnum3 strv];
  end
  strnumnew=fliplr(strnum3);
  else
  strnumnew=num;    
  end
%end function