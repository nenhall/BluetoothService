//
//  Bytes.swift
//  BluetoothService
//
//  Created by nenhall on 2020/4/19.
//  Copyright © 2020 nenhall. All rights reserved.
//

import Foundation

precedencegroup DefaultPrecedence {
    associativity : left
    higherThan: AdditionPrecedence
    lowerThan: MultiplicationPrecedence
    assignment: true
}
infix operator >~

public class Hex {
    public var bytes = [UInt8]()
    public var value = UInt8(0)
    public var byte: Data {
        get {
            Data(_: self.bytes)
        }
    }
    public init(_ _value: UInt8) {
        value = _value
        bytes.append(_value)
    }
    public static func >~(lHex: Hex, rHex: Hex) -> Hex {
        let hex = lHex
        hex.bytes.append(rHex.value)
        return hex
    }
}

public extension Array where Element == UInt8 {
    var byte: Data { get { Data(_: self) } }
    static func >~(lElement: Array<UInt8>, rElement:  Array<UInt8>) -> Array<UInt8> {
        var arr = lElement
        arr.append(contentsOf: rElement)
        return arr
    }
}

public extension Int {
    var hex: UInt8 { get { UInt8(self) } }
}

public extension String {
    
    /// 十六进制转换成字符串
    /// - Returns: description
    mutating func hexToString() -> String {
        var bytes = [UInt8]()
        var dataBStr : String = ""
        for (index, _) in self.enumerated(){
            let fromIndex = index*2
            let toIndex = index*2 + 1
            if toIndex > (self.count - 1) {
                break
            }
            
           let range = NSRange.init(location: fromIndex, length: 2)
            let ocString = NSString.init(string: self)
            let subStr = ocString.substring(with: range)
            let hexCharStr = String.init(subStr)
            var r:CUnsignedInt = 0
            Scanner(string: hexCharStr).scanHexInt32(&r)
            bytes.append(UInt8(r))
        }
        
        dataBStr = String.init(data: Data(_: bytes), encoding: String.Encoding.ascii)!
        return dataBStr
    }

    
    /// 字符串转换为十六进制
    /// - Returns: 十六进制字符串
    func toHexString() -> String {
            let strData = self.data(using: String.Encoding.utf8)
            let bytes = strData?.withUnsafeBytes {
                [UInt8](UnsafeBufferPointer(start: $0, count: (strData?.count)!))
            }

            var sumString : String = ""
            for byte in bytes! {
                let newString = String(format: "%x",byte&0xff)
                if newString.count == 1 {
                    sumString = String(format: "%@0%@",sumString,newString)
                }else{
                    sumString = String(format: "%@%@",sumString,newString)
                }
            }

            return sumString
        }
    
    func hah() {
//        let a = Scanner.init(string: resArr.last!)
//        var b:UInt32 = 0
//        if withUnsafeMutablePointer(to: &b, {
//              a.scanHexInt32($0)
//        }){
//         print(b)
//        }
    }
}

