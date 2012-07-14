function Rs = GetVDP(RH,RV);

Rs = fzero(@VDP(RH,RV),(RH+RV)/2)

end

function vv = VDP(RH,RV)

vv = exp(-pi()*RH/Rs)+exp(-pi()*RV/Rs)-1;

end

