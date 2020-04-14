package com.kaanbiryol.flaudio

import android.media.MediaPlayer
import java.util.*
import kotlin.time.milliseconds


typealias DurationHandler = (Double, Double) -> Unit
typealias VoidHandler = () -> Unit
typealias ReadyHandler = (Double) -> Unit

class Channel {
    companion object {
        const val prepare = "prepare"
        const val play = "play"
        const val pause = "pause"
        const val playbackSpeed = "playbackSpeed"
        const val seek = "seek"
        const val seekTo = "seekTo"
        const val duration = "duration"
        const val dispose = "dispose"
    }
}

class Event {
    companion object {
        const val onStart = "onStart"
        const val onPause = "onStart"
        const val onTick = "onTick"
    }
}

interface Playable {
    var player: MediaPlayer
    var duration: Double
    fun prepare(urlString: String, onTickHandler: DurationHandler, onReadyHandler: ReadyHandler)
    fun play(onPlayHandler: VoidHandler)
    fun pause(onPauseHandler: VoidHandler)
    fun playbackSpeed(rate: Double)
    fun seek(seconds: Double)
    fun seekTo(seconds: Double)
    fun dispose()
}

class AudioManager : Playable {
    companion object {
        val instance = AudioManager()
    }

    private val streamTimer = Timer()
    override lateinit var player: MediaPlayer

    override var duration: Double = 0.0
        get() = player.duration.toDouble()

    override fun prepare(urlString: String, onTickHandler: DurationHandler, onReadyHandler: ReadyHandler) {
        player = MediaPlayer()
        player.setDataSource(urlString)
        player.setOnPreparedListener {
            onReadyHandler(duration)
        }
        val streamTask = object: TimerTask() {
            override fun run() {
                if (player.isPlaying) onTickHandler(player.currentPosition.toDouble(), duration)
            }
        }
        streamTimer.schedule(streamTask, 0, 1000)
        player.prepare()
    }

    override fun play(onPlayHandler: VoidHandler) {
        player.start()
        onPlayHandler()
    }

    override fun pause(onPauseHandler: VoidHandler) {
        player.pause()
        onPauseHandler()
    }

    override fun playbackSpeed(rate: Double) {
        player.playbackParams = player.playbackParams.setSpeed(rate.toFloat());
    }

    override fun seek(seconds: Double) {
        player.seekTo(player.currentPosition + (seconds * 1000).toInt())
    }

    override fun seekTo(seconds: Double) {
        player.seekTo((seconds * 1000).toInt())
    }

    override fun dispose() {
        player.stop()
        player.release()
        streamTimer.cancel()
        streamTimer.purge()
    }

}

