classdef Platform < handle
    %Platform Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        uri
        algorithm
        evaluator
        processors
    end
    
    methods
        function obj = Platform(uri)
            %Constructor
            obj.uri = uri;
            obj.algorithm = [];
            obj.evaluator = [];
            obj.processors = {};
        end
        
        function evaluate = useEvaluator(obj, func)
            % Setup algorithm client
            if ~isobject(obj.algorithm)
                obj.algorithm = AlgorithmClient(join([obj.uri, '?type=algorithm']));
                waitfor(obj.algorithm, 'id');
            end

            % Setup evaluator client
            if ischar(func)
                obj.evaluator = struct('id', func);
            else
                obj.evaluator = EvaluatorClient(join([obj.uri, '?type=evaluator']));
                waitfor(obj.evaluator, 'id');
                obj.evaluator.setEvaluate(func);
            end

            % Init a new task
            newTask = struct('type', 'newTask', ...
                'algorithmId', obj.algorithm.id, 'evaluatorId', obj.evaluator.id);
            obj.algorithm.send(jsonencode(newTask));
            waitfor(obj.algorithm, 'taskId');

            % Start the task
            startTask = struct('type', 'startTask', 'id', obj.algorithm.taskId);
            obj.algorithm.send(jsonencode(startTask));

            function Y = wrappedFunc(X)
                point = struct('type', 'evaluate', 'data', X);
                obj.algorithm.send(jsonencode(point));
                waitfor(obj.algorithm, 'returned', 1);
                if obj.algorithm.cancelled
                    obj.close();
                    error('task has been cancelled');
                end
                obj.algorithm.returned = 0;
                Y = obj.algorithm.currentY;
            end

            evaluate = @wrappedFunc;
        end
        
        function evaluatorId = runEvaluator(obj, func)
            % Setup evaluator client
            obj.evaluator = EvaluatorClient(join([obj.uri, '?type=evaluator']));
            waitfor(obj.evaluator, 'id');
            obj.evaluator.setEvaluate(func);
            evaluatorId = obj.evaluator.id;
        end
        
        function process = useProcessor(obj, func)
            % Setup algorithm client
            if ~isobject(obj.algorithm)
                obj.algorithm = AlgorithmClient(join([obj.uri, '?type=algorithm']));
                waitfor(obj.algorithm, 'id');
            end

            % Setup processor client
            processor = [];
            if ischar(func)
                processor = struct('id', func);
                obj.processors{end + 1} = processor;
            else
                processor = ProcessorClient(join([obj.uri, '?type=processor']));
                waitfor(processor, 'id');
                processor.setProcess(func);
                obj.processors{end + 1} = processor;
            end

            function Y = wrappedFunc(X)
                point = struct('type', 'process', 'data', X, 'processorId', processor.id);
                obj.algorithm.send(jsonencode(point));
                waitfor(obj.algorithm, 'returned', 1);
                if obj.algorithm.cancelled
                    obj.close();
                    error('task has been cancelled');
                end
                obj.algorithm.returned = 0;
                Y = obj.algorithm.currentY;
            end

            process = @wrappedFunc;
        end
        
        function processorId = runProcessor(obj, func)
            % Setup processor client
            processor = ProcessorClient(join([obj.uri, '?type=processor']));
            waitfor(processor, 'id');
            processor.setProcess(func);
            obj.processors{end + 1} = processor;
            processorId = processor.id;
        end
        
        function cleanUp(obj)
            completeTask = struct('type', 'completeTask', 'id', obj.algorithm.taskId);
            obj.algorithm.send(jsonencode(completeTask));
            obj.close();
        end
        
        function close(obj)
            if isobject(obj.algorithm)
                obj.algorithm.close();
            end
            if isobject(obj.evaluator)
                obj.evaluator.close();
            end
            for processor = obj.processors
                if isobject(processor{1})
                    processor{1}.close();
                end
            end
        end
    end
end
