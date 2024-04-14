//
//  Chip8Display.swift
//  Chip8Emulator
//
//  Created by Rob Patterson on 4/13/24.
//

import SwiftUI

struct Chip8Display: View {
    @ObservedObject var chip8: Chip8 = Chip8()
    @State private var refreshID = UUID()
    
    var body: some View {
        return GeometryReader { geometry in
            VStack(spacing: 0) {
                ForEach(0..<32, id: \.self) { y in
                    HStack(spacing: 0) {
                        ForEach(0..<64, id: \.self) { x in
                            Rectangle()
                                .fill(self.chip8.display[y][x] == 1 ? Color.white : Color.black)
                                .frame(width: geometry.size.width / 64, height: geometry.size.height / 32)
                                .id(refreshID)
                        }
                    }
                }
            }
            .border(Color.gray, width: 5)
        }
        .background(Color.blue)
        .frame(width: 320, height: 160)
        .onAppear() {
            self.chip8.start()
            self.refreshID = UUID()
        }
    }
}
