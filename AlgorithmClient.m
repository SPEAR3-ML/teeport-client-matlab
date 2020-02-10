classdef AlgorithmClient < WebSocketClient
    %CLIENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        returned
        current_Y
    end
    
    methods
        function obj = AlgorithmClient(varargin)
            %Constructor
            obj@WebSocketClient(varargin{:});
            obj.returned = 0;
            obj.current_Y = [];
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
            if msg.type == 'evaluated'
                Y = msg.data;
                obj.current_Y = Y;
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

