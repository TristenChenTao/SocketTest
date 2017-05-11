//
//  ClientViewController.swift
//  SocketTest
//
//  Created by yiyou on 2017/5/9.
//  Copyright © 2017年 esgame. All rights reserved.
//

import UIKit

class ClientViewController: UIViewController {
    
    //IP地址
    @IBOutlet weak var ipTF: UITextField!
    
    //端口
    @IBOutlet weak var portTF: UITextField!
    
    //消息
    @IBOutlet weak var msgTF: UITextField!
    
    //信息显示
    @IBOutlet weak var infoTV: UITextView!
    
    var socketManager: SocketManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socketManager = SocketManager()
        socketManager?.delegate = self
    }
    
    func addText(text: String) {
        infoTV.text = infoTV.text.appendingFormat("%@\n", text)
    }
    
    //连接
    @IBAction func connectionAct(sender: AnyObject) {
        if (ipTF.text?.isEmpty)! || (portTF.text?.isEmpty)! {
            addText(text:"IP和端口不能为空")
            return
        }
        

        do {
            try socketManager?.connect(toHost: ipTF.text!, onPort: UInt16(portTF.text!)!)
            addText(text: "连接成功")
        }catch _ {
            addText(text: "连接失败")
        }
    }
    
    //断开
    @IBAction func disconnectAct(sender: AnyObject) {
        socketManager?.disconnect()
        addText(text: "断开连接")
    }
    
    //发送
    @IBAction func sendMsgAct(sender: AnyObject) {
        addText(text: "发送消息：\(msgTF.text!)")
        socketManager?.write(msgTF.text!)
    }
}

extension ClientViewController: SocketToolDelegate {
    
    
    func socketDidConnect() {
        addText(text: "与服务器连接成功")
    }
    
    func socketDidDisconnect(err: Error?) {
        addText(text: "与服务器断开连接")
    }
    
    func socketDidReceivedText(_ text: String, tag: Int) {
        DispatchQueue.main.async {
            self.addText(text: "收到服务端消息：\(text)")
        }
    }
    
}
