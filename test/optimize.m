function optimize(max_generation)
    if isempty(max_generation)
        max_generation = 10;
    end
    
    w_evaluate = wrapper(@evaluate);
    
    for i = 1:max_generation
        X = randn(1, 10);
        Y = w_evaluate(X);
        Y
    end
end

function Y = evaluate(X)
    Y = sum(X);
end
