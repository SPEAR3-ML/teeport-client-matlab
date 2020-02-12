function optimize(maxGeneration)
    switch nargin
      case 0
        maxGeneration = [];
      case 1
      otherwise
        error('1 input is accepted')
    end
    if isempty(maxGeneration)
        maxGeneration = 10;
    end
    
%     evaluateW = wrapper(@evaluate);
    [evaluateW, cleanUp] = wrapper(@evaluate);
    
    for i = 1:maxGeneration
        X = randn(1, 10);
        Y = evaluateW(X);
        Y
    end
    
    cleanUp();
end

function Y = evaluate(X)
    Y = sum(X);
end
