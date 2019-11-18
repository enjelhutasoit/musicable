//
//  OnboardingViewController.swift
//  VTune
//
//  Created by Stefani Kurnia Permata Dewi on 18/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var startBtn: GetStarted!
    @IBOutlet weak var scrollView: UIScrollView!{
           didSet{
               scrollView.delegate = self
           }
       }
       @IBOutlet weak var pageControl: UIPageControl!
       
       override func viewDidLoad() {
           super.viewDidLoad()
               startBtn.isHidden = true
              slides = createSlides()
              setupSlideScrollView(slides: slides)
                
               pageControl.numberOfPages = slides.count
               pageControl.currentPage = 0
               scrollView.showsHorizontalScrollIndicator = false
               scrollView.showsVerticalScrollIndicator = false
               view.bringSubviewToFront(pageControl)
               
       }
       
       @IBAction func nextButtonDidTapped(_ sender: Any) {
       UserDefaults.standard.set(true, forKey: "FinishOnboarding")
        print(UserDefaults.standard.bool(forKey: "FinishOnboarding"))
       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       guard let vc = storyboard.instantiateInitialViewController() else {return}
       vc.modalPresentationStyle = .fullScreen
       present(vc, animated: true, completion: nil)
          
           
       }
       
           var slides: [Slide] = []
       
       func showButton(button: UIButton, hidden: Bool){
           UIButton.transition(with: button, duration: 0.5, options: .transitionCrossDissolve, animations: {
               self.startBtn.isHidden = hidden
               self.skipBtn.isHidden = true
           })
       }
       
       func createSlides() -> [Slide] {
           
           let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
           slide1.imgBg.image = UIImage(named: "On Boarding Bg")
           slide1.imageView.image = UIImage(named: "On Boarding Icon Page 1")
           slide1.labelTitle.text = "Selamat Datang di VTune !"
           slide1.labelDesc.text = "“VTune” membantu Teman Tuli menikmati musik dengan getaran, gelombang musik, dan lirik."
           
           let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
           slide2.imgBg.image = UIImage(named: "On Boarding Bg")
           slide2.imageView.image = UIImage(named: "On Boarding Icon Page 2")
           slide2.labelTitle.text = "iTunes"
           slide2.labelDesc.text = "“VTune” mengambil lagu dari Perpustakaan Lagu iTunes."
           
           
           return [slide1, slide2]
       }
       
       func setupSlideScrollView(slides : [Slide]) {
                  scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                  scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
                  scrollView.isPagingEnabled = true
                  
                  for i in 0 ..< slides.count {
                      slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
                      scrollView.addSubview(slides[i])
                  }
              }
       func scrollViewDidScroll(_ scrollView: UIScrollView) {
                      let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
                      pageControl.currentPage = Int(pageIndex)
                      if pageControl.currentPage <= 0 {
                          startBtn.isHidden = true
                          skipBtn.isHidden = false
                      } else {
                          skipBtn.isHidden = true
                          showButton(button: startBtn, hidden: false)
                      }
               let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
               let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
                
                // vertical
                let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
                let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
                
                let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
                let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
                   
                   
             let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
                   
                   if(percentOffset.x > 0 && percentOffset.x <= 0.5) {
                       slides[0].imageView.transform = CGAffineTransform(scaleX: (0.5-percentOffset.x)/0.5, y: (0.5-percentOffset.x)/0.5)
         //              skipBtn.setTitle("Lewati", for: UIControl.State.normal)
         //              skipBtn.frame = CGRect(x: 21, y: 832, width: 45, height: 30)
        //               startBtn.isHidden = true
                   } else if(percentOffset.x > 0.5 && percentOffset.x <= 1.0) {
                       slides[1].imageView.transform = CGAffineTransform(scaleX: (percentOffset.x), y: (percentOffset.x))
             //          startBtn.isHidden = false
             //          startBtn.setTitle("Mulai", for: UIControl.State.normal)
              //         startBtn.frame = CGRect(x: 353, y: 832, width: 37, height: 30)
                    //   skipBtn.isHidden = true
                   }
               }
       
             func scrollView(_ scrollView: UIScrollView, didScrollToPercentageOffset percentageHorizontalOffset: CGFloat) {
                    if(pageControl.currentPage == 0) {
                        
                        let pageUnselectedColor: UIColor = fade(fromRed: 255/255, fromGreen: 255/255, fromBlue: 255/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
                        pageControl.pageIndicatorTintColor = pageUnselectedColor
                        
                        
                        let bgColor: UIColor = fade(fromRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1, toRed: 255/255, toGreen: 255/255, toBlue: 255/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
                        slides[pageControl.currentPage].backgroundColor = bgColor
                        
                        let pageSelectedColor: UIColor = fade(fromRed: 81/255, fromGreen: 36/255, fromBlue: 152/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
                        pageControl.currentPageIndicatorTintColor = pageSelectedColor
                    }
                }
                
                
                func fade(fromRed: CGFloat,
                          fromGreen: CGFloat,
                          fromBlue: CGFloat,
                          fromAlpha: CGFloat,
                          toRed: CGFloat,
                          toGreen: CGFloat,
                          toBlue: CGFloat,
                          toAlpha: CGFloat,
                          withPercentage percentage: CGFloat) -> UIColor {
                    
                    let red: CGFloat = (toRed - fromRed) * percentage + fromRed
                    let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
                    let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
                    let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
                    
                    // return the fade colour
                    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
                }

}
