//
//  Copyright (c) 2017 Manav Rathi
//
//  Apache License, v2.0
//

import Foundation
import AVFoundation
import AudioToolbox

/// Play an AAC SHOUTcast stream.
///
/// An AAC stream has the MIME type "audio/aac", and the data consists
/// of ADTS (Audio Data Transport Stream) frames.

class AACShoutcastStreamPlayer: StreamPlayer, ShoutcastStreamDelegate, ADTSParserDelegate {

    let url: URL
    let delegateQueue: DispatchQueue

    weak var delegate: StreamPlayerDelegate?

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    private var stream: ShoutcastStream?
    private var adtsParser: ADTSParser?

    /// - Parameter url: The URL of the SHOUTcast stream server that
    ///   emits an AAC audio stream.
    ///
    /// - Parameter delegateQueue: A serial queue on which the delegate
    ///   methods will be invoked.

    init(url: URL, delegateQueue: DispatchQueue) {
        self.url = url
        self.delegateQueue = delegateQueue

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: nil)

        engine.prepare()
    }

    func play() {
        connect()
    }

    func pause() {
        stopPlayback()
        disconnect()
    }

    private func connect() {
        adtsParser = ADTSParser(pcmFormat: playerNode.outputFormat(forBus: 0))
        adtsParser?.delegate = self

        stream = ShoutcastStream(url: url, mimeType: "audio/aac", delegate: self, delegateQueue: delegateQueue)
    }
    
    private func disconnect() {
        stream = nil
        adtsParser = nil
    }

    private func startPlayback() throws {
        try engine.start()
        playerNode.play()
        delegate?.streamPlayerDidStartPlayback(self)
    }

    private func stopPlayback() {
        playerNode.stop()
        engine.stop()
        delegate?.streamPlayerDidStopPlayback(self)
    }

    func shoutcastStreamDidConnect(_ stream: ShoutcastStream) {
        do {
            try startPlayback()
        } catch {
            disconnect()
            return log.warning("Could not start audio playback: \(error)")
        }
    }

    func shoutcastStreamDidDisconnect(_ stream: ShoutcastStream) {
        disconnect()
        stopPlayback()
    }

    func shoutcastStream(_ stream: ShoutcastStream, gotNewTitle title: String) {
        delegate?.streamPlayer(self, didChangeSong: title)
    }

    func shoutcastStream(_ stream: ShoutcastStream, gotData data: Data) {
        adtsParser!.parse(data)
    }

    func adtsParserDidEncounterError(_ adtsParser: ADTSParser) {
        pause()
    }

    func adtsParser(_ adtsParser: ADTSParser, didParsePCMBuffer buffer: AVAudioPCMBuffer) {
        playerNode.scheduleBuffer(buffer)
    }

}
