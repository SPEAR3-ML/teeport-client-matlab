function [evaluateW, cleanUp] = wrapper(evaluate)
    uri = 'ws://zeta:8080/';
    
    % Setup algorithm client
    algorithm = AlgorithmClient(join([uri, '?type=algorithm']));
    waitfor(algorithm, 'id');
    algorithmId = algorithm.id;
    
    % Setup evaluator client
    if ischar(evaluate)
        evaluator = 0;
        evaluatorId = evaluate;
    else
        evaluator = EvaluatorClient(join([uri, '?type=evaluator']));
        waitfor(evaluator, 'id');
        evaluatorId = evaluator.id;
        evaluator.setEvaluate(evaluate);
    end
    
    
    % Init a new task
    newTask = struct('type', 'newTask', ...
        'algorithmId', algorithmId, 'evaluatorId', evaluatorId);
    algorithm.send(jsonencode(newTask));
    waitfor(algorithm, 'taskId');
    
    % Start the task
    startTask = struct('type', 'startTask', 'id', algorithm.taskId);
    algorithm.send(jsonencode(startTask));

    function Y = wrapped(X)
        point = struct('type', 'evaluate', 'data', X);
        algorithm.send(jsonencode(point));
        waitfor(algorithm, 'returned', 1);
        algorithm.returned = 0;
        Y = algorithm.currentY;
    end

    function disconnect()
        % Complete the task
        completeTask = struct('type', 'completeTask', 'id', algorithm.taskId);
        algorithm.send(jsonencode(completeTask));
        
        algorithm.close();
        if evaluator ~= 0
            evaluator.close();
        end
    end
    
    evaluateW = @wrapped;
    cleanUp = @disconnect;
end
