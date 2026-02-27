//
//  ContentView.swift
//  MuffinStoreJailed
//
//  Created by Mineek on 26/12/2024.
//

import SwiftUI
import PartyUI
import DeviceKit

struct ContentView: View {
    @State private var hasShownWelcome: Bool = false
    @State private var showLogs: Bool = true
    @State private var showSettingsView: Bool = false
    
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        VStack {
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationSplitView(sidebar: {
                    List {
                        if showLogs {
                            Section(header: HeaderLabel(text: "Terminal", icon: "terminal")) {
                                VStack(alignment: .leading) {
                                    TerminalView()
                                }
                                .padding()
                                .modifier(DynamicGlassEffect(shape: AnyShape(.rect(cornerRadius: platterCornerRadius())), useBackground: false))
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(.dropdownRowInsets)
                        }
                        Section {
                            BottomBar()
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.dropdownRowInsets)
                    }
                    .listStyle(.plain)
                    .navigationTitle("PancakeStore")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                Haptic.shared.play(.soft)
                                showLogs.toggle()
                            }) {
                                Image(systemName: "terminal")
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                showSettingsView.toggle()
                            }) {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
                    .modifier(SidebarToggleModifier())
                    .navigationSplitViewColumnWidth(385)
                }) {
                    List {
                        if !appData.isAuthenticated {
                            LoginView()
                        } else {
                            if appData.isDowngrading {
                                DowngradingView()
                            } else {
                                DowngradeAppView()
                            }
                        }
                    }
                }
            } else {
                NavigationStack {
                    List {
                        if showLogs {
                            VStack(alignment: .leading) {
                                TerminalView()
                            }
                        }
                        if !appData.isAuthenticated {
                            LoginView()
                        } else {
                            if appData.isDowngrading {
                                DowngradingView()
                            } else {
                                DowngradeAppView()
                            }
                        }
                    }
                    .navigationTitle("PancakeStore")
                    .safeAreaInset(edge: .bottom) {
                        BottomBar()
                            .modifier(OverlayBackground())
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                Haptic.shared.play(.soft)
                                showLogs.toggle()
                            }) {
                                Image(systemName: "terminal")
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                showSettingsView.toggle()
                            }) {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .onAppear {
            appData.isAuthenticated = EncryptedKeychainWrapper.hasAuthInfo()
            print("Found \(appData.isAuthenticated ? "auth" : "no auth") info in keychain")
            if appData.isAuthenticated {
                appData.applicationStatus = "Ready to Downgrade!"
                appData.applicationIcon = "checkmark.circle.fill"
                appData.applicationIconColor = .primary
                guard let authInfo = EncryptedKeychainWrapper.getAuthInfo() else {
                    print("Failed to get auth info from keychain, logging out")
                    appData.isAuthenticated = false
                    EncryptedKeychainWrapper.nuke()
                    EncryptedKeychainWrapper.generateAndStoreKey()
                    return
                }
                appData.appleId = authInfo["appleId"]! as! String
                appData.password = authInfo["password"]! as! String
                appData.ipaTool = IPATool(appleId: appData.appleId, password: appData.password)
                let ret = appData.ipaTool?.authenticate()
                print("Re-authenticated \(ret! ? "successfully" : "unsuccessfully")")
            } else {
                print("No auth info found in keychain, setting up by generating a key in SEP")
                EncryptedKeychainWrapper.generateAndStoreKey()
            }
        }
    }
}

struct SidebarToggleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .toolbar(removing: .sidebarToggle)
        } else {
            content
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppData())
}
