classdef NeuroRobot_matlab
    
    properties(GetAccess = 'private', SetAccess = 'private')
        mh matlab.mex.MexHost
    end
    
    methods
        % Constructor
        function robotObject = NeuroRobot_matlab(ipAddress, port)
%             if ~(isvalid(robotObject.mh))
                robotObject.mh = mexhost;
%                 this.mh.pro
%             end
            feval(robotObject.mh, "NeuroRobot_MatlabBridge", "init", ipAddress, port);
        end
        
        % Starts all threads
        function start(this)
            feval(this.mh, "NeuroRobot_MatlabBridge", "start");
        end
        
        % Reads last ~1sec of audio from shared memory
        function audioFrames = readAudio(this)
            audioFrames = feval(this.mh, "NeuroRobot_MatlabBridge", "readAudio");
        end
        
        % Reads current frame from shared memory
        function videoFrames = readVideo(this)
            videoFrames = feval(this.mh, "NeuroRobot_MatlabBridge", "readVideo");
        end
        
        % Stops all threads
        function stop(this)
            feval(this.mh, "NeuroRobot_MatlabBridge", "stop");
        end
        
        % Queries whether the video/audio thread is running
        function isRunning = isRunning(this)
            isRunning = feval(this.mh, "NeuroRobot_MatlabBridge", "isRunning");
        end
        
        % Writes serial data through socket
        function writeSerial(this, data)
            feval(this.mh, "NeuroRobot_MatlabBridge", "writeSerial", data);
        end
        
        % Reads all serial data from shared memory
        function data = readSerial(this)
            data = feval(this.mh, "NeuroRobot_MatlabBridge", "readSerial");
        end
        
        % Sends audio data through socket
        function sendAudio(this, fileName)
            [data, Fs] = audioread(fileName);
            
            % Change sample rate
            sampleRate = double(feval(this.mh, "NeuroRobot_MatlabBridge", "readAudioSampleRate"));
            if Fs ~= sampleRate
                [P,Q] = rat(sampleRate/Fs);
                data = resample(data, P, Q);
            end
            
            % Scale to 14bit
            data = int16(data * 8158);
            feval(this.mh, "NeuroRobot_MatlabBridge", "sendAudio", data);
        end
        
        % Sends audio data through socket
        function sendAudio2(this, data)
            % Scale to 14bit
            data = int16(data * 8158);
            feval(this.mh, "NeuroRobot_MatlabBridge", "sendAudio", data);
        end
        
        % Reads stream error
        function data = readStreamState(this)
            data = feval(this.mh, "NeuroRobot_MatlabBridge", "readStreamState");
        end
        
        % Reads socket error
        function data = readSocketState(this)
            data = feval(this.mh, "NeuroRobot_MatlabBridge", "readSocketState");
        end
        
        % Reads audio sample rate
        function data = readAudioSampleRate(this)
            data = feval(this.mh, "NeuroRobot_MatlabBridge", "readAudioSampleRate");
        end

        % Reads video width
        function data = readVideoWidth(this)
            data = feval(this.mh, "NeuroRobot_MatlabBridge", "readVideoWidth");
        end

        % Reads video height
        function data = readVideoHeight(this)
            data = feval(this.mh, "NeuroRobot_MatlabBridge", "readVideoHeight");
        end
    end
end

