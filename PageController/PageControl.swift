//
//  PageControl.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-07.
//

import UIKit

class PageControl: UIView {
    var numberOfPages: Int = 3
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        return scrollView
    }()
    private let pageControl: UIPageControl = {
        let pageControll = UIPageControl()
        return pageControll
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        setupScrollView()
        setupPageControl()
        
        addConstraintsToScrollView()
        addConstraintsToPageControl()
        
        if scrollView.subviews.count == 0 {
            configureScrollView()
        }
    }
    
    fileprivate func setupPageControl() {
        pageControl.numberOfPages = numberOfPages
        pageControl.backgroundColor = .clear //.systemGray
        pageControl.addTarget(self,
                              action: #selector(pageControlDidChange),
                              for: .valueChanged)
        self.addSubview(pageControl)
    }
    
    fileprivate func addConstraintsToPageControl() {
        pageControl.bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: 100)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        let g = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControl.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    fileprivate func setupScrollView() {
        // Do any additional setup after loading the view.
        scrollView.delegate = self
        scrollView.backgroundColor = .darkGray
        
        scrollView.contentSize = CGSize(width: self.bounds.width*CGFloat(numberOfPages),
                                        height: scrollView.bounds.height)
        scrollView.isPagingEnabled = true
        self.addSubview(scrollView)
    }
    
    fileprivate func addConstraintsToScrollView() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height - 100)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let g = self.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1)
        ])
        
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * self.bounds.width, y: 0), animated: true)
    }
    
    func configureScrollView() {
        scrollView.contentSize = CGSize(width: self.bounds.width*CGFloat(numberOfPages),
                                        height: scrollView.bounds.height)
        scrollView.isPagingEnabled = true
        let pageColours: [UIColor] = [
            .systemGray6,
            .systemGray4,
            .systemGray2
        ]
         
        for i in 0..<3 {
            let page = UIView(frame: CGRect(x: CGFloat(i) * self.bounds.width,
                                            y: 0,
                                            width: self.bounds.width,
                                            height: self.bounds.height))
            page.backgroundColor = pageColours[i]
            scrollView.addSubview(page)
        }
    }
}

extension PageControl: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
    }
}
