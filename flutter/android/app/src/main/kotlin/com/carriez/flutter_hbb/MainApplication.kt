package com.carriez.flutter_hbb

import android.app.Application
import android.util.Log
import ffi.FFI

class MainApplication : Application() {
    companion object {
        private const val TAG = "MainApplication"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "App start")
        // Only call native function if library is loaded
        if (FFI.nativeLibraryLoaded) {
            try {
                FFI.onAppStart(applicationContext)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to call FFI.onAppStart: ${e.message}")
            }
        } else {
            Log.w(TAG, "Native library not loaded, skipping FFI.onAppStart")
        }
    }
}
