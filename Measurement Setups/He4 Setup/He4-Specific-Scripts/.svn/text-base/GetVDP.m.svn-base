function Rs = GetVDP(RH,RV);

Rs = fzero(@(Rs) VDP(Rs,RH,RV),(RH+RV)*2);
%c = 2; d = 2;
%x = fzero(@(x) myfun(x,c,d),0.1)
%x = fzero(@(x) VDP(x,c,d),0.1)

end

function vv = VDP(Rs,RH,RV)

vv = exp(-pi()*RH/Rs)+exp(-pi()*RV/Rs)-1;

end

function f = myfun(x,c,d)
%f = cos(c*x)+cos(d*x);
f = exp(-pi()*c/x)-1;
end
