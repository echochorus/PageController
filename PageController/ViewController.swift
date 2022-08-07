//
//  ViewController.swift
//  PageController
//
//  Created by Eric Williams on 2022-08-07.
//

import UIKit

class ViewController: UIViewController {

    var numberOfPages: Int = 3
    private let scrollView = UIScrollView()
    private let pageControl: UIPageControl = {
        let pageControll = UIPageControl()
        return pageControll
    }()
    
    fileprivate func setupPageControl() {
        pageControl.numberOfPages = numberOfPages
        pageControl.backgroundColor = .systemGray
        pageControl.addTarget(self,
                              action: #selector(pageControlDidChange),
                              for: .valueChanged)
        view.addSubview(pageControl)
    }
    
    fileprivate func setupScrollview() {
        // Do any additional setup after loading the view.
        scrollView.delegate = self
        scrollView.backgroundColor = .darkGray
        view.addSubview(scrollView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollview()
        setupPageControl()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - 100)
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height-100, width: view.frame.size.width, height: 100)
        if scrollView.subviews.count == 2 {
            configureScrollView()
        }
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * view.frame.size.width, y: 0), animated: true)
    }
    
    private func configureScrollView() {
        scrollView.contentSize = CGSize(width: view.frame.size.width*CGFloat(numberOfPages),
                                        height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        let pageColours: [UIColor] = [
            .systemGray6,
            .systemGray4,
            .systemGray2
        ]
         
        for i in 0..<3 {
            let page = UIView(frame: CGRect(x: CGFloat(i) * view.frame.size.width,
                                            y: 0,
                                            width: view.frame.size.width,
                                            height: scrollView.frame.size.height))
            page.backgroundColor = pageColours[i]
            scrollView.addSubview(page)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
    }
}
