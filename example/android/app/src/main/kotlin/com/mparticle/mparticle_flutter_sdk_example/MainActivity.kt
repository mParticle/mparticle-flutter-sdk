package com.mparticle.mparticle_flutter_sdk_example

import android.app.Application
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import com.mparticle.MParticle
import com.mparticle.MParticleOptions

class ExampleApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        val options = MParticleOptions.builder(this)
                .logLevel(MParticle.LogLevel.VERBOSE)
                .credentials("API-KEY", "SECRET")
                .build()
        MParticle.start(options)
    }

}



class MainActivity: FlutterActivity() {
}