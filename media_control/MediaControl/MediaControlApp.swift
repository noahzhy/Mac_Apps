//
//  MediaControlApp.swift
//  MediaControl
//
//  Created by Noah on 2024/3/25.
//

import SwiftUI

@main
struct MediaControlApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().frame(minWidth: 400, minHeight: 180)
        }.windowResizability(.contentSize)
    }
}
