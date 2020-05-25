//
//  Neurorobot-SwiftBridge.cpp
//  Neurorobot-Framework
//
//  Created by Djordje Jovic on 6/18/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#include "NeuroRobot-SwiftBridge.hpp"
#include "NeuroRobotManager.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    const long long swiftBridge_sizeOfVideoFrame(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        return robotObject->videoFrameBytes();
    }

    const int swiftBridge_videoWidth(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        return robotObject->videoWidth();
    }

    const int swiftBridge_videoHeight(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        return robotObject->videoHeight();
    }
    const unsigned int swiftBridge_audioSampleRate(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        return robotObject->audioSampleRate();
    }
    
    const void *swiftBridge_Init(char *ipAddress, char *port, short version, StreamErrorOccurredCallback streamCallback, SocketErrorOccurredCallback socketCallback)
    {
        std::string ipAddressString(ipAddress);
        std::string portString(port);
        
        NeuroRobotManager *robotObject = new NeuroRobotManager(ipAddressString, portString, version, streamCallback, socketCallback);
        
        return (void *)robotObject;
    }
    
    const void swiftBridge_start(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        robotObject->start();
    }
    
    const uint8_t *swiftBridge_readVideo(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        return robotObject->readVideoFrame();
    }
    
    const void swiftBridge_stop(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        robotObject->stop();
        
        delete robotObject;
    }
    
    const void *swiftBridge_readAudio(const void *object, size_t *totalBytes, unsigned short *bytesPerSample)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        void *audioData = robotObject->readAudio(totalBytes, bytesPerSample);
        
        return audioData;
    }
    
    const char *swiftBridge_readSerial(const void *object, size_t *totalBytes)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        char *serialData = robotObject->readSerial(totalBytes);
        
        return serialData;
    }
    
    const void swiftBridge_writeSerial(const void *object, char *message)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        robotObject->writeSerial(message);
    }
    
    const void swiftBridge_sendAudio(const void *object, int16_t *audioData, size_t numberOfBytes)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        robotObject->sendAudio(audioData, numberOfBytes);
    }

    const StreamStateType swiftBridge_readStreamState(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        return robotObject->readStreamState();
    }

    const SocketStateType swiftBridge_readSocketState(const void *object)
    {
        NeuroRobotManager *robotObject = (NeuroRobotManager *)object;
        return robotObject->readSocketState();
    }

#ifdef __cplusplus
}
#endif
