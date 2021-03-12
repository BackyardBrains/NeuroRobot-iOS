//
//  Neurorobot-SwiftBridge.hpp
//  Neurorobot-Framework
//
//  Created by Djordje Jovic on 6/18/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#ifndef NeuroRobot_SwiftBridge_hpp
#define NeuroRobot_SwiftBridge_hpp

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "TypeDefs.h"

    const long long swiftBridge_sizeOfVideoFrame(const void *object);
    const int swiftBridge_videoWidth(const void *object);
    const int swiftBridge_videoHeight(const void *object);
    const unsigned int swiftBridge_audioSampleRate(const void *object);

    const void *swiftBridge_Init(char *ipAddress, char *port, short version, StreamErrorOccurredCallback streamCallback, SocketErrorOccurredCallback socketCallback);
    const void swiftBridge_start(const void *object);
    const uint8_t *swiftBridge_readVideo(const void *object);
    const void swiftBridge_stop(const void *object);
    const void *swiftBridge_readAudio(const void *object, size_t *totalBytes, unsigned short *bytesPerSample);
    const char *swiftBridge_readSerial(const void *object, size_t *totalBytes);
    
    const void swiftBridge_writeSerial(const void *object, char *message);
    const void swiftBridge_sendAudio(const void *object, int16_t *audioData, size_t numberOfBytes);

    const StreamStateType swiftBridge_readStreamState(const void *object);
    const SocketStateType swiftBridge_readSocketState(const void *object);
    
#ifdef __cplusplus
}
#endif


#endif /* NeuroRobot_SwiftBridge_hpp */
