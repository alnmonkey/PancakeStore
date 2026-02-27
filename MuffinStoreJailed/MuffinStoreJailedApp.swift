//
//  MuffinStoreJailedApp.swift
//  MuffinStoreJailed
//
//  Created by Mineek on 31/12/2024.
//

import SwiftUI

var pipe = Pipe()
var sema = DispatchSemaphore(value: 0)
var weOnADebugBuild: Bool = false

@main
struct MuffinStoreJailedApp: App {
    @StateObject private var appData = AppData.shared
    
    init() {
        // Setup log stuff (redirect stdout)
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        #if DEBUG
        weOnADebugBuild = true
        #else
        weOnADebugBuild = false
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
    }
}

extension String: @retroactive Error {}
