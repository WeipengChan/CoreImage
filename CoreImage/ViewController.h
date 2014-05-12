//
//  ViewController.h
//  CoreImage
//
//  Created by YunInfo on 14-5-12.
//  Copyright (c) 2014年 Robin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)amountSliderValueChanged:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UISlider *amountSlider;

- (IBAction)loadPhoto:(UIButton *)sender;

@end
