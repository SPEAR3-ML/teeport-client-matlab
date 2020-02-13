function cleanUp = run_evaluator()
    [evaluatorId, cleanUp] = evalWrapper(@evaluate);
    
    fprintf('evaluatorId: %s', evaluatorId);
end

function Y = evaluate(X)
    Y = sum(X, 2);
end
