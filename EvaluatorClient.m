classdef EvaluatorClient < WebSocketClient
    %CLIENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        evaluate
    end
    
    methods
        function obj = EvaluatorClient(varargin)
            %Constructor
            obj@WebSocketClient(varargin{:});
            obj.id = '';
            obj.evaluate = [];
        end
        
        function setEvaluate(obj, evaluate)
            obj.evaluate = evaluate;
        end
    end
    
    methods (Access = protected)
        function onOpen(obj,message)
            % This function simply displays the message received
            fprintf('%s\n',message);
        end
        
        function onTextMessage(obj,message)
            % Blabla
            msg = jsondecode(message);
            if strcmp(msg.type,'hello')
                obj.id = msg.id;
            elseif strcmp(msg.type,'evaluate')
                taskId = msg.taskId;
                X = msg.data;
                Y = obj.evaluate(X);
                
                res = struct('type', 'evaluated', 'taskId', taskId, 'data', normalizeMatrixByJson(Y));
                obj.send(jsonencode(res));
            else
                fprintf('%s\n',message);
            end
        end
        
        function onBinaryMessage(obj,bytearray)
            % This function simply displays the message received
            fprintf('Binary message received:\n');
            fprintf('Array length: %d\n',length(bytearray));
        end
        
        function onError(obj,message)
            % This function simply displays the message received
            fprintf('Error: %s\n',message);
        end
        
        function onClose(obj,message)
            % This function simply displays the message received
            fprintf('%s\n',message);
        end
    end
end

