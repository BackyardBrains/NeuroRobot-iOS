//
//  Brain_Brigde.hpp
//  Brain-Framework
//
//  Created by Djordje Jovic on 8/27/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#ifndef Brain_Brigde_hpp
#define Brain_Brigde_hpp

#ifdef __cplusplus
extern "C" {
#endif
#include <stdint.h>
#include <stdbool.h>

const void* brain_Init();
const void brain_setVideoSize(const void* object, int width_, int height_);
const void brain_load(const void* object, char* pathToMatFile_, int *error_);
const void brain_start(const void* object);
const void brain_stop(const void* object);
const void brain_setDistance(const void* object, int distance);
const void brain_setVideo(const void* object, const uint8_t* videoFrame);
const void brain_setAudio(const void* object, const float* audioData, const int numberOfSamples, const int sampleRate);
const double brain_getRightTorque(const void* object);
const double brain_getLeftTorque(const void* object);
const float brain_getSpeakerTone(const void* object);
const double* brain_getNeuronValues(const void* object, int *numberOfNeurons);
const bool* brain_getFiringNeurons(const void* object, int *numberOfNeurons);
const void brain_deinit(const void* object);

const double** brain_getConnectToMe(const void* object, int *numberOfNeurons);
const double** brain_getContacts(const void* object, int *numberOfNeurons, int *numberOfConnections);
const double* brain_getX(const void* object, int *numberOfNeurons);
const double* brain_getY(const void* object, int *numberOfNeurons);

#ifdef __cplusplus
}
#endif

#endif /* Brain_Brigde_hpp */
