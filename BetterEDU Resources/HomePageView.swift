//
//  HomePageView.swift
//  BetterEDU Resources
//
//  Created by McTyler Tong on 10/16/24.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        VStack {
            Text("BetterEDU Resources")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            TextField("Search Resources", text: .constant(""))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Button(action: {
                        // Navigate to Financial Services
                    }) {
                        Text("Financial Services")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }

                    Button(action: {
                        // Navigate to Emergency Hotlines
                    }) {
                        Text("Emergency Hotlines")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(10)
                    }

                    // Add more buttons here
                }
            }
            .padding()
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
