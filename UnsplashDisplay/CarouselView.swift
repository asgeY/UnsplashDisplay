//
//  CarouselView.swift
//  UnsplashDisplay
//
//  Created by AsgeY on 4/26/23.
//

import SwiftUI

struct CarouselView: View {
    var photos: [UnsplashImage]
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack {

            }

            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .frame(width: 450, height: 700)
            .onChange(of: currentIndex) { newValue in
                if newValue == photos.count {
                    currentIndex = 0
                } else if newValue == -1 {
                    currentIndex = photos.count - 1
                }
            }
        }
    }

