//
//  ContentView.swift
//  MediaControl
//
//  Created by Noah on 2024/3/25.
//

import SwiftUI
import Foundation


struct ContentView: View {
    @State var selectedDevice = 0
    @State var deviceNames = ["No device found"]
    // environment variable for ANDROID_HOME
    @State var ANDROID_HOME = ""

    var body: some View {
        VStack {
            // youtube music icon
            Image(systemName: "music.note")
                .imageScale(.large)
                .foregroundStyle(.tint)
                // size of the icon
                .frame(width: 48, height: 48)

            HStack {
                // a picker that can select device
                Picker("Device", selection: $selectedDevice) {
                    // add a list of devices
                    ForEach(0..<deviceNames.count, id: \.self) { index in
                        Text(deviceNames[index])
                    }
                }.frame(width: 200)

                Button(action: {
                    // refresh the device name
                    Task {
                       await getDevices()
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }.padding()
            // music control buttons
            HStack {
                Button(action: {
                    // open the App
                    Task {
                        await adbShellCommand(command: "am start -n com.google.android.apps.youtube.music/com.google.android.apps.youtube.music.activities.MusicActivity")
                    }
                }) {
                    Label("Open", systemImage: "music.note")
                }

                Button(action: {
                    // play previous music
                    Task {
                        await adbShellCommand(command: "input keyevent 88")
                    }
                }) {
                    Image(systemName: "backward.fill")
                }

                Button(action: {
                    // play/pause music
                    Task {
                        await adbShellCommand(command: "input keyevent 85")
                    }
                }) {
                    Label("Play/Pause", systemImage: "play")
                }

                // add button that can play next music with icon only
                Button(action: {
                    // play next music
                    Task {
                        await adbShellCommand(command: "input keyevent 87")
                    }
                }) {
                    Image(systemName: "forward.fill")
                }

                Button(action: {
                    // decrease volume
                    Task {
                        await adbShellCommand(command: "input keyevent 25")
                    }
                }) {
                    Image(systemName: "speaker.wave.1.fill")
                }

                Button(action: {
                    // increase volume
                    Task {
                        await adbShellCommand(command: "input keyevent 24")
                    }
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }
        }
        .padding(0)
        .navigationTitle("Media Control")
        .frame(width: 400, height: 180)
        .fixedSize()
        .onAppear {
            Task {
                ANDROID_HOME = "/Users/\(getUserName())/Library/Android/sdk"
                await getDevices()
            }
        }
    }

    func getDevices() async {
        try? Process.launch(
            path: "/Users/haoyu/Library/Android/sdk/platform-tools/adb",
            arguments: ["devices"],
            terminationHandler: { exitCode, outData, errorData in
                let outString = String(data: outData, encoding: .utf8) ?? ""
                let errorString = String(data: errorData, encoding: .utf8) ?? ""
                print("exitCode: \(exitCode)")
                print("outString: \(outString)")
                print("errorString: \(errorString)")
                // get the device name from the outString
                let lines = outString.split(separator: "\n")
                deviceNames = []
                for i in 1..<lines.count {
                    let device = lines[i].split(separator: "\t")[0]
                    deviceNames.append(String(device))
                }
            }
        )
    }

    func adbShellCommand(command: String) async {
        // split the command into an array
        let commandArray = command.split(separator: " ").map { String($0) }
        try? Process.launch(
            path: ANDROID_HOME + "/platform-tools/adb",
            arguments: ["-s", deviceNames[selectedDevice]] + ["shell"] + commandArray,
            // arguments: ["devices"],
            terminationHandler: { exitCode, outData, errorData in
                let outString = String(data: outData, encoding: .utf8) ?? ""
                let errorString = String(data: errorData, encoding: .utf8) ?? ""
                print("exitCode: \(exitCode)")
                print("outString: \(outString)")
                print("errorString: \(errorString)")
            }
        )
    }
}

#Preview {
    ContentView()
}

// function to get user name from the system
func getUserName() -> String {
    let userName = NSUserName()
    return userName
}

extension Process {
  @discardableResult
  static func launch(
    path: String,
    arguments: [String] = [],
    terminationHandler: @escaping (Int, Data, Data) -> Void
  ) throws -> Process {
    let process = Process()
    let outPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outPipe
    process.standardError = errorPipe
    process.arguments = arguments
    process.launchPath = path
    process.terminationHandler = { process in
      let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
      let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
      let exitCode = Int(process.terminationStatus)
      terminationHandler(exitCode, outData, errorData)
    }
    try process.run()
    return process
  }
}


func debugShellCommand(tool: String, command: String) async {
    // split the command into an array
    let commandArray = command.split(separator: " ").map { String($0) }
    try? Process.launch(
        path: tool,
        arguments: commandArray,
        terminationHandler: { exitCode, outData, errorData in
            let outString = String(data: outData, encoding: .utf8) ?? ""
            let errorString = String(data: errorData, encoding: .utf8) ?? ""
            print("exitCode: \(exitCode)")
            print("outString: \(outString)")
            print("errorString: \(errorString)")
        }
    )
}
