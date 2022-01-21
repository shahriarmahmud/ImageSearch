//
//  ISImageDetailsView.swift
//  ImageSearch
//
//  Created by Shahriar Mahmud on 1/21/22.
//

import UIKit

protocol ISImageDetailsDelegate {
    func didDismiss()
}

class ISImageDetailsView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak private var backButton: UIButton!
    
    static let identifiere = "ISImageDetailsView"
    
    private var X: CGFloat = 0
    private var Y: CGFloat = 0
    private var Duration: CGFloat = 0
    var delegate: ISImageDetailsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    fileprivate func commonInit(){
        Bundle.main.loadNibNamed(ISImageDetailsView.identifiere, owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.image = nil
        addSubview(contentView)
    }
    public func showImage(image: UIImage, fromSize: CGSize, x: CGFloat, y: CGFloat, duration: CGFloat){
        X = x
        Y = y
        Duration = duration
        imageView.image = image
        showAnimation(fromSize: fromSize, x: x, y: y, duration: duration)
    }
    private func showAnimation(fromSize: CGSize, x: CGFloat, y: CGFloat, duration: CGFloat){
        let scale = CABasicAnimation()
        scale.keyPath = "transform.scale"
        let sz = ( fromSize.height * fromSize.width ) / (contentView.frame.size.height * contentView.frame.size.width)
        scale.fromValue = sz
        scale.toValue = 1
        scale.duration = duration
        imageView.layer.add(scale, forKey: "basic")
        
        let position = CABasicAnimation(keyPath: "position")
        position.fromValue = CGPoint(x: x, y: y)
        position.toValue = CGPoint(x: self.contentView.layer.frame.midX, y: self.contentView.layer.frame.midY)
        position.duration = duration
        position.fillMode = .forwards
        position.isRemovedOnCompletion = false
        position.beginTime = CACurrentMediaTime()
        imageView.layer.add(position, forKey: nil)
    }
    
    private func hideAnimation( x: CGFloat, y: CGFloat, duration: CGFloat){
        let scale = CABasicAnimation()
        scale.keyPath = "transform.scale"
        scale.fromValue = 1
        scale.toValue = 0
        scale.duration = duration
        imageView.layer.add(scale, forKey: "basic")
        
        let position = CABasicAnimation(keyPath: "position")
        position.fromValue = CGPoint(x: self.contentView.layer.frame.midX, y: self.contentView.layer.frame.midY)
        position.toValue = CGPoint(x: x, y: y)
        position.duration = duration
        position.fillMode = .forwards
        position.isRemovedOnCompletion = false
        position.beginTime = CACurrentMediaTime()
        imageView.layer.add(position, forKey: nil)
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        backButton.isHidden = true
        hideAnimation(x: X, y: Y, duration: Duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + (Duration - 0.05) ) {
            self.imageView.isHidden = true
            self.delegate?.didDismiss()
            self.removeFromSuperview()
        }
    }
}
