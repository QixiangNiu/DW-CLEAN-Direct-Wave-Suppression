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

function out = music_comparison(single, cfg)
%MUSIC_COMPARISON Eight-element MUSIC comparison using measured peak ratios.

angles = -90:0.25:90;
M = cfg.arrayElements;
K = cfg.musicSnapshots;
aD = exp(-1j*pi*(0:M-1).'*sind(cfg.directAngleDeg));
aE = exp(-1j*pi*(0:M-1).'*sind(cfg.echoAngleDeg));
out.spectrumDB = zeros(numel(single.names), numel(angles));

for m = 1:numel(single.names)
    sD = (randn(1,K)+1j*randn(1,K))/sqrt(2);
    sE = (randn(1,K)+1j*randn(1,K))/sqrt(2);
    ampD = max(single.directPeaks(m), 1e-4);
    ampE = max(single.echoPeaks(m), 1e-4);
    noiseStd = 0.015;
    X = ampD*aD*sD + ampE*aE*sE + ...
        noiseStd/sqrt(2)*(randn(M,K)+1j*randn(M,K));
    R = (X*X')/K;
    [V,D] = eig((R+R')/2, 'vector');
    [~,order] = sort(real(D), 'descend');
    En = V(:,order(3:end));
    P = zeros(size(angles));
    for q = 1:numel(angles)
        a = exp(-1j*pi*(0:M-1).'*sind(angles(q)));
        P(q) = 1/real(a'*(En*En')*a + eps);
    end
    P = 10*log10(P/max(P));
    out.spectrumDB(m,:) = P;
end

out.angles = angles;
out.names = single.names;
[~,iD] = min(abs(angles-cfg.directAngleDeg));
[~,iE] = min(abs(angles-cfg.echoAngleDeg));
out.directPeakDB = out.spectrumDB(:,iD);
out.echoPeakDB = out.spectrumDB(:,iE);
end
