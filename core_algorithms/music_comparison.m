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
%MUSIC_COMPARISON Eight-element MUSIC using processed MF snapshots.
% Source snapshots are bootstrapped from the actual direct and echo
% matched-filter mainlobes. Only independent sensor noise is synthesized.

angles = -90:0.25:90;
M = cfg.arrayElements;
K = cfg.musicSnapshots;
aD = exp(-1j*pi*(0:M-1).'*sind(cfg.directAngleDeg));
aE = exp(-1j*pi*(0:M-1).'*sind(cfg.echoAngleDeg));
out.spectrumDB = zeros(numel(single.names),numel(angles));
guard = max(2,round(0.002*cfg.fs));

previous = rng;
cleanup = onCleanup(@() rng(previous));
rng(cfg.randomSeed+52000,'twister');
for method = 1:numel(single.names)
    [cOutput,~] = correlation_trace(single.outputs{method}, ...
        single.sim.reference(single.sim.directStart: ...
        single.sim.directStart+round(cfg.T*cfg.fs)-1), ...
        single.sim.directStart,cfg.fs);
    [cEcho,~] = correlation_trace(single.sim.echo, ...
        single.sim.reference(single.sim.directStart: ...
        single.sim.directStart+round(cfg.T*cfg.fs)-1), ...
        single.sim.directStart,cfg.fs);
    [cNoise,~] = correlation_trace(single.sim.noise, ...
        single.sim.reference(single.sim.directStart: ...
        single.sim.directStart+round(cfg.T*cfg.fs)-1), ...
        single.sim.directStart,cfg.fs);
    cResidualDirect = cOutput-cEcho-cNoise;
    directIndices = max(1,single.sim.directStart-guard): ...
        min(numel(cOutput),single.sim.directStart+guard);
    echoIndices = max(1,single.sim.echoStart-guard): ...
        min(numel(cOutput),single.sim.echoStart+guard);
    sourceD = cResidualDirect(directIndices);
    sourceE = cEcho(echoIndices);
    sourceD = reshape(sourceD(randi(numel(sourceD),1,K)),1,[]);
    sourceE = reshape(sourceE(randi(numel(sourceE),1,K)),1,[]);

    floorMask = true(size(cOutput));
    floorMask(max(1,directIndices(1)-guard): ...
        min(numel(cOutput),directIndices(end)+guard)) = false;
    floorMask(max(1,echoIndices(1)-guard): ...
        min(numel(cOutput),echoIndices(end)+guard)) = false;
    sensorNoiseStd = sqrt(median(abs(cNoise(floorMask)).^2)+eps);
    sensorNoise = sensorNoiseStd/sqrt(2)*(randn(M,K)+1j*randn(M,K));
    X = aD*sourceD+aE*sourceE+sensorNoise;
    X = X-mean(X,2);
    R = (X*X')/K;
    [V,D] = eig((R+R')/2,'vector');
    [~,order] = sort(real(D),'descend');
    En = V(:,order(3:end));
    spectrum = zeros(size(angles));
    for q = 1:numel(angles)
        steering = exp(-1j*pi*(0:M-1).'*sind(angles(q)));
        denominator = real(steering'*(En*En')*steering);
        spectrum(q) = 1/max(denominator,eps);
    end
    out.spectrumDB(method,:) = 10*log10(spectrum/max(spectrum));
end

out.angles = angles;
out.names = single.names;
[~,iD] = min(abs(angles-cfg.directAngleDeg));
[~,iE] = min(abs(angles-cfg.echoAngleDeg));
out.directPeakDB = out.spectrumDB(:,iD);
out.echoPeakDB = out.spectrumDB(:,iE);
out.arraySnapshots = K;
clear cleanup
end
