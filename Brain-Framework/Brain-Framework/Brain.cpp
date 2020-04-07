//
//  Brain.cpp
//  Brain-Framework
//
//  Created by Djordje Jovic on 8/17/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#include "Brain.hpp"
#include <iostream>
#include <matio.h>
#include <opencv2/opencv.hpp>
#include <iomanip>
#include <string>
#include <map>
#include <random>
#include <cmath>
#include <thread>
#include <numeric>
#include "AudioProcessing.cpp"
#include "Math/MathFunctions.hpp"

// MARK:-
typedef enum : int {
    ColorRed = 0,
    ColorGreen,
    ColorBlue
} Color;

// MARK:-
class Score {
public:
    Score() {}

    double thisScore;
    double temporalScore;
};

// MARK:- Interface
std::vector<Neuron*> parseNeurons(matvar_t* brainStruct);
void timerStart(std::function<void(Brain*)> func, Brain* brain);
void simulateNextIteration(Brain* brain);
void updateBrain(Brain* brain);
void processVisualInput(Brain* brain);
void processAudioInput(Brain* brain);
Score calculateScore(Color color, cv::Mat frame, int nCam);
void updateMotors(Brain* brain);

// MARK:- Implementation
Brain::Brain()
{
    
}

void Brain::setVideoSize(int width_, int height_)
{
    cols = width_;
    rows = height_;
}

void Brain::load(std::string filePath_, int* error_)
{
    if (isRunning) {
        stop();
    }
    
    mat_t* matfp = Mat_Open(filePath_.c_str(), MAT_ACC_RDONLY);

    matvar_t* matvar = Mat_VarReadNextInfo(matfp);
    int read_err = Mat_VarReadDataAll(matfp, matvar);
    *error_ = read_err;
    if (read_err == 0) {
        std::cout << "loaded brain: " + filePath_ << std::endl;
        matvar_t* fooMatvar;

        // Parse brain data
        fooMatvar = Mat_VarGetStructFieldByName(matvar, "nneurons", 0);
        numberOfNeurons = ((double*)fooMatvar->data)[0];
        fooMatvar = Mat_VarGetStructFieldByName(matvar, "a_init", 0);
        aInit = ((double*)fooMatvar->data)[0];
        fooMatvar = Mat_VarGetStructFieldByName(matvar, "b_init", 0);
        bInit = ((double*)fooMatvar->data)[0];
        fooMatvar = Mat_VarGetStructFieldByName(matvar, "c_init", 0);
        cInit = ((double*)fooMatvar->data)[0];
        fooMatvar = Mat_VarGetStructFieldByName(matvar, "d_init", 0);
        dInit = ((double*)fooMatvar->data)[0];
        fooMatvar = Mat_VarGetStructFieldByName(matvar, "w_init", 0);
        wInit = ((double*)fooMatvar->data)[0];

        // Parse neuron data
        neurons = parseNeurons(matvar);

        Mat_Close(matfp);

        std::random_device rd{};
        std::mt19937 gen{ rd() };
        std::normal_distribution<double> distribution(0.0, 1.0);

        for (int i = 0; i < numberOfNeurons; ++i) {
            double randomNumber = distribution(gen);

            neurons[i]->v = neurons[i]->c + 5 * randomNumber;
            neurons[i]->u = neurons[i]->b * neurons[i]->v;

            neurons[i]->spikesStep = std::vector<double>(msPerStep, 0);
            neurons[i]->iStep = std::vector<double>(msPerStep, 0);
        }
        
        spikesLoop = std::vector<std::vector<double> >(numberOfNeurons, std::vector<double>(msPerStep * nStepsPerLoop, 0));
        visPrefVals = std::vector<std::vector<double> >(neurons[0]->visPref.size(), std::vector<double>(2, 0));
    }
}

std::vector<Neuron*> parseNeurons(matvar_t* brainStruct)
{
    std::vector<Neuron*> neurons;
    matvar_t* fooMatvar;
    fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "nneurons", 0);
    if (fooMatvar != NULL) {
        double numberOfNeurons = ((double*)fooMatvar->data)[0];

        for (int i = 0; i < numberOfNeurons; i++) {
            Neuron* neuron = new Neuron();

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "a", 0);
            neuron->a = ((double*)fooMatvar->data)[i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "b", 0);
            neuron->b = ((double*)fooMatvar->data)[i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "c", 0);
            neuron->c = ((double*)fooMatvar->data)[i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "d", 0);
            neuron->d = ((double*)fooMatvar->data)[i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "neuron_xys", 0);
            size_t nRow = fooMatvar->dims[0];
            neuron->x = ((double*)fooMatvar->data)[i];
            neuron->y = ((double*)fooMatvar->data)[nRow + i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "neuron_contacts", 0);
            for (int j = i; j < fooMatvar->dims[1] * numberOfNeurons; j = j + numberOfNeurons) {
                neuron->contacts.push_back(((double*)fooMatvar->data)[j]);
            }

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "connectome", 0);
            for (int j = i; j < fooMatvar->dims[1] * numberOfNeurons; j = j + numberOfNeurons) {
                neuron->connectToMe.push_back(((double*)fooMatvar->data)[j]);
            }

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "neuron_cols", 0);
            for (int j = i; j < fooMatvar->dims[1] * numberOfNeurons; j = j + numberOfNeurons) {
                neuron->color.push_back(((double*)fooMatvar->data)[j]);
            }

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "audio_prefs", 0);
            if (fooMatvar != NULL) {
                neuron->audioPref = ((double*)fooMatvar->data)[i];
            }

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "neuron_tones", 0);
            if (fooMatvar != NULL) {
                neuron->tone = ((double*)fooMatvar->data)[i];
            }

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "da_connectome", 0);
            for (int k = i; k < numberOfNeurons * fooMatvar->dims[1]; k = k + numberOfNeurons) {
                std::vector<double> connectToMeVector;
                for (int j = k; j < numberOfNeurons * fooMatvar->dims[1] * fooMatvar->dims[2]; j = j + numberOfNeurons * fooMatvar->dims[1]) {
                    connectToMeVector.push_back(((double*)fooMatvar->data)[j]);
                }
                neuron->daConnecToMe.push_back(connectToMeVector);
            }

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "vis_prefs", 0);
            for (int k = i; k < numberOfNeurons * fooMatvar->dims[1]; k = k + numberOfNeurons) {
                std::vector<bool> visPrefsVector;
                for (int j = k; j < numberOfNeurons * fooMatvar->dims[1] * fooMatvar->dims[2]; j = j + numberOfNeurons * fooMatvar->dims[1]) {
                    visPrefsVector.push_back(((bool*)fooMatvar->data)[j]);
                }
                neuron->visPref.push_back(visPrefsVector);
            }

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "dist_prefs", 0);
            neuron->distPref = ((double*)fooMatvar->data)[i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "network_ids", 0);
            neuron->networkId = ((double*)fooMatvar->data)[i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "da_rew_neurons", 0);
            neuron->daRewNeuron = ((double*)fooMatvar->data)[i];

            fooMatvar = Mat_VarGetStructFieldByName(brainStruct, "bg_neurons", 0);
            neuron->bgNeuron = ((double*)fooMatvar->data)[i];

            // Neuron Tones

            // Spikes Loop
            // Network drive

            neurons.push_back(neuron);
        }
    }

    return neurons;
}

void Brain::start()
{
    if (isRunning) {
        return;
    }
    
    videoFrame = new uint8_t[cols * rows * 3];

    isRunning = true;
    timerStart(simulateNextIteration, this);
}

void Brain::stop()
{
    isRunning = false;
}

void timerStart(std::function<void(Brain*)> func, Brain* brain)
{
    std::thread([func, brain]() {
        while (brain->isRunning) {
            func(brain);
            std::this_thread::sleep_for(std::chrono::milliseconds((long long)brain->nStepsPerLoop));
        }
    }).detach();
}

void simulateNextIteration(Brain* brain)
{
    updateBrain(brain);
    updateMotors(brain);
    processVisualInput(brain);
    processAudioInput(brain);
}

void updateBrain(Brain* brain)
{
    for (int i = 0; i < brain->numberOfNeurons; i++) {
        Neuron* neuron = brain->neurons[i];
        neuron->visI = 0;
        neuron->distI = 0;
        neuron->audioI = 0;
        for (int t = 0; t < brain->msPerStep; t++) {
            neuron->spikesStep[t] = 0;
            neuron->iStep[t] = 0;
        }
    }

    for (int i = 0; i < brain->numberOfNeurons; i++) {
        Neuron* neuron = brain->neurons[i];
        
        // Calculate visual input current
        for (int ncam = 0; ncam < 2; ncam++) {
            double sum = 0;
            for (int t = 0; t < neuron->visPref.size(); t++) {
                if (neuron->visPref[t][ncam]) {
                    sum += brain->visPrefVals[t][ncam];
                }
            }
            neuron->visI = neuron->visI + sum;
        }
    }

    for (int i = 0; i < brain->numberOfNeurons; i++) {
        Neuron* neuron = brain->neurons[i];

        // Calculate distance sensor input current
        if (neuron->distPref == 1 || neuron->distPref == 2 || neuron->distPref == 3) {

            double factor = 0;

            if (neuron->distPref == 1) {
                factor = 1000;
            } else if (neuron->distPref == 2) {
                factor = 2000;
            } else if (neuron->distPref == 3) {
                factor = 3000;
            }

            neuron->distI = MathFunctions::sigmoid(brain->distance, factor, -0.8) * 50;
        }
    }

    for (int i = 0; i < brain->numberOfNeurons; i++) {
        Neuron* neuron = brain->neurons[i];

        // Calculate audio input current
        if (neuron->audioPref == 1 || neuron->audioPref == 2 || neuron->audioPref == 3) {

            if ((neuron->audioPref == 1 && brain->audioMaxFreq > 200 && brain->audioMaxFreq < 400) ||
                (neuron->audioPref == 2 && brain->audioMaxFreq > 500 && brain->audioMaxFreq < 700) ||
                (neuron->audioPref == 3 && brain->audioMaxFreq > 1100 && brain->audioMaxFreq < 1300)) {

                neuron->audioI = 50;
            }
        }
    }

    std::random_device rd{};
    std::mt19937 gen { rd() };
    std::normal_distribution<double> distribution(0.0, 1.0);

    // Run brain simulation
    for (int t = 0; t < brain->msPerStep; t++) {
        
        for (int i = 0; i < brain->numberOfNeurons; i++) {
            Neuron* neuron = brain->neurons[i];
            
            // Add noise
            double randomNumber = distribution(gen);
            neuron->I = 5 * randomNumber;
        }
        
        for (int i = 0; i < brain->numberOfNeurons; i++) {
            Neuron* neuron = brain->neurons[i];
            
            // Find spiking neurons
            if (neuron->v >= 30) {
                neuron->spikesStep[t] = 1;
                
                // Reset spiking v to c
                neuron->v = neuron->c;
                
                // Adjust spiking u to d
                neuron->u = neuron->u + neuron->d;
                
                // Add spiking synaptic weights to neuronal inputs
                for (int k = 0; k < brain->numberOfNeurons; k++) {
                    Neuron* neuron2 = brain->neurons[k];
                    neuron2->I = neuron2->I + neuron->connectToMe[k];
                }
            }
        }
        
        for (int i = 0; i < brain->numberOfNeurons; i++) {
            Neuron* neuron = brain->neurons[i];
            
            // Add sensory input currents
            neuron->I = neuron->I + neuron->visI + neuron->distI + neuron->audioI;
            neuron->iStep[t] = neuron->I;
            
            // Update v
            neuron->v = neuron->v + 0.5 * (0.04 * std::pow(neuron->v, 2) + 5 * neuron->v + 140 - neuron->u + neuron->I);
            neuron->v = neuron->v + 0.5 * (0.04 * std::pow(neuron->v, 2) + 5 * neuron->v + 140 - neuron->u + neuron->I);
            
            // Update u
            neuron->u = neuron->u + neuron->a * (neuron->b * neuron->v - neuron->u);
            
            // Avoid nans
            if (std::isnan(neuron->v)) {
                neuron->v = neuron->c;
            }
        }
    }

    for (int i = 0; i < brain->numberOfNeurons; i++) {
        Neuron* neuron = brain->neurons[i];

        int sum = 0;
        for (auto& n : neuron->spikesStep) {
            sum += n;
        }

        neuron->firing = sum > 0 ? true : false;
    }
}

void processVisualInput(Brain* brain)
{
    if (brain->videoFrame != 0) {

        cv::Size netInputSize(brain->colsResized, brain->rowsResized);

        int y = 0;
        int size = brain->rows;
        
        if (brain->rows > brain->cols) {
            size = (int)((float)brain->cols * 0.8);
            y = (brain->rows - size) / 2;
        }
        
        cv::Rect left_cut(0, y, size, size);
        cv::Rect right_cut(brain->cols - size, y, size, size);
        int sizes[] = { brain->rows, brain->cols };
        cv::Mat imageMat(2, sizes, CV_8UC3, brain->videoFrame);

        //        cv::imshow("display", imageMat);

        for (int nCam = 0; nCam < 2; nCam++) {

            cv::Mat bigFrame(brain->rows, brain->rows, CV_8UC3);
            
            cv::Mat frame;

            if (nCam == 0) {
                bigFrame = imageMat(left_cut);
            } else {
                bigFrame = imageMat(right_cut);
            }

            cv::resize(bigFrame, frame, netInputSize);

            auto scoreRed = calculateScore(ColorRed, frame, nCam);

            brain->visPrefVals[0][nCam] = scoreRed.thisScore;
            brain->visPrefVals[1][nCam] = scoreRed.temporalScore;

            auto scoreGreen = calculateScore(ColorGreen, frame, nCam);

            brain->visPrefVals[2][nCam] = scoreGreen.thisScore;
            brain->visPrefVals[3][nCam] = scoreGreen.temporalScore;

            auto scoreBlue = calculateScore(ColorBlue, frame, nCam);

            brain->visPrefVals[4][nCam] = scoreBlue.thisScore;
            brain->visPrefVals[5][nCam] = scoreBlue.temporalScore;
        }
    }
}

void processAudioInput(Brain* brain)
{
    if (brain->audioData.size() > 0) {
        float maxAmp = 0;
        float maxFreq = 0;
        calculateMaxAmpAndFreq(brain->audioData, brain->audioSampleRate, &maxAmp, &maxFreq);
        brain->audioMaxFreq = maxFreq;
        brain->max_amp = maxAmp;
    }
}

Score calculateScore(Color color, cv::Mat frame, int nCam)
{
    Score score = Score();

    cv::Mat boolMat(frame.rows, frame.cols, CV_8UC1);
    boolMat = boolMat.zeros(frame.rows, frame.cols, CV_8UC1);

    int firstIndex = 0;
    int secondIndex = 1;
    int thirdIndex = 2;
    double multiplier = 2;

    if (color == ColorRed) {
        firstIndex = 0;
        secondIndex = 1;
        thirdIndex = 2;
        multiplier = 2;
    } else if (color == ColorGreen) {
        firstIndex = 1;
        secondIndex = 0;
        thirdIndex = 2;
        multiplier = 1.5;
    } else if (color == ColorBlue) {
        firstIndex = 2;
        secondIndex = 1;
        thirdIndex = 0;
        multiplier = 1.5;
    }

    for (int i = 0; i < frame.rows; i++) {
        for (int j = 0; j < frame.cols; j++) {
            if ((frame.at<cv::Vec3b>(i, j)[firstIndex] > frame.at<cv::Vec3b>(i, j)[secondIndex] * multiplier && frame.at<cv::Vec3b>(i, j)[firstIndex] > frame.at<cv::Vec3b>(i, j)[thirdIndex] * multiplier) && frame.at<cv::Vec3b>(i, j)[firstIndex] > 50) {
                boolMat.at<bool>(i, j) = true;
            }
        }
    }

    cv::Mat blob(frame.rows, frame.cols, CV_8UC1);
    int totalNumberOfLabels = cv::connectedComponents(boolMat, blob);

    if (totalNumberOfLabels > 0) {
        std::vector<int> sumPerCells(totalNumberOfLabels, 0);
        for (int i = 0; i < blob.rows; i++) {
            for (int j = 0; j < blob.cols; j++) {
                if (blob.at<int>(i, j) != 0 && blob.at<int>(i, j) < sumPerCells.size()) {
                    sumPerCells[blob.at<int>(i, j)] += 1;
                }
            }
        }

        auto maxElementIndex = std::max_element(sumPerCells.begin(), sumPerCells.end()) - sumPerCells.begin();
        auto npx = *std::max_element(sumPerCells.begin(), sumPerCells.end());

        std::vector<float> x;
        std::vector<int> y;

        for (int i = 0; i < blob.rows; i++) {
            for (int j = 0; j < blob.cols; j++) {
                if (blob.at<int>(i, j) == maxElementIndex) {
                    y.push_back(i);
                    x.push_back(j);
                }
            }
        }

        score.thisScore = MathFunctions::sigmoid(npx, 1000, 0.01) * 50;
        
        auto mean = MathFunctions::mean(x);

        if (nCam == 0) {
            score.temporalScore = MathFunctions::sigmoid(((227 - mean) / 227), 0.95, 5) * score.thisScore;
        } else if (nCam == 1) {
            score.temporalScore = MathFunctions::sigmoid((mean / 227), 0.95, 5) * score.thisScore;
        }

    } else {
        score.thisScore = 0;
        score.temporalScore = 0;
    }

    return score;
}

void updateMotors(Brain* brain)
{
    std::vector<double> motorCommand(4);

    double left_forward = 0;
    double right_forward = 0;
    double left_backward = 0;
    double right_backward = 0;

    double left_dir = 0;
    double left_torque = 0;
    double right_dir = 0;
    double right_torque = 0;
    
    double maxTorque = 250;
    double minTorque = 120;

    for (int i = 0; i < brain->numberOfNeurons; i++) {
        Neuron* neuron = brain->neurons[i];

        if (neuron->firing) {
            left_forward = left_forward + (neuron->contacts[5] + neuron->contacts[7]) / 2;
            right_forward = right_forward + (neuron->contacts[9] + neuron->contacts[11]) / 2;
            left_backward = left_backward + (neuron->contacts[6] + neuron->contacts[8]) / 2;
            right_backward = right_backward + (neuron->contacts[10] + neuron->contacts[12]) / 2;
        }
    }

    left_torque = left_forward - left_backward;

    left_dir = MathFunctions::sign(left_torque);
    left_torque = abs(left_torque);
    if (left_torque > maxTorque) {
        left_torque = maxTorque;
    }
    brain->leftTorgue = left_torque * left_dir;

    right_torque = right_forward - right_backward;
    right_dir = MathFunctions::sign(right_torque);
    right_torque = abs(right_torque);
    if (right_torque > maxTorque) {
        right_torque = maxTorque;
    }
    brain->rightTorgue = right_torque * right_dir;

    std::cout << "leftTorque: " << brain->leftTorgue << "\trightTorque: " << brain->rightTorgue << std::endl;
    
    std::vector<float> theseTones;
    for (int i = 0; i < brain->numberOfNeurons; i++) {
        Neuron* neuron = brain->neurons[i];
        
        if (neuron->contacts[3] > 0 && neuron->firing && neuron->tone != 0) {
            theseTones.push_back((float)neuron->tone);
        }
    }
    
    brain->speakerTone = MathFunctions::mean(theseTones);
    
    std::cout << "speaker frequency: " << brain->speakerTone << std::endl;
    
}
