//
//  cpu.swift
//  Chip8Emulator
//
//  Created by Rob Patterson on 4/10/24.
//

import Foundation

class Chip8: ObservableObject {
    private var isRunning = false
    
    private var memory: [UInt8] = Array(repeating: 0, count: 4096)
    
    var display: [[UInt8]] = Array(repeating: Array(repeating: 0, count: 64), count: 32)
    
    private var PC: UInt16 = 0x200
    private var I: UInt16 = 0
    
    private var stack: [UInt16] = []
    
    private var delayTimer: UInt8 = 0
    private var soundTimer: UInt8 = 0
    
    private var V: [UInt8] = Array(repeating: 0, count: 16)
    
    private var keypad: [Bool] = Array(repeating: false, count: 16)
    
    func initialize() {
        let fontDef: [UInt8] = [
            0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
            0x20, 0x60, 0x20, 0x20, 0x70, // 1
            0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
            0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
            0x90, 0x90, 0xF0, 0x10, 0x10, // 4
            0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
            0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
            0xF0, 0x10, 0x20, 0x40, 0x40, // 7
            0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
            0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
            0xF0, 0x90, 0xF0, 0x90, 0x90, // A
            0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
            0xF0, 0x80, 0x80, 0x80, 0xF0, // C
            0xE0, 0x90, 0x90, 0x90, 0xE0, // D
            0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
            0xF0, 0x80, 0xF0, 0x80, 0x80  // F
        ]
        
        for i in 0..<fontDef.count {
            memory[0x50 + i] = fontDef[i]
        }
        
        PC = 0x200
        
        do {
            try loadROM(from: URL(fileURLWithPath: Bundle.main.path(forResource: "ibm-logo.ch8", ofType: nil)!))
        } catch {
            print("error")
        }
    }
    
    func loadROM(from url: URL) throws {
        let romData = try Data(contentsOf: url)
        for (i, byte) in romData.enumerated() {
            memory[0x200 + i] = byte
        }
    }
    
    func executeCycle() {
        let opcode = UInt16(memory[Int(PC)]) << 8 | UInt16(memory[Int(PC) + 1])
        PC += 2
        
        switch opcode & 0xF000 {
        case 0x0000:
            switch opcode & 0x00FF {
            case 0x00E0: // clear screen
                print("clearing screen")
                self.display = Array(repeating: Array(repeating: 0, count: 64), count: 32)
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                break
            case 0x00EE: // return from subroutine
                print("popping from stack")
                PC = stack.popLast()! // crash if stack is empty
                break
            default: break
            }
        case 0x1000: // set program counter to 0x0NNN
            PC = opcode & 0x0FFF
            break
        case 0x2000: // call subroutine at 0x0NNN
            stack.append(PC)
            PC = opcode & 0x0FFF
            break
        case 0x3000:
            
            break
        case 0x4000:
            break
        case 0x5000:
            break
        case 0x6000: // set register 0x0X00 to value 0x00NN
            print("setting register value")
            V[Int((opcode & 0x0F00) >> 8)] = UInt8(opcode & 0x00FF)
            break
        case 0x7000: // add 0x0NN to register 0x0X00
            print("adding to register")
            V[Int((opcode & 0x0F00) >> 8)] += UInt8(opcode & 0x00FF)
            break
        case 0x8000:
            switch opcode & 0x000F {
            case 0x0000:
                V[Int((opcode & 0x0F00) >> 8)] = V[Int((opcode & 0x00F0) >> 4)]
                break
            case 0x0001:
                V[Int((opcode & 0x0F00) >> 8)] |= V[Int((opcode & 0x00F0) >> 4)]
                break
            case 0x0002:
                V[Int((opcode & 0x0F00) >> 8)] &= V[Int((opcode & 0x00F0) >> 4)]
                break
            case 0x0003:
                V[Int((opcode & 0x0F00) >> 8)] ^= V[Int((opcode & 0x00F0) >> 4)]
                break
            case 0x0004: // NOT IMPLEMENTED
                V[Int((opcode & 0x0F00) >> 8)] = V[Int((opcode & 0x00F0) >> 4)]
                break
            case 0x0005: // NOT IMPLEMENTED
                V[Int((opcode & 0x0F00) >> 8)] = V[Int((opcode & 0x00F0) >> 4)]
                break
            case 0x0006:
                V[Int((opcode & 0x0F00) >> 8)] = V[Int((opcode & 0x00F0) >> 4)]
                let shiftedBit = V[Int((opcode & 0x0F00) >> 8)] & 0b0000_0001
                V[Int((opcode & 0x0F00) >> 8)] >>= 1
                V[0xF] = shiftedBit
                break
            case 0x0007: // NOT IMPLEMENTED
                V[Int((opcode & 0x0F00) >> 8)] = V[Int((opcode & 0x00F0) >> 4)]
                break
            case 0x000E:
                V[Int((opcode & 0x0F00) >> 8)] = V[Int((opcode & 0x00F0) >> 4)]
                let shiftedBit = V[Int((opcode & 0x0F00) >> 8)] & 0b1000_0000
                V[Int((opcode & 0x0F00) >> 8)] <<= 1
                V[0xF] = shiftedBit
                break
            default:
                break
            }
            break
        case 0xA000: // set I register to 0x0NNN
            print("setting I register")
            I = opcode & 0x0FFF
            break
        case 0xB000:
            PC = UInt16(V[Int((opcode & 0x0FFF))] + V[0x0])
            break
        case 0xC000:
            V[Int((opcode & 0x0F00) >> 8)] = UInt8.random(in: 0...255) & (UInt8(opcode) & 0x00FF)
            break
        case 0xD000: // display to screen
            let X = V[Int((opcode & 0x0F00) >> 8)]
            let Y = V[Int((opcode & 0x00F0) >> 4)]
            V[0xF] = 0
            
            let N = opcode & 0x000F
            
            print("displaying sprite at \(X), \(Y) with height \(N) to screen")
            
            for row in 0..<N {
                let spriteRow = memory[Int(I + row)]
                
                for col in 0..<8 {
                    let x_pos = (Int(X) + Int(col)) % 64
                    let y_pos = (Int(Y) + Int(row)) % 32
                    
                    let currentPixel = display[y_pos][x_pos]
                    
                    let spritePixel = (spriteRow >> (7 - col)) & 0x01
                    let newPixel = currentPixel ^ spritePixel
                    
                    display[y_pos][x_pos] = newPixel
                    
                    if currentPixel == 1 && newPixel == 0 {
                        V[0xF] = 1
                    }
                    
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                }
            }
            
            break
        case 0xE000:
            switch opcode & 0x00FF {
            case 0x009E:
                if keypad[Int(V[Int((opcode & 0x0F00) >> 8)])] { PC += 2 }
                break
            case 0x00A1:
                if !keypad[Int(V[Int((opcode & 0x0F00) >> 8)])] { PC += 2 }
                break
            default: break
            }
            break
        case 0xF000:
            switch opcode & 0x00FF {
            case 0x0007:
                V[Int((opcode & 0x0F00) >> 8)] = delayTimer
                break
            case 0x0015:
                delayTimer = V[Int((opcode & 0x0F00) >> 8)]
                break
            case 0x0018:
                soundTimer = V[Int((opcode & 0x0F00) >> 8)]
                break
            default:
                break
            }
            break
        default:
            break
        }
        
        if delayTimer > 0 {
            delayTimer -= 1
        }
        
        if soundTimer > 0 {
            soundTimer -= 1
        }
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true;
        initialize()
        DispatchQueue.global(qos: .userInitiated).async {
            while self.isRunning {
                self.executeCycle()
                usleep(1200)
            }
        }
    }
    
    func stop() {
        isRunning = false
    }
    
    private func getBits(fromByte byte: UInt8) -> [UInt8] {
        var byte = byte
        var bits: [UInt8] = Array(repeating: 0, count: 8)
        for i in 0..<8 {
            if (byte & 0x01) == 1 {
                bits[i] = 1
            }
            byte >>= 1
        }
        return bits
    }
}
