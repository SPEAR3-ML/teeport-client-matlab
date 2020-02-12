function [evaluatorId, cleanUp] = evalWrapper(evaluate)
    uri = 'ws://zeta:8080/';
    
    % Setup evaluator client
    evaluator = EvaluatorClient(join([uri, '?type=evaluator']));
    waitfor(evaluator, 'id');
    evaluatorId = evaluator.id;
    evaluator.setEvaluate(evaluate);

    function disconnect()
        evaluator.close();
    end
    
    cleanUp = @disconnect;
end
