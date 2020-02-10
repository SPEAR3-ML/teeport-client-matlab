function w_evaluate = wrapper(evaluate)
    uri = 'ws://zeta:8080';
    algorithm = AlgorithmClient(uri);
    evaluator = EvaluatorClient(uri);
    evaluator.setEvaluate(evaluate);
    info = struct('gen', 0);

    function Y = wrapped(X)
        point = struct('type', 'evaluate', ...
            'taskId', '0', ...
            'gen', info.gen, ...
            'data', X);
        algorithm.send(jsonencode(point));
        waitfor(algorithm, 'returned', 1);
        algorithm.returned = 0;
        info.gen = info.gen + 1;
        Y = algorithm.current_Y;
    end
    
    w_evaluate = @wrapped;
end
