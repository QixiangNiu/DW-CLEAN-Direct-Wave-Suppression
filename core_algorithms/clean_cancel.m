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

function [residual, info] = clean_cancel(received, tx, cfg, useDoubleWindow)
%CLEAN_CANCEL Traditional CLEAN or the paper-inspired DW-CLEAN.
% Continue while the residual correlation PAR is at least threshold D.

residual = received(:);
tx = tx(:);
L = numel(tx);
if useDoubleWindow
    maxIter = cfg.dwMaxIterations;
    nSegments = cfg.window2Segments;
    label = 'DW-CLEAN';
else
    maxIter = cfg.cleanMaxIterations;
    nSegments = 1;
    label = 'CLEAN';
end

info.parDB = nan(maxIter,1);
info.startIndex = nan(maxIter,1);
info.pathGain = cell(maxIter,1);
info.residualPower = nan(maxIter,1);

for it = 1:maxIter
    c = conv(residual, conj(flipud(tx)), 'valid');
    % window1 is used for the direct wave and its early strong multipath;
    % exclude the later target-echo range from cancellation.
    iMin = max(1, round((cfg.directStartSec-cfg.window1StepSec)*cfg.fs)+1);
    iMax = min(numel(c), round((cfg.directStartSec+cfg.maxDirectMultipathDelaySec)*cfg.fs)+1);
    cWindow1 = c(iMin:iMax);
    [~, localIdx] = max(abs(cWindow1));
    idx = iMin+localIdx-1;
    parDB = correlation_par_db(cWindow1);
    info.parDB(it) = parDB;
    if parDB < cfg.thresholdDB
        break;
    end

    segment = residual(idx:idx+L-1);
    estimate = zeros(L,1);
    gains = zeros(nSegments,1);
    for q = 1:nSegments
        q1 = floor((q-1)*L/nSegments)+1;
        q2 = floor(q*L/nSegments);
        tq = tx(q1:q2);
        rq = segment(q1:q2);
        gains(q) = (tq'*rq)/(tq'*tq + eps);
        estimate(q1:q2) = gains(q)*tq;
    end
    residual(idx:idx+L-1) = segment-cfg.cleanLoopGain*estimate;
    info.startIndex(it) = idx;
    info.pathGain{it} = gains;
    info.residualPower(it) = mean(abs(residual).^2);
end

valid = ~isnan(info.startIndex);
info.parDB = info.parDB(1:max(1,find(~isnan(info.parDB),1,'last')));
info.startIndex = info.startIndex(valid);
info.pathGain = info.pathGain(valid);
info.residualPower = info.residualPower(valid);
info.iterations = nnz(valid);
info.method = label;
end
