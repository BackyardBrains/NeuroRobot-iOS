//
//  Brain_Brigde.cpp
//  Brain-Framework
//
//  Created by Djordje Jovic on 8/27/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#include "Brain_Brigde.hpp"
#include "../Brain.hpp"
#include <thread>

#ifdef __cplusplus
extern "C" {
#endif

const void* brain_Init()
{
    Brain* brain = new Brain();
    return brain;
}

const void brain_setVideoSize(const void* object, int width_, int height_)
{
    Brain* brainObject = (Brain*)object;
    brainObject->setVideoSize(width_, height_);
}

const void brain_load(const void* object, char* pathToMatFile_, int *error_)
{
    Brain* brainObject = (Brain*)object;
    brainObject->load(std::string(pathToMatFile_), error_);
}

const void brain_start(const void* object)
{
    Brain* brainObject = (Brain*)object;
    brainObject->start();
}

const void brain_stop(const void* object)
{
    Brain* brainObject = (Brain*)object;
    brainObject->stop();
}

const void brain_deinit(const void* object)
{
    Brain* brainObject = (Brain*)object;
    if (brainObject->isRunning) {
        brainObject->stop();
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(2000));
    
    delete brainObject;
}

const void brain_setDistance(const void* object, int distance)
{
    Brain* brainObject = (Brain*)object;
    brainObject->distance = distance;
}

const void brain_setVideo(const void* object, const uint8_t* videoFrame)
{
    Brain* brainObject = (Brain*)object;
    memcpy(brainObject->videoFrame, videoFrame, brainObject->cols * brainObject->rows * 3);
}

const void brain_setAudio(const void* object, const float* audioData, const int numberOfSamples, const int sampleRate)
{
    Brain* brainObject = (Brain*)object;
    brainObject->audioSampleRate = sampleRate;
    brainObject->audioData = std::vector<float>(audioData, audioData + numberOfSamples);
}

const double brain_getRightTorque(const void* object)
{
    Brain* brainObject = (Brain*)object;
    return brainObject->rightTorgue;
}

const double brain_getLeftTorque(const void* object)
{
    Brain* brainObject = (Brain*)object;
    return brainObject->leftTorgue;
}

const float brain_getSpeakerTone(const void* object)
{
    Brain* brainObject = (Brain*)object;
    return brainObject->speakerTone;
}

const double* brain_getNeuronValues(const void* object, int *numberOfNeurons)
{
    Brain* brainObject = (Brain*)object;
    double* neuronValues = new double[brainObject->numberOfNeurons];
    std::vector<Neuron*> neurons = brainObject->neurons;
    *numberOfNeurons = (int)brainObject->numberOfNeurons;
    
    for (int i = 0; i < brainObject->numberOfNeurons; i++) {
        auto neuron = neurons[i];
        neuronValues[i] = neuron->v;
    }
    
    return neuronValues;
}

const double** brain_getConnectToMe(const void* object, int *numberOfNeurons)
{
    Brain* brainObject = (Brain*)object;
    
    std::vector<Neuron*> neurons = brainObject->neurons;
    *numberOfNeurons = (int)brainObject->numberOfNeurons;
    
    const double** connections = new const double*[*numberOfNeurons];
    
    for (int i = 0; i < brainObject->numberOfNeurons; i++) {
        auto foo = new double[neurons[0]->connectToMe.size()];
        auto neuron = neurons[i];
        for (int j = 0; j < neuron->connectToMe.size(); j++) {
            auto connectToMe = neuron->connectToMe[j];
            foo[j] = connectToMe;
        }
        connections[i] = foo;
    }
    
    return connections;
}

const double** brain_getContacts(const void* object, int *numberOfNeurons, int *numberOfConnections)
{
    Brain* brainObject = (Brain*)object;
    
    std::vector<Neuron*> neurons = brainObject->neurons;
    *numberOfNeurons = (int)brainObject->numberOfNeurons;
    
    const double** connections = new const double*[*numberOfNeurons];
    
    for (int i = 0; i < brainObject->numberOfNeurons; i++) {
        auto foo = new double[neurons[0]->contacts.size()];
        auto neuron = neurons[i];
        
        for (int j = 0; j < neuron->contacts.size(); j++) {
            auto contact = neuron->contacts[j];
            foo[j] = contact;
        }
        connections[i] = foo;
        
        *numberOfConnections = (int)neuron->contacts.size();
    }
    
    return connections;
}

const double* brain_getX(const void* object, int *numberOfNeurons)
{
    Brain* brainObject = (Brain*)object;
    double* neuronValues = new double[brainObject->numberOfNeurons];
    std::vector<Neuron*> neurons = brainObject->neurons;
    *numberOfNeurons = (int)brainObject->numberOfNeurons;
    
    for (int i = 0; i < brainObject->numberOfNeurons; i++) {
        auto neuron = neurons[i];
        neuronValues[i] = neuron->x;
    }
    
    return neuronValues;
}

const double* brain_getY(const void* object, int *numberOfNeurons)
{
    Brain* brainObject = (Brain*)object;
    double* neuronValues = new double[brainObject->numberOfNeurons];
    std::vector<Neuron*> neurons = brainObject->neurons;
    *numberOfNeurons = (int)brainObject->numberOfNeurons;
    
    for (int i = 0; i < brainObject->numberOfNeurons; i++) {
        auto neuron = neurons[i];
        neuronValues[i] = neuron->y;
    }
    
    return neuronValues;
}

const bool* brain_getFiringNeurons(const void* object, int *numberOfNeurons)
{
    Brain* brainObject = (Brain*)object;
    bool* neuronValues = new bool[brainObject->numberOfNeurons];
    std::vector<Neuron*> neurons = brainObject->neurons;
    *numberOfNeurons = (int)brainObject->numberOfNeurons;
    
    for (int i = 0; i < brainObject->numberOfNeurons; i++) {
        auto neuron = neurons[i];
        neuronValues[i] = neuron->firing;
    }
    
    return neuronValues;
}

#ifdef __cplusplus
}
#endif
