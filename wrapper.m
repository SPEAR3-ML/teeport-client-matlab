function evaluateW = wrapper(evaluate)
    uri = 'ws://zeta:8080/';
    
    % Setup algorithm client
    algorithm = AlgorithmClient(join([uri, '?type=algorithm']));
    waitfor(algorithm, 'id');
    algorithmId = algorithm.id;
    
    % Setup evaluator client
    evaluator = EvaluatorClient(join([uri, '?type=evaluator']));
    waitfor(evaluator, 'id');
    evaluatorId = evaluator.id;
    evaluator.setEvaluate(evaluate);
    
    % Init a new task
    newTask = struct('type', 'newTask', ...
        'algorithmId', algorithmId, 'evaluatorId', evaluatorId);
    algorithm.send(jsonencode(newTask));
    waitfor(algorithm, 'taskId');

    function Y = wrapped(X)
        point = struct('type', 'evaluate', 'data', X);
        algorithm.send(jsonencode(point));
        waitfor(algorithm, 'returned', 1);
        algorithm.returned = 0;
        Y = algorithm.currentY;
    end
    
    evaluateW = @wrapped;
end
