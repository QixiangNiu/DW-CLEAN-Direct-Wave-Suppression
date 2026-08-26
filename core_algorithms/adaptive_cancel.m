% =========================================================================
% *       *  *********  *       *
% **      *  *       *  *       *
% * *     *  *       *  *       *
% *  *    *  *       *  *       *
% *   *   *  *********  *       *
% *    *  *  *          *       *
% *     * *  *          *       *
% *      **  *          *       *
% *       *  *           *******
%
% Author: QIXIANG NIU
% Affiliation:
%   Northwestern Polytechnical University, School of Marine Science and Technology
%   Underwater Communication and Cooperative Detection Laboratory
%   Ocean Institute, Northwestern Polytechnical University
% Chinese affiliation:
%   西北工业大学航海学院“水下通信与协同探测”实验室
%   西北工业大学海洋研究院
% Date: 2023-10-15
% Copyright (c) 2023 QIXIANG NIU. All rights reserved.
% For academic research and reproducibility. Retain this notice.
% =========================================================================

function [residual, info] = adaptive_cancel(desired, reference, cfg, method)
%ADAPTIVE_CANCEL Complex LMS, NLMS, or RLS reference-channel canceller.

d = desired(:); x = reference(:);
N = numel(d); M = cfg.filterOrder;
w = zeros(M,1);
residual = d;
estimate = zeros(N,1);
sampleEvery = max(1, floor(N/60));
wHistory = zeros(M, ceil(N/sampleEvery));
errHistory = zeros(ceil(N/sampleEvery),1);
hCount = 0;

if strcmpi(method, 'RLS')
    P = 100*eye(M);
end

for n = M:N
    u = x(n:-1:n-M+1);
    yhat = w' * u;
    e = d(n)-yhat;
    estimate(n) = yhat;
    residual(n) = e;

    switch upper(method)
        case 'LMS'
            w = w + cfg.muLMS*u*conj(e);
        case 'NLMS'
            w = w + (cfg.muNLMS/(cfg.nlmsDelta + real(u'*u)))*u*conj(e);
        case 'RLS'
            den = cfg.rlsLambda + u'*P*u;
            k = (P*u)/den;
            w = w + k*conj(e);
            P = (P-k*(u'*P))/cfg.rlsLambda;
            P = (P+P')/2;
        otherwise
            error('Unknown adaptive method: %s', method);
    end

    if mod(n-M, sampleEvery)==0 || n==N
        hCount = hCount+1;
        wHistory(:,hCount) = w;
        i1 = max(M,n-sampleEvery+1);
        errHistory(hCount) = mean(abs(residual(i1:n)).^2);
    end
end

info.method = upper(method);
info.finalWeights = w;
info.estimate = estimate;
info.weightHistory = wHistory(:,1:hCount);
info.errorPower = errHistory(1:hCount);
info.sampleEvery = sampleEvery;
end
