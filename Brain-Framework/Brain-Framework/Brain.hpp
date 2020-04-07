//
//  Brain.hpp
//  Brain-Framework
//
//  Created by Djordje Jovic on 8/17/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#ifndef Brain_hpp
#define Brain_hpp

#include <stdio.h>
#include <iostream>
#include <vector>
#include "Neuron.hpp"
#include <cmath>

class Brain
{
public:
    
    // Brain data
    double numberOfNeurons;
    double aInit;
    double bInit;
    double cInit;
    double dInit;
    double wInit;
    double pulsePeriod = 0.125;
    double msPerStep = round(pulsePeriod * 1000);
    double nStepsPerLoop = 100;
    std::vector<std::vector<double>> spikesLoop;
    
    std::vector<std::vector<double>> visPrefVals;

    // Other data
    bool isRunning = false;
    
    void setVideoSize(int width_, int height_);
    void load(std::string filePath, int *error);
//public:
    std::vector<Neuron*> neurons;
    
    Brain();
    
    void start();
    void stop();
    
    int cols = 1920;
    int rows = 1080;
    int rowsResized = 227;
    int colsResized = 227;
    
    uint8_t *videoFrame = NULL;
    std::vector<float> audioData;
    
    int distance = 0;
    
    double leftTorgue = 0;
    double rightTorgue = 0;
    float speakerTone = 0;
    int audioSampleRate = 0;
    
    float audioMaxFreq = 0;
    float max_amp = 0;
    
};

#endif /* Brain_hpp */
