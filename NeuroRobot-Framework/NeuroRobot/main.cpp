//
//  main.cpp
//  NeuroRobot
//
//  Created by Djordje Jovic on 16/01/2020.
//  Copyright © 2020 Backyard Brains. All rights reserved.
//

#include <iostream>
#include "../NeuroRobot-Framework/NeuroRobotManager.h"
#include <boost/thread/thread.hpp>


////class Callbacks {
////public:
//    static void streamCallback(StreamStateType error) {
//
//    }
//
//    static void socketCallback(SocketStateType error) {
//
//    }
////};

int main(int argc, const char * argv[]) {
    std::string cmdString = "";
    
    NeuroRobotManager *robotObject = new NeuroRobotManager("192.168.100.1", "80", nullptr, nullptr);
    robotObject->start();
    
    int cycleCounter = 0;
    
    while(robotObject->isRunning() && cmdString.length() == 0) {
        
        size_t size = 0;
        unsigned short bytesPerSample = 0;
        robotObject->readAudio(&size, &bytesPerSample);
        std::cout << "Read " << size << " bytes" << std::endl;
        
        cycleCounter++;
        
//        std::getline(std::cin, cmdString);
    }
    
    robotObject->stop();
    
    boost::this_thread::sleep_for(boost::chrono::milliseconds(2000));
    
    return 0;
}

