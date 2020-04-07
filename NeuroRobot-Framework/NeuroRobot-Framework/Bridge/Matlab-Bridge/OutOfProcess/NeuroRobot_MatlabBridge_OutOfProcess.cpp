//
//  NeuroRobot_MatlabBridge.cpp
//  Neurorobot-Framework
//
//  Created by Djordje Jovic on 7/6/19.
//  Copyright © 2019 Backyard Brains. All rights reserved.
//

#include "mex.hpp"
#include "mexAdapter.hpp"

#include "NeuroRobotManager.h"
//#include <iostream>
//#include <mex.h>
//#include <boost/thread/thread.hpp>
//#include "matrix.h"

/**
 Base Neuro Robot API class. It is intended to have only one statically allocated object of this class and all mex calls will be executed through that object.
 */

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
private:
    NeuroRobotManager *robotObject = NULL;
    std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();
    matlab::data::ArrayFactory factory;
    
public:
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        
        std::string function = checkArguments(outputs, inputs);
        
        if (function == "init") {
            init(outputs, inputs);
        } else if (function == "start") {
            start(outputs, inputs);
        } else if (function == "readAudio") {
            readAudio(outputs, inputs);
        } else if (function == "readVideo") {
            readVideo(outputs, inputs);
        } else if (function == "stop") {
            stop(outputs, inputs);
        } else if (function == "isRunning") {
            isRunning(outputs, inputs);
        } else if (function == "writeSerial") {
            writeSerial(outputs, inputs);
        } else if (function == "readSerial") {
            readSerial(outputs, inputs);
        } else {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("There isn't function with '" + function + "' name.") }));
        }
    }
    
private:
    void init(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        
        if (inputs.size() != 3) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("Three inputs required") }));
        }
        if (inputs[1].getType() != ArrayType::MATLAB_STRING) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("Second input must be type string. (ip address)") }));
        }
        if (inputs[2].getType() != ArrayType::MATLAB_STRING) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("Second input must be type string. (port)") }));
        }
        
        TypedArray<MATLABString> ipAddressArray = std::move(inputs[1]);
        TypedArray<MATLABString> portArray = std::move(inputs[2]);
        
        std::string ipAddress = std::string(ipAddressArray[0]);
        std::string port = std::string(portArray[0]);
        
        robotObject = new NeuroRobotManager(ipAddress, port, nullptr, nullptr);
    }
    
    void start(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        robotObject->start();
    }
    
    void readAudio(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        std::vector<size_t> size(1);
        int size_ = 0;
        int16_t *audioData = robotObject->readAudio(&size_);
        size[0] = (size_t)size_;
        
        outputs[0] = factory.createArray(size, audioData, audioData + size[0]);
    }
    
    void readVideo(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        std::vector<size_t> size = { (size_t)robotObject->videoFrameBytes() };
        uint8_t *videoData = robotObject->readVideoFrame();
        
        outputs[0] = factory.createArray(size, videoData, videoData + size[0]);
    }
    
    void stop(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        robotObject->stop();
        robotObject = NULL;
    }
    
    void isRunning(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        std::vector<size_t> size = { (size_t)1 };
        bool isRunning[] = { robotObject->isRunning() };
        
        outputs[0] = factory.createArray(size, isRunning, isRunning + size[0]);
    }
    
    void writeSerial(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        
        if (inputs.size() != 2) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("Two inputs required") }));
        }
        if (inputs[1].getType() != ArrayType::MATLAB_STRING) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("Second input must be type string") }));
        }
        TypedArray<MATLABString> serialDataArray = std::move(inputs[1]);
        std::string serialData = std::string(serialDataArray[0]);
        robotObject->writeSerial(serialData);
        
        //            char *input_buf;
        //            int   buflen,status;
        //
        //            /* Check for proper number of arguments. */
        //            if (nrhs != 2)
        //                mexErrMsgTxt("One input required.");
        //            else if (nlhs > 2)
        //                mexErrMsgTxt("Too many output arguments.");
        //
        //            /* Input must be a string. */
        //            if (mxIsChar(prhs[0]) != 1)
        //                mexErrMsgTxt("Input must be a string.");
        //
        //            /* Input must be a row vector. */
        //            if (mxGetM(prhs[0]) != 1)
        //                mexErrMsgTxt("Input must be a row vector.");
        //
        //            /* Get the length of the input string. */
        //            buflen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
        //
        //            /* Allocate memory for input and output strings. */
        //            input_buf = (char*) mxCalloc(buflen, sizeof(char));
        //
        //            /* Copy the string data from prhs[0] into a C string
        //             * input_buf. */
        //            status = mxGetString(prhs[1], input_buf, buflen);
        //            if (status != 0)
        //                mexWarnMsgTxt("Not enough space. String is truncated.");
        //
//                    std::string s(static_cast<const char*>(input_buf), buflen);
                    
    }
    
    void readSerial(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        std::vector<size_t> size(1);
        int size_ = 0;
        uint8_t *serialData = robotObject->readSerial(&size_);
        size[0] = (size_t)size_;
        
        outputs[0] = factory.createArray(size, serialData, serialData + size[0]);
    }
    void sendAudio(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
    }
    void readStreamState(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
    }
    void readSocketState(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
    }
    void readAudioSampleRate(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
    }
    void readVideoWidth(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
    }
    void readVideoHeight(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
    }
    
    std::string checkArguments(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        
        if (inputs.size() < 1) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("One or more inputs required") }));
        }
        if (inputs[0].getType() != ArrayType::MATLAB_STRING) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("First input must be type string. (function name)") }));
        }
        
        TypedArray<MATLABString> in = std::move(inputs[0]);
        std::string function = std::string(in[0]);
        if (function != "init" && !robotObject) {
            matlabPtr->feval("error", 0, std::vector<matlab::data::Array>({ factory.createScalar("Robot object not created. Please call `init` firstly.") }));
        }
        
        return function;

//        if (inputs.size() != 2) {
//            matlabPtr->feval(u"error",
//                0, std::vector<matlab::data::Array>({ factory.createScalar("Two inputs required") }));
//        }
//
//        if (inputs[0].getNumberOfElements() != 1) {
//            matlabPtr->feval(u"error",
//                0, std::vector<matlab::data::Array>({ factory.createScalar("Input multiplier must be a scalar") }));
//        }
//
//        if (inputs[0].getType() != matlab::data::ArrayType::DOUBLE ||
//            inputs[0].getType() == matlab::data::ArrayType::COMPLEX_DOUBLE) {
//            matlabPtr->feval(u"error",
//                0, std::vector<matlab::data::Array>({ factory.createScalar("Input multiplier must be a noncomplex scalar double") }));
//        }
//
//        if (inputs[1].getType() != matlab::data::ArrayType::DOUBLE ||
//            inputs[1].getType() == matlab::data::ArrayType::COMPLEX_DOUBLE) {
//            matlabPtr->feval(u"error",
//                0, std::vector<matlab::data::Array>({ factory.createScalar("Input matrix must be type double") }));
//        }
//
//        if (inputs[1].getDimensions().size() != 2) {
//            matlabPtr->feval(u"error",
//                0, std::vector<matlab::data::Array>({ factory.createScalar("Input must be m-by-n dimension") }));
//        }
    }
};
