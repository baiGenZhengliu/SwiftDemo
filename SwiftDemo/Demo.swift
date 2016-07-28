//
//  Demo.swift
//  SwiftDemo
//
//  Created by HuJiazhou on 16/7/25.
//  Copyright © 2016年 HuJiazhou. All rights reserved.
//

import UIKit

// 代表当前控件的状态
enum SHRefreshControlState: Int {
    // 正常
    case Normal = 0
    // 下拉中
    case Pulling = 1
    // 刷新中
    case Refreshing = 2
}

// 控件的高度
let RefreshControlH: CGFloat = 120

class Demo: UIControl {
    
    var contentY: CGFloat?
    
    var contentInsetTop: CGFloat?
    
    var scrollView: UIScrollView?
    
    // 记录当前状态
    var shState:SHRefreshControlState = .Normal{
        didSet{
            switch shState {
            case .Normal:
                //快递员
                self.pawMan.stopAnimating()
                self.pawMan.hidden = true
                self.boxImageView.transform = CGAffineTransformIdentity;
                // 判断上一个状态为刷新中
                if oldValue == .Refreshing {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.scrollView?.contentInset.top -= RefreshControlH
                        }, completion: { (_) -> Void in
                            // 显示显示盒子
                            self.pawMan.stopAnimating()
                            self.pawMan.hidden = true
                            self.boxImageView.hidden = false
                            self.pictManView.hidden = false
                    })
                }
                
            case .Pulling:

                //下拉刷新中
                messageLabel.hidden = false
                messageLabel.text = "让购物更便捷\n\("下拉刷新")"
                
                //box
                let Ttraslate:CGAffineTransform =  CGAffineTransformMakeTranslation((contentY!+26)/5, -(contentY!+26)/10)
                
                let traslate:CGAffineTransform = CGAffineTransformScale(Ttraslate, -(contentY!+64)/80, -(contentY!+64)/80)
                
                self.boxImageView.transform = traslate
    
                
                //单人
                let mantraslate:CGAffineTransform =  CGAffineTransformTranslate(self.transform, -(contentY!+26)/5, -(contentY!+26)/101)
                
                let manttraslate: CGAffineTransform = CGAffineTransformScale( mantraslate, -(contentY!+64)/90, -(contentY!+64)/90)
                
                self.pictManView.transform = manttraslate
                
                
            case .Refreshing:
                
                
                yanchi { () -> () in
                    
                refreshControl.endRefreshing()
                    
                }
                messageLabel.hidden = false
                
                // 设置动画 增加scrollView 滑动距离
                // 隐藏快递员
                pictManView.hidden = true
                //隐藏快递
                boxImageView.hidden = true
                //显示速度
                speedPic.hidden = false
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    if self.scrollView?.contentInset.top < 164 {
                    self.scrollView?.contentInset.top += RefreshControlH
                     }
                    }, completion: { (_) -> Void in
                        // 告知外界可以刷新了
                        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: CGRect(x: 0, y: -RefreshControlH, width: UIScreen.mainScreen().bounds.width, height: RefreshControlH))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 供外界调用的方法
    func endRefreshing(){
        // 01 当前的状态改成正常
        // 02 减去100
        shState = .Normal
    }
    
    // 该控件将要加载到那个父视图
    override func willMoveToSuperview(newSuperview: UIView?) {
        // 判断他是否为nil 而且是可以滚动的
        guard let scrollView = newSuperview as? UIScrollView else{
            return
        }
        // kvo
        self.scrollView = scrollView
        // 监听scrollView 使用kvo
        self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    // 得到scrollView 的变化
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        getSHRefreshControlState(self.scrollView!.contentOffset.y)
    }
    /*
    
    - 当用户拖动tableView 而且没有松手
    - 当contentOffset.y > -164 显示正常 且当前状态为下拉中
    - 当contentOffset.y <= -164 下拉中 且当前的状态为正常
    - 当用户拖动tableView 而且松手了
    -  如果当前的状态为 下拉中   ---》刷新中
    - 如果用户松手了 而且当前的状态为下拉中 才能进入刷新中
    */
    // 判断当前刷新控件显示状态
    func getSHRefreshControlState(contentOffsetY: CGFloat){
        
        contentY = contentOffsetY
        
        print(contentOffsetY)
        // -64
        contentInsetTop = self.scrollView?.contentInset.top ?? 0
        
        // 代表用户正在拖动
        if self.scrollView!.dragging {
            
            if contentOffsetY > -contentInsetTop! - RefreshControlH && contentOffsetY < -contentInsetTop!{
                
                shState = .Pulling
            }
 
        }else {
            // 代表用户松手了
            if shState == .Pulling {
                
                shState = .Refreshing
                
                self.pawMan.hidden = false
                
                self.pawMan.stopAnimating()
  
            }
        }
    }
    
    // MARK: - 设置视图
    private func setupUI(){
        // 添加控件
        addSubview(messageLabel)
        addSubview(boxImageView)
        addSubview(pawMan)
        addSubview(pictManView)
        addSubview(speedPic)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 30))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 15))
        
        boxImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: boxImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -30))
        addConstraint(NSLayoutConstraint(item: boxImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        pawMan.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: pawMan, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -70))
        addConstraint(NSLayoutConstraint(item: pawMan, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 10))
        
        pictManView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: pictManView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -120))
        addConstraint(NSLayoutConstraint(item: pictManView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 10))
        
        
        speedPic.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: speedPic, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -140))
        addConstraint(NSLayoutConstraint(item: speedPic, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 15))
        
    }
    
    deinit{
        
        self.scrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - 懒加载控件
    private lazy var messageLabel: UILabel = {
        let lab = UILabel()
        lab.text = "让购物更便捷\n\("加载中...")"
        lab.numberOfLines = 0
        lab.textColor = UIColor.grayColor()
        lab.font = UIFont.systemFontOfSize(14)
        lab.hidden = true
        return lab
    }()
    //加载box
    private lazy var boxImageView: UIImageView = UIImageView(image: UIImage(named: "box"))
    
    //快递员
    lazy  var pawMan :UIImageView = {
        
        let imageview = UIImageView()
        let imagearray:[UIImage] = [UIImage(named: "deliveryStaff")!,
            UIImage(named: "deliveryStaff1")!,
            UIImage(named: "deliveryStaff2")!,
            UIImage(named: "deliveryStaff3")!
            
        ]
        
        imageview.image = UIImage.animatedImageWithImages(imagearray, duration: 0.3)
        imageview.hidden = true
        return imageview
    }()
    
    //单人图片
    lazy var pictManView:UIImageView = {
        
        let imageview = UIImageView()
        
        imageview.image = UIImage(named: "staticDeliveryStaff")
        
        return imageview
    }()
    
    lazy var speedPic:UIImageView = {
        
        let imageview = UIImageView()
        
        imageview.image = UIImage(named: "speed")
        
        imageview.hidden = true //默认隐藏
        
        return imageview
        
    }()
    
}
