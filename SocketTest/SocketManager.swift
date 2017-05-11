//
//  SocketManager.swift
//  SocketTest
//
//  Created by yiyou on 2017/5/10.
//  Copyright © 2017年 esgame. All rights reserved.
//

import UIKit

protocol SocketToolDelegate {
    
    func socketDidReceivedText(_ text: String, tag: Int) -> Void
    
    func socketDidDisconnect(err: Error?) -> Void
    
    func socketDidConnect() -> Void
}


class SocketManager : NSObject, GCDAsyncSocketDelegate {
    
    
    var delegate : SocketToolDelegate?
    
    //心跳包
    private let heartKey = "heart";
    private let heartRequestTag = 99;
    private let heartTimeInterval: TimeInterval = 30
    
    //应答超时
    private let timeout:TimeInterval = 5;
    
    private var timer: Timer?
    
    private var socket: GCDAsyncSocket?
    
    private var hasStartHeart: Bool = false
    
    var isConnecting:Bool {
        return hasStartHeart
    }
    
    
    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    //连接
    func connect(toHost: String, onPort: UInt16) throws {
        try socket?.connect(toHost: toHost, onPort: onPort)
    }
    
    //断开连接
    func disconnect() {
        socket?.disconnect()
    }
    
    //发送数据
    func write(_ text: String, tag:Int = 0) {
        if let data = text.appending("\r\n").data(using: .utf8) {
            socket?.readData(withTimeout: timeout, tag: tag)
            socket?.write(data, withTimeout: timeout, tag: tag)
        }
    }
    
    //关闭心跳
    private func closeHeart() {
        timer?.invalidate()
        hasStartHeart = false
    }
    
    
    //开启心跳
    private func startHeart() {
        
        guard hasStartHeart == false else {
            return
        }
        
        closeHeart()
        
        DispatchQueue.global().async { [unowned self] in
            self.timer = Timer.init(timeInterval: 1, target: self, selector:#selector(self.writeHeart), userInfo: nil, repeats: true)
            RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
        }
        
        hasStartHeart = true
    }
    
    func writeHeart() {
        self.write(self.heartKey, tag: self.heartRequestTag)
    }
    
    
    /////////////////////////////////////////
    
    //接受数据
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) -> Void {
        
        if tag == self.heartRequestTag {
            NSLog("received heart")
        }
        else {
            if let text = String(data: data as Data, encoding: String.Encoding.utf8) {
                delegate?.socketDidReceivedText(text, tag: tag)
            }
        }
    }
    
    
    //连接成功
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) -> Void {
        self.socket?.readData(withTimeout: -1, tag: 0)
        
        startHeart()
        
        delegate?.socketDidConnect()
    }
    
    //连接断开
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) -> Void {
        closeHeart()
        delegate?.socketDidDisconnect(err: err)
    }
}


