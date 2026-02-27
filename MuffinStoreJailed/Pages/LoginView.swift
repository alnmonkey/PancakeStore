//
//  LoginView.swift
//  PancakeStore
//
//  Created by lunginspector on 2/24/26.
//

import SwiftUI
import PartyUI

struct LoginView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        Section(header: HeaderLabel(text: "Apple ID", icon: "icloud"), footer: Text("Created by [mineek](https://github.com/mineek/MuffinStoreJailed-Public), improved with love by [jailbreak.party](https://github.com/jailbreakdotparty). Use this tool at your own risk! App data may be lost, and other damage could occur.")) {
            VStack(spacing: 12) {
                TextField("Email Address", text: $appData.appleId)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(GlassyTextFieldStyle(isDisabled: appData.hasSent2FACode))
                HStack {
                    if appData.showPassword {
                        TextField("Password", text: $appData.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(GlassyTextFieldStyle(isDisabled: appData.hasSent2FACode))
                    } else {
                        SecureField("Password", text: $appData.password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textFieldStyle(GlassyTextFieldStyle(isDisabled: appData.hasSent2FACode))
                    }
                    Button(action: {
                        appData.showPassword.toggle()
                    }) {
                        Image(systemName: appData.showPassword ? "eye" : "eye.slash")
                            .frame(width: 20, height: 22)
                            .modifier(UpdatedIconAnimation(isOn: appData.showPassword))
                    }
                    .buttonStyle(GlassyButtonStyle())
                    .frame(width: 50)
                }
            }
        }
        if appData.hasSent2FACode {
            Section(header: HeaderLabel(text: "2FA Code", icon: "key"), footer: Text("If you did not receive a notification on any of the devices that are trusted to receive verification codes, type in six random numbers into the field. Trust me.")) {
                TextField("2FA Code", text: $appData.code)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(GlassyTextFieldStyle())
            }
        }
    }
}
