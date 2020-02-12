function cleanUp = evaluator()
%     evaluateW = wrapper(@evaluate);
    [evaluatorId, cleanUp] = evalWrapper(@evaluate);
    
    fprintf('evaluatorId: %s', evaluatorId);
end

function Y = evaluate(X)
    Y = sum(X);
end
