package com.keyee.recordAudio;

import java.io.File;
import android.widget.Toast;
import android.util.Log;

import android.content.Context;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

public class RecordModule extends ReactContextBaseJavaModule {
    private Callback callback;
    private static final String TAG = RecordModule.class.getSimpleName();
    private ExtAudioRecorder exRecorder = null;
    private Context context;
    private String WavAudioName;

    public RecordModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;
    }

    @Override
    public String getName() { return "RecordAudio"; }

    @ReactMethod
    public void startRecord(String fileName, Callback callback) {
        this.callback = callback;
        WritableMap callbackMap = Arguments.createMap();
        if (fileName == null || fileName == "")
            fileName = "recordKeyeeApp";
        if (!fileName.endsWith(".wav"))
            fileName+= ".wav";
        String fileBasePath = this.getReactApplicationContext().getFilesDir().getAbsolutePath();
        WavAudioName = fileBasePath+"/audioCache/"+fileName;
        if (exRecorder != null){
            exRecorder.release();
            exRecorder = null;
        }
        File file = new File(WavAudioName);
        if (file.exists()) {
            file.delete();
        }
        exRecorder = ExtAudioRecorder.getInstanse(false);
        exRecorder.setOutputFile(WavAudioName);
        exRecorder.prepare();
        exRecorder.start();

        callbackMap.putBoolean("success", true);
        callbackMap.putString("param","Successfully started.");
        callback.invoke(callbackMap);
    }

    @ReactMethod
    public void stopRecord(Callback callback) {
        WritableMap callbackMap = Arguments.createMap();
        if (exRecorder == null || exRecorder.getState() != ExtAudioRecorder.State.RECORDING){
            callbackMap.putBoolean("success", false);
            callbackMap.putString("param","未正确开始录音,或发生错误.");
            callback.invoke(callbackMap);
            return;
        }
        exRecorder.stop();
        exRecorder.release();
        exRecorder = null;
        callbackMap.putBoolean("success", true);
        callbackMap.putString("param", WavAudioName);
        callback.invoke(callbackMap);
    }

    @ReactMethod
    public void clearCache(Callback callback) {
        try {
            String fileBasePath = this.getReactApplicationContext().getFilesDir().getAbsolutePath();
            File file = new File(fileBasePath+"/audioCache");
            if (!file.exists()) {
                callback.invoke(true);
                return;
            }
            boolean success = DeleteRecursive(file);
            callback.invoke(success);
        } catch (Exception ex) {
            ex.printStackTrace();
            callback.invoke(false);
        }
    }

    private boolean DeleteRecursive(File fileOrDirectory) {
        if (fileOrDirectory.isDirectory()) {
            for (File child : fileOrDirectory.listFiles()) {
                DeleteRecursive(child);
            }
        }
        return fileOrDirectory.delete();
    }
}