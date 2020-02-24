function Xn = normalizeMatrixByJson(X)
    N = size(X, 1);
    D = size(X, 2);
    if D == 1
        Xn = cell(N, 1);
        for i=1:N
            Xn{i} = num2cell(X(i, :), [1, 2]);
        end
    else
        Xn = num2cell(X, 2);
    end
    Xn = {Xn};
end