//
//  ViewController.swift
//  socket-test
//
//  Created by DevHive.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    private var webSocket : URLSessionWebSocketTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        guard let host = ProcessInfo.processInfo.environment["ws_address"],
              let port = ProcessInfo.processInfo.environment["ws_port"] else {
            print("unvalid environment")
            return
        }
        let url = URL(string: "ws://\(host):\(port)")
        webSocket = session.webSocketTask(with: url!)
        webSocket?.resume()
        self.receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected to server")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Disconnect from Server \(String(describing: reason))")
    }
    
    func receive(){
        let workItem = DispatchWorkItem{ [weak self] in
            self?.webSocket?.receive(completionHandler: { result in
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let strMessage):
                        if strMessage.contains("ping") {
                            self?.webSocket?.send(URLSessionWebSocketTask.Message.string("pong"), completionHandler: { error in
                                if error == nil {
                                    print("handshaked")
                                } else {
                                    print(error as Any)
                                }
                            })
                        }
                    default:
                        break
                    }
                case .failure(let error):
                    print("Error Receiving \(error)")
                }
                self?.receive()
            })
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1 , execute: workItem)
    }
}

