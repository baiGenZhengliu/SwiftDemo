//
//  ViewController.swift
//  SwiftDemo
//
//  Created by HuJiazhou on 16/7/25.
//  Copyright © 2016年 HuJiazhou. All rights reserved.
//

import UIKit

// 系统下载刷新
let refreshControl:Demo = Demo()

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tabelview = UITableView(frame: view.bounds, style: UITableViewStyle.Plain)
        
        tabelview.tableHeaderView?.backgroundColor = UIColor.redColor()
        
        view.addSubview(tabelview)

        tabelview.addSubview(refreshControl);

      
       }
  
    }


    
    func yanchi(backrefresh:()->()){
    
    dispatch_async(dispatch_get_global_queue(0, 0)) { () -> Void in
       
        NSThread.sleepForTimeInterval(3)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            backrefresh()
            
            
        })
        
        
        
        }
    
    }
    



