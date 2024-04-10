//
//  cpu.swift
//  Chip8Emulator
//
//  Created by Rob Patterson on 4/10/24.
//

import Foundation

class Chip8 {
    var memory: [UInt8]
    
    var display: [[CFBit]]
    
    var PC: UInt16
    var I: UInt16
    
    var stack: [UInt16]
    
    var delayTimer: UInt8
    var soundTimer: UInt8
    
    var V: [UInt8]
    
    init() {
        self.memory = []
        self.display = [[]]
        self.PC = 0
        self.I = 0
        self.stack = []
        self.delayTimer = 0
        self.soundTimer = 0
        self.V = []
    }
}
