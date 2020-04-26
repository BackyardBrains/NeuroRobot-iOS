//
//  BrainWorker.cpp
//  Brain-Framework
//
//  Created by Djordje Jovic on 14/04/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

#include "BrainWorker.hpp"
#include <random>
#include <thread>

#include "AudioProcessing.cpp"
#include "Math/MathFunctions.hpp"

BrainWorker::~BrainWorker()
{
    if (whileLoopIsRunning) {
        semaphore.wait();
    }
}

int BrainWorker::load(std::string filePath_)
{
    if (isRunning) {
        stop();
    }
    
    return brain.load(filePath_, msPerStep, nStepsPerLoop);
}

void BrainWorker::setVideoSize(int width_, int height_)
{
    cols = width_;
    rows = height_;
}

//MARK:- Simulation
void BrainWorker::start()
{
    if (isRunning) {
        return;
    }
    
    videoFrame = new uint8_t[cols * rows * 3];
    
    isRunning = true;
    
    std::thread simulationThread(&BrainWorker::simulateNextIteration, this);
    simulationThread.detach();
}

void BrainWorker::stop()
{
    isRunning = false;
}

void BrainWorker::simulateNextIteration()
{
    whileLoopIsRunning = true;
    while (isRunning) {
        
        updateBrain();
        updateMotors();
        processVisualInput();
        processAudioInput();
        
        std::this_thread::sleep_for(std::chrono::milliseconds((long long)nStepsPerLoop));
        semaphore.signal();
    }
    whileLoopIsRunning = false;
}

void BrainWorker::updateBrain()
{
    for (int i = 0; i < brain.numberOfNeurons; i++) {
        Neuron & neuron = brain.neurons[i];
        
        neuron.visI = 0;
        neuron.distI = 0;
        neuron.audioI = 0;
        for (int t = 0; t < msPerStep; t++) {
            neuron.spikesStep[t] = 0;
            neuron.iStep[t] = 0;
        }
    }
    
    for (int i = 0; i < brain.numberOfNeurons; i++) {
        Neuron & neuron = brain.neurons[i];
        
        // Calculate visual input current
        for (int ncam = 0; ncam < 2; ncam++) {
            double sum = 0;
            for (int t = 0; t < neuron.visPref.size(); t++) {
                if (neuron.visPref[t][ncam]) {
                    sum += brain.visPrefVals[t][ncam];
                }
            }
            neuron.visI = neuron.visI + sum;
        }
    }
    
    for (int i = 0; i < brain.numberOfNeurons; i++) {
        Neuron & neuron = brain.neurons[i];
        
        // Calculate distance sensor input current
        if (neuron.distPref == 1 || neuron.distPref == 2 || neuron.distPref == 3) {
            
            double factor = 0;
            
            if (neuron.distPref == 1) {
                factor = 1000;
            } else if (neuron.distPref == 2) {
                factor = 2000;
            } else if (neuron.distPref == 3) {
                factor = 3000;
            }
            
            neuron.distI = MathFunctions::sigmoid(distance, factor, -0.8) * 50;
        }
    }
    
    for (int i = 0; i < brain.numberOfNeurons; i++) {
        Neuron & neuron = brain.neurons[i];
        
        // Calculate audio input current
        if (neuron.audioPref == 1 || neuron.audioPref == 2 || neuron.audioPref == 3) {
            
            if ((neuron.audioPref == 1 && audioMaxFreq > 200 && audioMaxFreq < 400) ||
                (neuron.audioPref == 2 && audioMaxFreq > 500 && audioMaxFreq < 700) ||
                (neuron.audioPref == 3 && audioMaxFreq > 1100 && audioMaxFreq < 1300)) {
                
                neuron.audioI = 50;
            }
        }
    }
    
    std::random_device rd{};
    std::mt19937 gen{ rd() };
    std::normal_distribution<double> distribution(0.0, 1.0);
    
    // Run brain simulation
    for (int t = 0; t < msPerStep; t++) {
        
        for (int i = 0; i < brain.numberOfNeurons; i++) {
            Neuron & neuron = brain.neurons[i];
            
            // Add noise
            double randomNumber = distribution(gen);
            neuron.I = 5 * randomNumber;
        }
        
        for (int i = 0; i < brain.numberOfNeurons; i++) {
            Neuron & neuron = brain.neurons[i];
            
            // Find spiking neurons
            if (neuron.v >= 30) {
                neuron.spikesStep[t] = 1;
                
                // Reset spiking v to c
                neuron.v = neuron.c;
                
                // Adjust spiking u to d
                neuron.u = neuron.u + neuron.d;
                
                // Add spiking synaptic weights to neuronal inputs
                for (int k = 0; k < brain.numberOfNeurons; k++) {
                    Neuron & neuron2 = brain.neurons[k];
                    neuron2.I = neuron2.I + neuron.connectToMe[k];
                }
            }
        }
        
        for (int i = 0; i < brain.numberOfNeurons; i++) {
            Neuron & neuron = brain.neurons[i];
            
            // Add sensory input currents
            neuron.I = neuron.I + neuron.visI + neuron.distI + neuron.audioI;
            neuron.iStep[t] = neuron.I;
            
            // Update v
            neuron.v = neuron.v + 0.5 * (0.04 * std::pow(neuron.v, 2) + 5 * neuron.v + 140 - neuron.u + neuron.I);
            neuron.v = neuron.v + 0.5 * (0.04 * std::pow(neuron.v, 2) + 5 * neuron.v + 140 - neuron.u + neuron.I);
            
            // Update u
            neuron.u = neuron.u + neuron.a * (neuron.b * neuron.v - neuron.u);
            
            // Avoid nans
            if (std::isnan(neuron.v)) {
                neuron.v = neuron.c;
            }
        }
    }
    
    for (int i = 0; i < brain.numberOfNeurons; i++) {
        Neuron & neuron = brain.neurons[i];
        
        int sum = 0;
        for (auto& n : neuron.spikesStep) {
            sum += n;
        }
        
        neuron.firing = sum > 0 ? true : false;
    }
}

void BrainWorker::processVisualInput()
{
    if (videoFrame != 0) {
        
        cv::Size netInputSize(colsResized, rowsResized);
        
        int y = 0;
        int size = rows;
        
        if (rows > cols) {
            size = (int)((float)cols * 0.8);
            y = (rows - size) / 2;
        }
        
        cv::Rect left_cut(0, y, size, size);
        cv::Rect right_cut(cols - size, y, size, size);
        int sizes[] = { rows, cols };
        cv::Mat imageMat(2, sizes, CV_8UC3, videoFrame);
        
        //        cv::imshow("display", imageMat);
        
        for (int nCam = 0; nCam < 2; nCam++) {
            
            auto cameraType = nCam == 0 ? CameraTypeLeft : CameraTypeRight;
            
            cv::Mat bigFrame(rows, rows, CV_8UC3);
            
            cv::Mat frame;
            
            if (nCam == 0) {
                bigFrame = imageMat(left_cut);
            } else {
                bigFrame = imageMat(right_cut);
            }
            
            cv::resize(bigFrame, frame, netInputSize);
            
            auto scoreRed = calculateScore(ColorRed, frame, cameraType);
            
            brain.visPrefVals[0][nCam] = scoreRed.thisScore;
            brain.visPrefVals[1][nCam] = scoreRed.temporalScore;
            
            auto scoreGreen = calculateScore(ColorGreen, frame, cameraType);
            
            brain.visPrefVals[2][nCam] = scoreGreen.thisScore;
            brain.visPrefVals[3][nCam] = scoreGreen.temporalScore;
            
            auto scoreBlue = calculateScore(ColorBlue, frame, cameraType);
            
            brain.visPrefVals[4][nCam] = scoreBlue.thisScore;
            brain.visPrefVals[5][nCam] = scoreBlue.temporalScore;
        }
    }
}

void BrainWorker::processAudioInput()
{
    if (audioData.size() > 0) {
        float maxAmp = 0;
        float maxFreq = 0;
        calculateMaxAmpAndFreq(audioData, audioSampleRate, &maxAmp, &maxFreq);
        audioMaxFreq = maxFreq;
        max_amp = maxAmp;
    }
}

Score BrainWorker::calculateScore(ColorType color, cv::Mat frame, CameraType camera)
{
    Score score;
    
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
        
        if (camera == CameraTypeLeft) {
            score.temporalScore = MathFunctions::sigmoid(((227 - mean) / 227), 0.95, 5) * score.thisScore;
        } else if (camera == CameraTypeRight) {
            score.temporalScore = MathFunctions::sigmoid((mean / 227), 0.95, 5) * score.thisScore;
        }
        
    } else {
        score.thisScore = 0;
        score.temporalScore = 0;
    }
    
    return score;
}

void BrainWorker::updateMotors()
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
    //    double minTorque = 120;
    
    for (int i = 0; i < brain.numberOfNeurons; i++) {
        Neuron & neuron = brain.neurons[i];
        
        if (neuron.firing) {
            left_forward = left_forward + (neuron.contacts[5] + neuron.contacts[7]) / 2;
            right_forward = right_forward + (neuron.contacts[9] + neuron.contacts[11]) / 2;
            left_backward = left_backward + (neuron.contacts[6] + neuron.contacts[8]) / 2;
            right_backward = right_backward + (neuron.contacts[10] + neuron.contacts[12]) / 2;
        }
    }
    
    left_torque = left_forward - left_backward;
    
    left_dir = MathFunctions::sign(left_torque);
    left_torque = abs(left_torque);
    if (left_torque > maxTorque) {
        left_torque = maxTorque;
    }
    leftTorgue = left_torque * left_dir;
    
    right_torque = right_forward - right_backward;
    right_dir = MathFunctions::sign(right_torque);
    right_torque = abs(right_torque);
    if (right_torque > maxTorque) {
        right_torque = maxTorque;
    }
    rightTorgue = right_torque * right_dir;
    
    std::cout << "leftTorque: " << leftTorgue << "\trightTorque: " << rightTorgue << std::endl;
    
    std::vector<float> theseTones;
    for (int i = 0; i < brain.numberOfNeurons; i++) {
        Neuron & neuron = brain.neurons[i];
        
        if (neuron.contacts[3] > 0 && neuron.firing && neuron.tone != 0) {
            theseTones.push_back((float)neuron.tone);
        }
    }
    
    speakerTone = MathFunctions::mean(theseTones);
    
    std::cout << "speaker frequency: " << speakerTone << std::endl;
}

//MARK:- Out functions

std::vector<double> BrainWorker::getNeuronValues()
{
    auto numberOfNeurons = brain.neurons.size();
    std::vector<double> neuronValues(numberOfNeurons);
    
    for (int i = 0; i < numberOfNeurons; i++) {
        auto neuron = brain.neurons[i];
        neuronValues[i] = neuron.v;
    }
    
    return neuronValues;
}

std::vector<std::vector<double>> BrainWorker::getConnectToMe()
{
    auto numberOfNeurons = brain.neurons.size();
    auto connectToMeSize = brain.neurons.front().connectToMe.size();
    std::vector<std::vector<double>> connectToMe(numberOfNeurons, std::vector<double>(connectToMeSize));
    
    for (int i = 0; i < numberOfNeurons; i++) {
        auto neuron = brain.neurons[i];
        for (int j = 0; j < connectToMeSize; j++) {
            connectToMe[i][j] = neuron.connectToMe[j];
        }
    }
    
    return connectToMe;
}

std::vector<std::vector<double>> BrainWorker::getContacts()
{
    auto numberOfNeurons = brain.neurons.size();
    auto contactsSize = brain.neurons.front().contacts.size();
    std::vector<std::vector<double>> contacts(numberOfNeurons, std::vector<double>(contactsSize));
    
    for (int i = 0; i < numberOfNeurons; i++) {
        auto neuron = brain.neurons[i];
        for (int j = 0; j < contactsSize; j++) {
            contacts[i][j] = neuron.contacts[j];
        }
    }
    
    return contacts;
}

std::vector<double> BrainWorker::getX()
{
    auto numberOfNeurons = brain.neurons.size();
    std::vector<double> neuronValues(numberOfNeurons);
    
    for (int i = 0; i < numberOfNeurons; i++) {
        auto neuron = brain.neurons[i];
        neuronValues[i] = neuron.x;
    }
    
    return neuronValues;
}

std::vector<double> BrainWorker::getY()
{
    auto numberOfNeurons = brain.neurons.size();
    std::vector<double> neuronValues(numberOfNeurons);
    
    for (int i = 0; i < numberOfNeurons; i++) {
        auto neuron = brain.neurons[i];
        neuronValues[i] = neuron.y;
    }
    
    return neuronValues;
}

std::vector<bool> BrainWorker::getFiringNeurons()
{
    auto numberOfNeurons = brain.neurons.size();
    std::vector<bool> neuronValues(numberOfNeurons);
    
    for (int i = 0; i < numberOfNeurons; i++) {
        auto neuron = brain.neurons[i];
        neuronValues[i] = neuron.firing;
    }
    
    return neuronValues;
}

std::vector<std::vector<double>> BrainWorker::getColors()
{
    auto numberOfNeurons = brain.neurons.size();
    auto colorSize = brain.neurons.front().color.size();
    std::vector<std::vector<double>> colors(numberOfNeurons, std::vector<double>(colorSize));
    
    for (int i = 0; i < numberOfNeurons; i++) {
        auto neuron = brain.neurons[i];
        for (int j = 0; j < colorSize; j++) {
            colors[i][j] = neuron.color[j];
        }
    }
    
    return colors;
}

std::vector<std::vector<std::vector<bool>>> BrainWorker::getVisPrefs()
{
    std::vector<std::vector<std::vector<bool>>> visPrefs;
    
    for (auto & neuron : brain.neurons) {
        visPrefs.push_back(neuron.visPref);
    }
    
    return visPrefs;
}
