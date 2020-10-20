% ref: https://ericneyman.wordpress.com/2019/12/26/beyond-the-mean-median-and-mode/

function x = pmean(v, p)

n = length(v);

x = norm(v,p) * (1/n) ^ (1/p);


