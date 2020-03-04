classdef OptimizerClient < WebSocketClient
    %CLIENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id
        taskId
        returned
        cancelled
        currentY
    end
    
    methods
        function obj = OptimizerClient(varargin)
            %Constructor
            obj@WebSocketClient(varargin{:});
            obj.id = '';
            obj.taskId = '';
            obj.returned = 0;
            obj.cancelled = 0;
            obj.currentY = [];
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
            elseif strcmp(msg.type,'taskCreated')
                obj.taskId = msg.id;
            elseif strcmp(msg.type,'evaluated')
                Y = msg.data;
                obj.currentY = Y;
                obj.returned = 1;
            elseif strcmp(msg.type,'stopTask')
                obj.returned = 1;
                obj.cancelled = 1;
            elseif strcmp(msg.type,'processed')
                Y = msg.data;
                obj.currentY = Y;
                obj.returned = 1;
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

