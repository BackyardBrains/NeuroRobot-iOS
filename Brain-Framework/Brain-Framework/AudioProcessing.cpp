//
//  AudioProcessing.cpp
//  iOS_Brain-Framework
//
//  Created by Djordje Jovic on 17/11/2019.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#ifndef AudioProcessing_cpp
#define AudioProcessing_cpp

//#include <iostream>
#include <stdio.h>
#include <iostream>
#include <vector>
#include <math.h>
#include "Math/MathFunctions.hpp"

static void calculateMaxAmpAndFreq(std::vector<float> audioData, int sampleRate, float *maxAmp, float *maxFreq)
{
    if (audioData.size() >= 1024) {
        float fs = (float)sampleRate;
        
        // Get first 1024 samples, it has to be 2^n.
        std::vector<float> x(audioData.begin(), audioData.begin() + 1024);
        
        // Get spectrum
        std::vector<float> y = MathFunctions::fft(x);
        float n = y.size();
        if (y.size()) {
            
            std::vector<float> pw(n);
            std::vector<float> fx(n);
            float fs_n = fs / n;
            for (int i = 0; i < n; i++) {
                float pw_ = pow(y[i], 2) / n;
                pw[i] = pw_;
                
                fx[i] = i * fs_n;
            }
            
            // Convert to Z scores
            float meanPW = MathFunctions::mean(pw);
            float standardDeviation = MathFunctions::calculateSD(pw);
            for (int i = 0; i < n; i++) {
                pw[i] = (pw[i] - meanPW) / standardDeviation;
            }
            
            // Get amp and freq
            long j = std::max_element(pw.begin(), pw.end()) - pw.begin();
            float fooAmp = *std::max_element(pw.begin(), pw.end());
            *maxAmp = fooAmp;
            *maxFreq = fx[j];
            
            printf("max amp: %lf\n", *maxAmp);
            printf("max freq: %lf\n", *maxFreq);
        }
    }
}

#endif /* AudioProcessing_cpp */
