classdef Teeport < handle
    %Teeport Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        uri
        optimizer
        evaluator
        processors
    end
    
    methods
        function obj = Teeport(uri)
            %Constructor
            obj.uri = uri;
            obj.optimizer = [];
            obj.evaluator = [];
            obj.processors = {};
        end
        
        function evaluate = useEvaluator(obj, func)
            % Setup optimizer client
            if ~isobject(obj.optimizer)
                obj.optimizer = OptimizerClient(join([obj.uri, '?type=optimizer&private=True']));
                waitfor(obj.optimizer, 'id');
            end

            % Setup evaluator client
            if ischar(func)
                obj.evaluator = struct('id', func);
            else
                obj.evaluator = EvaluatorClient(join([obj.uri, '?type=evaluator&private=True']));
                waitfor(obj.evaluator, 'id');
                obj.evaluator.setEvaluate(func);
            end

            % Init a new task
            newTask = struct('type', 'newTask', ...
                'optimizerId', obj.optimizer.id, 'evaluatorId', obj.evaluator.id);
            obj.optimizer.send(jsonencode(newTask));
            waitfor(obj.optimizer, 'taskId');

            % Start the task
            startTask = struct('type', 'startTask', 'id', obj.optimizer.taskId);
            obj.optimizer.send(jsonencode(startTask));

            function Y = wrappedFunc(X)
                point = struct('type', 'evaluate', 'data', normalizeMatrixByJson(X));
                obj.optimizer.send(jsonencode(point));
                waitfor(obj.optimizer, 'returned', 1);
                if obj.optimizer.cancelled
                    obj.close();
                    error('task has been cancelled');
                end
                obj.optimizer.returned = 0;
                Y = obj.optimizer.currentY;
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
            % Setup optimizer client
            if ~isobject(obj.optimizer)
                obj.optimizer = OptimizerClient(join([obj.uri, '?type=optimizer&private=True']));
                waitfor(obj.optimizer, 'id');
            end

            % Setup processor client
            processor = [];
            if ischar(func)
                processor = struct('id', func);
                obj.processors{end + 1} = processor;
            else
                processor = ProcessorClient(join([obj.uri, '?type=processor&private=True']));
                waitfor(processor, 'id');
                processor.setProcess(func);
                obj.processors{end + 1} = processor;
            end

            function Y = wrappedFunc(X)
                point = struct('type', 'process', 'data', X, 'processorId', processor.id);
                obj.optimizer.send(jsonencode(point));
                waitfor(obj.optimizer, 'returned', 1);
                if obj.optimizer.cancelled
                    obj.close();
                    error('task has been cancelled');
                end
                obj.optimizer.returned = 0;
                Y = obj.optimizer.currentY;
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
            if isobject(obj.optimizer)
                completeTask = struct('type', 'completeTask', 'id', obj.optimizer.taskId);
                obj.optimizer.send(jsonencode(completeTask));
            end
            obj.close();
        end
        
        function close(obj)
            if isobject(obj.optimizer)
                obj.optimizer.close();
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
