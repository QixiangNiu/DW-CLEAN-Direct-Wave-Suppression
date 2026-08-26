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
%CLEAN_CANCEL Paper equations (20)-(33) and Algorithm 1 without plotting.
% Window1 is moved by lambda over the direct-wave/multipath search region.
% For DW-CLEAN, each aligned window is divided into n Window2 segments.

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
info.windowStartIndex = nan(maxIter,1);
info.pathGain = cell(maxIter,1);
info.windowScores = cell(maxIter,1);
info.residualPower = nan(maxIter,1);
stepSamples = max(1,round(cfg.window1StepSec*cfg.fs));
searchFirst = max(1,round((cfg.directStartSec-cfg.window1StepSec)*cfg.fs)+1);
searchLast = min(numel(residual)-L+1,round( ...
    (cfg.directStartSec+cfg.maxDirectMultipathDelaySec)*cfg.fs)+1);
windowGrid = searchFirst:stepSamples:searchLast;
if windowGrid(end) ~= searchLast
    windowGrid(end+1) = searchLast;
end

for it = 1:maxIter
    c = conv(residual,conj(flipud(tx)),'valid');
    % Equation (25): move Window1 by lambda and retain the strongest aligned
    % correlation inside every movement interval.
    windowScores = zeros(size(windowGrid));
    candidateIndex = zeros(size(windowGrid));
    for window = 1:numel(windowGrid)
        rangeFirst = windowGrid(window);
        if window < numel(windowGrid)
            rangeLast = min(searchLast,windowGrid(window+1)-1);
        else
            rangeLast = searchLast;
        end
        [windowScores(window),localIdx] = max(abs(c(rangeFirst:rangeLast)));
        candidateIndex(window) = rangeFirst+localIdx-1;
    end
    [~,bestWindow] = max(windowScores);
    idx = candidateIndex(bestWindow);
    cWindow1 = c(searchFirst:searchLast);
    parDB = correlation_par_db(cWindow1);
    info.parDB(it) = parDB;
    if parDB < cfg.thresholdDB
        break;
    end

    windowStart = windowGrid(bestWindow);
    aligned = residual(idx:idx+L-1);
    estimate = zeros(L,1);
    gains = zeros(nSegments,1);
    for q = 1:nSegments
        q1 = floor((q-1)*L/nSegments)+1;
        q2 = floor(q*L/nSegments);
        tq = tx(q1:q2);
        rq = aligned(q1:q2);
        segmentEstimate = zeros(size(rq));
        for inner = 1:cfg.segmentMaxIterations
            % Equations (29)-(31). A complex estimate retains the carrier
            % delay phase in (30), while its magnitude equals the MF estimate.
            gain = (tq'*rq)/(tq'*tq+eps);
            component = cfg.cleanLoopGain*gain*tq;
            rq = rq-component;
            segmentEstimate = segmentEstimate+component;
            segmentCorrelation = conv(rq,conj(flipud(tq)),'full');
            if correlation_par_db(segmentCorrelation) < cfg.thresholdDB
                break;
            end
        end
        gains(q) = (tq'*segmentEstimate)/(tq'*tq+eps);
        estimate(q1:q2) = segmentEstimate;
    end
    if nSegments > 1 && cfg.segmentGainSmoothing > 1
        % Enforce the continuous reconstructed direct wave required before
        % splicing in (33), while reducing segment-wise noise in A_hat_dn.
        gains = movmean(gains,cfg.segmentGainSmoothing,'Endpoints','shrink');
        for q = 1:nSegments
            q1 = floor((q-1)*L/nSegments)+1;
            q2 = floor(q*L/nSegments);
            estimate(q1:q2) = gains(q)*tx(q1:q2);
        end
    end
    % Equation (33) is the concatenation already represented by estimate.
    residual(idx:idx+L-1) = aligned-estimate;
    info.startIndex(it) = idx;
    info.windowStartIndex(it) = windowStart;
    info.pathGain{it} = gains;
    info.windowScores{it} = windowScores;
    info.residualPower(it) = mean(abs(residual).^2);
end

valid = ~isnan(info.startIndex);
info.parDB = info.parDB(1:max(1,find(~isnan(info.parDB),1,'last')));
info.startIndex = info.startIndex(valid);
info.windowStartIndex = info.windowStartIndex(valid);
info.pathGain = info.pathGain(valid);
info.windowScores = info.windowScores(valid);
info.residualPower = info.residualPower(valid);
info.iterations = nnz(valid);
info.method = label;
info.estimate = received(:)-residual;
info.windowStepSamples = stepSamples;
info.windowGrid = windowGrid;
end
