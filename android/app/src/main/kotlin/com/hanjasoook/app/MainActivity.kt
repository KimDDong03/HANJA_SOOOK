package com.hanjasoook.app

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.SoundPool
import android.os.Build
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val audioChannelName = "hanjasoook/audio"
    private val notificationChannelName = "hanjasoook/notifications"
    private val notificationPermissionRequestCode = 4301
    private val soundPool =
        SoundPool.Builder()
            .setMaxStreams(4)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .build()
    private val soundIds = mutableMapOf<String, Int>()
    private val loadedSoundIds = mutableSetOf<Int>()
    private val pendingSoundVolumes = mutableMapOf<Int, Float>()
    private var strokeStreamId: Int? = null
    private var musicPlayer: MediaPlayer? = null
    private var currentMusicAsset: String? = null
    private var pendingNotificationResult: MethodChannel.Result? = null
    private var pendingReminderHour: Int = 18
    private var pendingReminderMinute: Int = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        soundPool.setOnLoadCompleteListener { pool, soundId, status ->
            if (status == 0) {
                loadedSoundIds.add(soundId)
                val volume = pendingSoundVolumes.remove(soundId)
                if (volume != null) {
                    pool.play(soundId, volume, volume, 1, 0, 1f)
                }
            } else {
                pendingSoundVolumes.remove(soundId)
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            audioChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playMusic" -> {
                    val asset = call.argument<String>("asset")
                    val volume = call.argument<Double>("volume")?.toFloat() ?: 1f
                    if (asset == null) {
                        result.error("missing_asset", "Audio asset is required.", null)
                    } else {
                        playMusic(asset, volume)
                        result.success(null)
                    }
                }
                "stopMusic" -> {
                    stopMusic()
                    result.success(null)
                }
                "playSfx" -> {
                    val asset = call.argument<String>("asset")
                    val volume = call.argument<Double>("volume")?.toFloat() ?: 1f
                    if (asset == null) {
                        result.error("missing_asset", "Audio asset is required.", null)
                    } else {
                        playSfx(asset, volume)
                        result.success(null)
                    }
                }
                "stopStrokeSfx" -> {
                    stopStrokeSfx()
                    result.success(null)
                }
                "preloadSfx" -> {
                    val asset = call.argument<String>("asset")
                    if (asset == null) {
                        result.error("missing_asset", "Audio asset is required.", null)
                    } else {
                        preloadSfx(asset)
                        result.success(null)
                    }
                }
                "dispose" -> {
                    disposeAudio()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationChannelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleDailyReminder" -> {
                    val hour = call.argument<Int>("hour") ?: 18
                    val minute = call.argument<Int>("minute") ?: 0
                    scheduleDailyReminderWithPermission(hour, minute, result)
                }
                "cancelDailyReminder" -> {
                    DailyReminderScheduler.cancel(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != notificationPermissionRequestCode) {
            return
        }

        val result = pendingNotificationResult ?: return
        pendingNotificationResult = null
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (granted) {
            DailyReminderScheduler.schedule(
                this,
                pendingReminderHour,
                pendingReminderMinute
            )
        }
        result.success(granted)
    }

    override fun onPause() {
        super.onPause()
        stopStrokeSfx()
        stopMusic()
    }

    private fun scheduleDailyReminderWithPermission(
        hour: Int,
        minute: Int,
        result: MethodChannel.Result
    ) {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                PackageManager.PERMISSION_GRANTED
        ) {
            if (pendingNotificationResult != null) {
                result.success(false)
                return
            }
            pendingNotificationResult = result
            pendingReminderHour = hour
            pendingReminderMinute = minute
            requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                notificationPermissionRequestCode
            )
            return
        }

        DailyReminderScheduler.schedule(this, hour, minute)
        result.success(true)
    }

    private fun playMusic(asset: String, volume: Float) {
        if (currentMusicAsset == asset && musicPlayer?.isPlaying == true) {
            musicPlayer?.setVolume(volume, volume)
            return
        }

        stopMusic()
        val assetFileDescriptor = assets.openFd(assetKey(asset))
        musicPlayer =
            MediaPlayer().apply {
                setDataSource(
                    assetFileDescriptor.fileDescriptor,
                    assetFileDescriptor.startOffset,
                    assetFileDescriptor.length
                )
                isLooping = true
                setVolume(volume, volume)
                prepare()
                start()
            }
        assetFileDescriptor.close()
        currentMusicAsset = asset
    }

    private fun stopMusic() {
        musicPlayer?.stop()
        musicPlayer?.release()
        musicPlayer = null
        currentMusicAsset = null
    }

    private fun playSfx(asset: String, volume: Float) {
        if (isStrokeSfx(asset)) {
            playStrokeSfx(asset, volume)
            return
        }
        val soundId = soundIds[asset]
        if (soundId != null) {
            if (loadedSoundIds.contains(soundId)) {
                soundPool.play(soundId, volume, volume, 1, 0, 1f)
            } else {
                pendingSoundVolumes[soundId] = volume
            }
            return
        }

        val assetFileDescriptor = assets.openFd(assetKey(asset))
        val newSoundId = soundPool.load(assetFileDescriptor, 1)
        assetFileDescriptor.close()
        soundIds[asset] = newSoundId
        pendingSoundVolumes[newSoundId] = volume
    }

    private fun preloadSfx(asset: String) {
        if (soundIds.containsKey(asset)) {
            return
        }

        val assetFileDescriptor = assets.openFd(assetKey(asset))
        val newSoundId = soundPool.load(assetFileDescriptor, 1)
        assetFileDescriptor.close()
        soundIds[asset] = newSoundId
    }

    private fun playStrokeSfx(asset: String, volume: Float) {
        stopStrokeSfx()
        val soundId = soundIds[asset]
        if (soundId != null) {
            if (loadedSoundIds.contains(soundId)) {
                strokeStreamId = soundPool.play(soundId, volume, volume, 1, 0, 1f)
            }
            return
        }

        val assetFileDescriptor = assets.openFd(assetKey(asset))
        val newSoundId = soundPool.load(assetFileDescriptor, 1)
        assetFileDescriptor.close()
        soundIds[asset] = newSoundId
    }

    private fun stopStrokeSfx() {
        val streamId = strokeStreamId
        if (streamId != null) {
            soundPool.stop(streamId)
        }
        strokeStreamId = null
    }

    private fun isStrokeSfx(asset: String): Boolean {
        return asset.contains("brush_01_b") ||
            asset.contains("writing_sound_effect") ||
            asset.contains("stroke_texture")
    }

    private fun disposeAudio() {
        stopStrokeSfx()
        stopMusic()
        soundPool.release()
    }

    private fun assetKey(asset: String): String {
        return FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(asset)
    }
}
