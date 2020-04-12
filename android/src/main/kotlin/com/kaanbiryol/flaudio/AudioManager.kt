package com.kaanbiryol.flaudio

import android.media.AudioAttributes
import android.media.MediaPlayer

typealias DurationHandler = (Int, Int) -> Unit
typealias VoidHandler = () -> Unit

class Channel {
    companion object {
        const val prepare = "prepare"
        const val play = "play"
        const val pause = "pause"
        const val playbackSpeed = "playbackSpeed"
        const val seek = "seek"
        const val duration = "duration"
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
    var duration: Int
    fun prepare(urlString: String, onTickHandler: DurationHandler)
    fun play(onPlayHandler: VoidHandler)
    fun pause(onPauseHandler: VoidHandler)
    fun playbackSpeed(rate: Float)
    fun seek(seconds: Int)
}

class AudioManager: Playable {
    companion object {
        val instance = AudioManager()
    }

    override lateinit var player: MediaPlayer

    override var duration: Int = 0
        get() = player.duration

    override fun prepare(urlString: String, onTickHandler: DurationHandler) {
        player = MediaPlayer()
        player.setDataSource(urlString)
        player.prepare()
        player.setOnBufferingUpdateListener { player: MediaPlayer, seconds: Int ->
            onTickHandler(seconds, duration)
        }
    }

    override fun play(onPlayHandler: VoidHandler) {
        player.start()
        onPlayHandler()
    }

    override fun pause(onPauseHandler: VoidHandler) {
        player.pause()
        onPauseHandler()
    }

    override fun playbackSpeed(rate: Float) {
        player.playbackParams.speed = rate
        //player.playbackParams = player.playbackParams.setSpeed(rate)
    }

    override fun seek(seconds: Int) {
        player.seekTo(seconds)
    }

}

