//
//  Sounds.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 18.3.21..
//  Copyright © 2021 Backyard Brains. All rights reserved.
//

import Foundation

final class Sounds {
    
    public static let shared = Sounds()
    
    private init() { }
    
    private let soundsFolderPath: [URL] = {
        guard let soundsURL = Bundle.main.url(forResource: "Sounds", withExtension: nil) else { fatalError() }
        guard var sounds = try? FileManager().contentsOfDirectory(at: soundsURL, includingPropertiesForKeys: nil, options: []) else { fatalError() }
        sounds.sort(by: { $0.path < $1.path } )
        return sounds
    }()
    
    private let soundsWavFolderPath: [URL] = {
        guard let soundsURL = Bundle.main.url(forResource: "Sounds/wav", withExtension: nil) else { fatalError() }
        guard var sounds = try? FileManager().contentsOfDirectory(at: soundsURL, includingPropertiesForKeys: nil, options: []) else { fatalError() }
        sounds.sort(by: { $0.path < $1.path } )
        return sounds
    }()
    
    func getURL(index: Int) -> URL {
        guard index > 0, index < soundsFolderPath.count - 1 else { fatalError("Sound index out of bounds.") }
        return soundsFolderPath[index]
    }
    
    func getURLWav(index: Int) -> URL {
        guard index > 0, index < soundsWavFolderPath.count - 1 else { fatalError("Sound index out of bounds.") }
        return soundsWavFolderPath[index]
    }
}
