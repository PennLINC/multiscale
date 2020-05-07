function res = calc_recon_error(data, u, v)
% data: t by v matrix
% u: t by k matrix
% v: v by k matrix
e = data - u * v';
res = sum(e(:).^2);
