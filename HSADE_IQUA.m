function [gbest, gbestval, CE, NFEs, SN] = HSADE_IQUA(FUN, D, UB, LB, MaxFEs)
% HSADE with Improved QUATRE Sampling Strategy
% Uses MaxFEs as the termination condition; FUN is a scalar, non-vectorized evaluator
% Outputs:
%   gbest     -- best solution
%   gbestval  -- best value
%   CE        -- best-so-far value after each true evaluation (length = NFEs)
%   NFEs      -- total number of true function evaluations
%   SN        -- [GS success count, LS success count]

begin_time = tic;

% ---------------- Initialization ----------------
NFEs = 0;                    % true evaluation count
CE   = zeros(1, MaxFEs);     % best-so-far trace (indexed by evaluation count)
gbestval = inf;              % global best value
gbest    = zeros(1, D);      % global best solution
GS_sucNum = 0;               % Global Search success count
LS_sucNum = 0;               % Local Search success count

% Initial LHS sample size
if D < 100
    initial_sample_size = 100;
else
    initial_sample_size = 150;
end
NP = 50;  % Maximum global candidate-pool size (take the top NP entries from the database)

% ---------------- Initial LHS sampling and true evaluation (consumes budget) ----------------
hx = repmat(LB, initial_sample_size, 1) + ...
     (repmat(UB, initial_sample_size, 1) - repmat(LB, initial_sample_size, 1)) .* ...
      lhsdesign(initial_sample_size, D);

hf = inf(1, initial_sample_size);
for i = 1:initial_sample_size
    if NFEs >= MaxFEs, break; end
    f = FUN(hx(i,:));             % scalar evaluation
    hf(i) = f;
    NFEs = NFEs + 1;

    if f < gbestval
        gbestval = f; gbest = hx(i,:);
    end
    CE(NFEs) = gbestval;
end

% Remove unevaluated rows (inf)
valid = isfinite(hf);
hx = hx(valid, :);
hf = hf(valid);

% Initial sorting
[hf, sidx] = sort(hf);
hx = hx(sidx, :);

% ---------------- Framework parameters ----------------
F  = 0.5;         % base scaling factor
CR = 0.5;         % crossover probability
gs = min( max(50, round(0.5*size(hx,1))) , size(hx,1) );    % training sample count (global surrogate)
ls = min(50, size(hx,1));                                   % number of local data samples

disp('====== Starting HSADE with Improved QUATRE (MaxFEs termination) ======');

% ================= Main loop (budget-driven) =================
while NFEs < MaxFEs
    progress = NFEs / MaxFEs;

    % ---------- 1) Global search (surrogate-based candidate -> one true evaluation) ----------
    % Use the current top NP individuals as the population
    curNP = min(NP, size(hx,1));
    pop = hx(1:curNP, :);
    pop_fit = hf(1:curNP);

    VRmax = repmat(UB, curNP, 1);
    VRmin = repmat(LB, curNP, 1);

    % Build the global surrogate (RBF, MATLAB's newrbe)
    gs_use = min(gs, size(hx,1));
    ghx = hx(1:gs_use, :);
    ghf = hf(1:gs_use);
    ghxd = real(sqrt(ghx.^2*ones(size(ghx')) + ones(size(ghx))*(ghx').^2 - 2*ghx*(ghx')));
    spr = max(max(ghxd))/(D*gs_use)^(1/D);
    try
        net = newrbe(ghx', ghf, spr);
        modelFUN = @(x) sim(net, x')';  % returns a 1-by-K row
    catch
        % If the Neural Network Toolbox is unavailable or fails, fall back to a simple polynomial evaluator
        modelFUN = @(x) sum((x - mean(ghx,1)).^2, 2);
    end

    % Candidate generation (surrogate ranking only; no true budget consumed)
    K  = 30;
    Uc = QUATRE_Improved(pop, curNP, D, F, CR, VRmax, VRmin, ...
                         'fitness', pop_fit', ...
                         'progress', progress, ...
                         'enable_adaptive', true);

    % Score with the surrogate and aggregate candidates
    pred = modelFUN(Uc);                 % 1-by-curNP or curNP-by-1
    [~, ord] = sort(pred(:), 'ascend');
    chooseK = min(K, size(Uc,1));
    pool = Uc(ord(1:chooseK), :);

    % Randomly take a prefix of the top pool and average it (balances exploration and exploitation)
    rr = randi(chooseK); 
    col = pool(1:rr, :);
    cand = mean(col, 1);

    % True evaluation (consumes one budget unit)
    if NFEs >= MaxFEs, break; end
    cand_fit = FUN(cand);
    NFEs = NFEs + 1;

    % Update database
    hx = [hx; cand];
    hf = [hf, cand_fit];
    [hf, sidx] = sort(hf);
    hx = hx(sidx, :);

    % Update global best
    if cand_fit <= gbestval
        gbestval = cand_fit; gbest = cand;
        GS_sucNum = GS_sucNum + 1;
        disp(['Best Cost(GS) = ' num2str(gbestval, '%.6e') ' | NFE=' num2str(NFEs) ' | prog=' num2str(progress, '%.2f')]);
    end

    CE(NFEs) = gbestval;
    if NFEs >= MaxFEs, break; end

    % ---------- 2) Local search (budgeted improved LPSR) ----------
    % Take the top ls entries as local data
    ls_use = min(ls, size(hx,1));
    lhx = hx(1:ls_use, :);
    lhf = hf(1:ls_use);

    local_LB = min(lhx, [], 1);
    local_UB = max(lhx, [], 1);

    % Local surrogate
    lhxd = real(sqrt(lhx.^2*ones(size(lhx')) + ones(size(lhx))*(lhx').^2 - 2*lhx*(lhx')));
    sprL = max(max(lhxd))/(D*ls_use)^(1/D);
    try
        netL = newrbe(lhx', lhf, sprL);
        LocalModelFUN = @(x) sim(netL, x')';
    catch
        LocalModelFUN = @(x) sum((x - mean(lhx,1)).^2, 2);
    end

    % Pass in the remaining budget
    remainBudget = MaxFEs - NFEs;
    if remainBudget <= 0, break; end

    maxLocalFEs = min(remainBudget, 50*D);   % Cap the local search budget
    minerror = 1e-8;

    [candLS, candLS_fit, usedFEs] = LocalSearch_LPSR_Improved( ...
        D, maxLocalFEs, FUN, minerror, lhx, local_LB, local_UB, LocalModelFUN);

    NFEs = NFEs + usedFEs;
    if usedFEs > 0
        % Insert candLS into the database (candLS_fit is already a true evaluation)
        hx = [hx; candLS];
        hf = [hf, candLS_fit];
        [hf, sidx] = sort(hf);
        hx = hx(sidx, :);

        if candLS_fit <= gbestval
            gbestval = candLS_fit; gbest = candLS;
            LS_sucNum = LS_sucNum + 1;
            disp(['Best Cost(LS) = ' num2str(gbestval, '%.6e') ' | NFE=' num2str(NFEs)]);
        end
        CE(NFEs) = gbestval;
    end
end

SN = [GS_sucNum, LS_sucNum];
disp('====== Optimization Complete ======');
disp(['Final best value: ', num2str(gbestval, '%.6e')]);
disp(['Total NFEs used : ', num2str(NFEs)]);
% Truncate CE to the actual NFEs length
CE = CE(1:NFEs);
end


% ================= Improved QUATRE generation operator (no true evaluation) =================
function U = QUATRE_Improved(P, NP, Dim, F, CR, VRmax, VRmin, varargin)
    p = inputParser;
    addParameter(p, 'fitness', [], @isnumeric);
    addParameter(p, 'progress', 0.5, @(x) x>=0 && x<=1);
    addParameter(p, 'enable_adaptive', true, @islogical);
    parse(p, varargin{:});

    fitness = p.Results.fitness;
    progress = p.Results.progress;
    enable_adaptive = p.Results.enable_adaptive;

    if isempty(fitness)
        fitness = sum(P.^2, 2); % simple fallback
    end
    [~, gbestid] = min(fitness);
    gbest = P(gbestid, :);

    % Generate lower-triangular mask label
    K = floor(NP/Dim);
    label = zeros(NP, Dim);
    for j = 0:K-1
        label(j*Dim+1:j*Dim+Dim, :) = tril(ones(Dim, Dim), 0);
    end
    if K*Dim < NP
        label(K*Dim+1:NP, :) = tril(ones(NP-K*Dim, Dim), 0);
    end
    for t = 1:NP
        label(t, :) = label(t, randperm(Dim));
    end
    label = label(randperm(NP)', :);

    % Adaptive F
    F_final = F;
    if enable_adaptive
        diversity = mean(std(P, 0, 1));
        max_range = mean(VRmax(1,:) - VRmin(1,:));
        diversity_ratio = max(1e-12, diversity / max_range);
        F_adp = F * (0.5 + diversity_ratio);
        F_adp = max(0.3, min(1.0, F_adp));
        F_prog = F * (1.2 - 0.5*progress);
        F_final = 0.7*F_adp + 0.3*F_prog;
    end

    U = zeros(NP, Dim);
    for i = 1:NP
        % Strategy selection
        if enable_adaptive
            r = rand();
            if progress < 0.3
                strat = (r < 0.6) + 1;       % 1: rand/1, 2: current-to-best/1
            elseif progress < 0.7
                if r < 0.3, strat = 1; elseif r < 0.7, strat = 2; else, strat = 3; end
            else
                strat = 2 + (r >= 0.2);      % 2: current-to-best/1, 3: best/1
            end
        else
            strat = 3;
        end

        % Select r1, r2, and r3
        idx = randperm(NP); idx(idx==i) = [];
        k0 = idx(1); k1 = idx(2); k2 = idx(3);
        P1 = P(k0,:); P2 = P(k1,:); P3 = P(k2,:);

        switch strat
            case 1 % rand/1
                V = P1 + F_final*(P2 - P3);
            case 2 % current-to-best/1
                V = P(i,:) + F_final*(gbest - P(i,:)) + F_final*(P2 - P3);
            otherwise % best/1
                V = gbest + F_final*(P2 - P3);
        end

        % QUATRE mask copy
        Ui = P(i,:);
        Ui(logical(label(i,:))) = V(logical(label(i,:)));

        % Boundary handling
        Ui = handleBoundary(Ui, P(i,:), VRmin(i,:), VRmax(i,:));

        U(i,:) = Ui;
    end
end

% -- Boundary handling: reflection + midpoint strategy + clipping -- 
function x_new = handleBoundary(x, x_old, LB, UB)
    x_new = x;
    for j = 1:length(x)
        if x(j) < LB(j) || x(j) > UB(j)
            if rand() < 0.8
                if x(j) < LB(j)
                    x_new(j) = LB(j) + (LB(j) - x(j));
                    if x_new(j) > UB(j), x_new(j) = (LB(j)+UB(j))/2; end
                else
                    x_new(j) = UB(j) - (x(j) - UB(j));
                    if x_new(j) < LB(j), x_new(j) = (LB(j)+UB(j))/2; end
                end
            else
                if x(j) < LB(j), x_new(j) = (LB(j)+x_old(j))/2;
                else,            x_new(j) = (UB(j)+x_old(j))/2; end
            end
            x_new(j) = max(LB(j), min(UB(j), x_new(j)));
        end
    end
end

% ================== Local search (budgeted, point-by-point evaluation) ==================
function [bestX, bestFit, usedFEs] = LocalSearch_LPSR_Improved( ...
    Dim, maxFes, FUN, minerror, lhx, LB, UB, LocalModelFUN)

    NP0 = 50; max_NP = NP0; min_NP = 4;
    F = 0.5; CR = 0.8;

    % Initialization
    NP = NP0;
    X  = (UB - LB).*rand(NP,Dim) + LB;

    % True evaluation (evaluate as much of the initial population as possible)
    fitnessX = inf(NP,1);
    evalX    = false(NP,1);      % true-evaluation flag
    usedFEs  = 0;
    for i = 1:NP
        if usedFEs >= maxFes, break; end
        fitnessX(i) = FUN(X(i,:));
        evalX(i)    = true;
        usedFEs     = usedFEs + 1;
    end
    % Unevaluated individuals are placeholders only and are not used for best comparisons
    if any(~evalX)
        fitnessX(~evalX) = LocalModelFUN(X(~evalX,:));
    end

    % Search for the best only among truly evaluated points; exit if none were evaluated
    if any(evalX)
        [bestFit, idxbest] = min(fitnessX(evalX));
        idxList = find(evalX);
        bestX   = X(idxList(idxbest),:);
    else
        bestFit = inf;
        bestX   = X(1,:);
        return;
    end

    emaImp = 0; beta = 0.8; tau_imp = 1e-5;

    while usedFEs < maxFes
        fitnessBest_old = bestFit;

        % Mutation + crossover
        V = zeros(NP,Dim); U = zeros(NP,Dim);
        [~, sorted_index] = sort(fitnessX);     % Safe: only used to choose pbest
        pNP = max(round(0.2*NP),2);

        for i = 1:NP
            pbest_idx = sorted_index(randi(pNP));
            pbest = X(pbest_idx,:);

            r1 = randi(NP); while r1==i, r1 = randi(NP); end
            r2 = randi(NP); while r2==i || r2==r1, r2 = randi(NP); end

            V(i,:) = X(i,:) + F*(pbest - X(i,:)) + F*(X(r1,:) - X(r2,:));
            V(i,:) = max(LB, min(UB, V(i,:)));
        end

        for i = 1:NP
            jrand = randi(Dim);
            for j = 1:Dim
                if rand <= CR || j == jrand
                    U(i,j) = V(i,j);
                else
                    U(i,j) = X(i,j);
                end
            end
        end

        % -- Point-by-point true evaluation: evaluate while budget allows; otherwise mark as unevaluated -- 
        fitnessU = inf(NP,1);
        evalU    = false(NP,1);
        for i = 1:NP
            if usedFEs >= maxFes, break; end
            fitnessU(i) = FUN(U(i,:));
            evalU(i)    = true;
            usedFEs     = usedFEs + 1;
        end
        % Unevaluated items use surrogate placeholders (only for sorting/density checks) and do not participate in replacement or best comparisons
        if any(~evalU)
            fitnessU(~evalU) = LocalModelFUN(U(~evalU,:));
        end

        % -- One-to-one selection: replacement is allowed only when evalU(i) is true -- 
        for i = 1:NP
            if evalU(i) && (fitnessU(i) <= fitnessX(i))
                X(i,:)       = U(i,:);
                fitnessX(i)  = fitnessU(i);
                evalX(i)     = true;      % this individual has a true evaluation
                if fitnessU(i) < bestFit
                    bestFit = fitnessU(i);
                    bestX   = X(i,:);
                end
            end
        end

        % EMA improvement rate
        rel_imp = max(0, (fitnessBest_old - bestFit) / (abs(fitnessBest_old) + 1e-12));
        emaImp  = beta*emaImp + (1-beta)*rel_imp;

        NP_linear = round(((min_NP - max_NP)/maxFes)*usedFEs + max_NP);
        next_NP = NP;
        if emaImp < tau_imp
            next_NP = min(NP, NP_linear);
        end

        % Shrink by density + worst value; placeholder fitness may be used for density/sorting but not for best updates
        if next_NP < NP
            re_num = NP - next_NP;
            if next_NP < min_NP, re_num = NP - min_NP; end

            XX = sum(X.^2,2);
            dmat = sqrt(max(0, XX + XX' - 2*(X*X')));
            dmat(1:NP+1:end) = inf;
            nnDist = min(dmat, [], 2);
            [~, densIdx]  = sort(nnDist,'ascend');
            [~, worstIdx] = sort(fitnessX,'descend');

            take_dens  = floor(re_num/2);
            take_worst = re_num - take_dens;
            delIdx = unique([densIdx(1:take_dens); worstIdx(1:take_worst)]);

            k = 1;
            while numel(delIdx) < re_num && k <= NP
                c = worstIdx(k);
                if ~ismember(c, delIdx), delIdx(end+1,1) = c; end
                k = k + 1;
            end

            X(delIdx,:)      = [];
            fitnessX(delIdx) = [];
            evalX(delIdx)    = [];
            NP = size(X,1);
        end

        if abs(fitnessBest_old - bestFit) <= minerror
            break;
        end
    end
end

