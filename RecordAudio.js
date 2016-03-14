'use strict';

import React,{
    NativeModules
} from 'react-native';

const Recorder = NativeModules.RecordAudio;

export default class RecordAudio {
    startRecord(saveFileName, callback) {
        Recorder.startRecord(saveFileName, (args)=>{
            callback && callback(args);
        });
    }

    stopRecord(callback) {
        Recorder.stopRecord((args)=>{
            callback && callback(args);
        });
    }

    clearCache(callback){
        Recorder.clearCache((args)=>{
            callback && callback(args);
        });
    }
}