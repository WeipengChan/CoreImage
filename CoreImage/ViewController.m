//
//  ViewController.m
//  CoreImage
//
//  Created by YunInfo on 14-5-12.
//  Copyright (c) 2014年 Robin. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
{
    CIContext *context;
    CIFilter *filter;
    CIImage *beginImage;
    UIImageOrientation orientation; // New!
}
@end


@implementation ViewController

- (IBAction)savePhoto:(UIButton *)sender
{
    CIImage * ouputImage = [filter outputImage];

    
    CGImageRef cgImg = [context createCGImage:ouputImage
                                             fromRect:[ouputImage extent]];
    // 4
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:cgImg
                                 metadata:[ouputImage properties]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              // 5
                              CGImageRelease(cgImg);
                          }];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Dispose of any resources that can be recreated.
    //1 filePath
    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"image" ofType:@"png"];
    NSURL * fileNameAndPath = [NSURL fileURLWithPath:filePath];
    
    
    beginImage =
    [CIImage imageWithContentsOfURL:fileNameAndPath];
    
    // 1
    context = [CIContext contextWithOptions:nil];
    
    filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues: kCIInputImageKey, beginImage,
                        @"inputIntensity", @0.8, nil];
    CIImage *outputImage = [filter outputImage];
    
    // 2
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    // 3
    UIImage *newImage = [UIImage imageWithCGImage:cgimg scale:1.0 orientation:orientation];
    self.imageView.image = newImage;
    
    // 4
    CGImageRelease(cgimg);
    
    //打印出所有可用的滤镜
    [self logAllFilters];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    
}

-(UIImage*)imageFromCIImage:(CIImage *)outputImage
{
    
    
    CGImageRef cgimg = [context createCGImage:outputImage
                                     fromRect:[outputImage extent]];
    
    UIImage * image = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    return image;
}

- (IBAction)amountSliderValueChanged:(UISlider *)slider
{
    
    float slideValue = slider.value;
    
    [filter setValue:@(slideValue)
              forKey:@"inputIntensity"];
    CIImage *outputImage = [filter outputImage];
  
    self.imageView.image = [self imageFromCIImage:outputImage];
    

}
- (IBAction)loadPhoto:(UIButton *)sender
{
    UIImagePickerController *pickerC =
    [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    [self presentViewController:pickerC animated:YES completion:nil];
}

#pragma mark - pickphoto delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *gotImage =
    [info objectForKey:UIImagePickerControllerOriginalImage];
    
    orientation = gotImage.imageOrientation;
    beginImage = [CIImage imageWithCGImage:gotImage.CGImage];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    [self amountSliderValueChanged:self.amountSlider];
    NSLog(@"%@", info);
}

- (void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logAllFilters {
    NSArray *properties = [CIFilter filterNamesInCategory:
                           kCICategoryBuiltIn];
    NSLog(@"%@", properties);
    for (NSString *filterName in properties) {
        CIFilter *fltr = [CIFilter filterWithName:filterName];
        NSLog(@"%@", [fltr attributes]);
    }
}

-(CIImage *)oldPhoto:(CIImage *)img withAmount:(float)intensity {
    
    // 1
    CIFilter *sepia = [CIFilter filterWithName:@"CISepiaTone"];
    [sepia setValue:img forKey:kCIInputImageKey];
    [sepia setValue:@(intensity) forKey:@"inputIntensity"];
    
    // 2
    CIFilter *random = [CIFilter filterWithName:@"CIRandomGenerator"];
    
    // 3
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:random.outputImage forKey:kCIInputImageKey];
    [lighten setValue:@(1 - intensity) forKey:@"inputBrightness"];
    [lighten setValue:@0.0 forKey:@"inputSaturation"];
    
    // 4
    CIImage *croppedImage = [lighten.outputImage imageByCroppingToRect:[beginImage extent]];
    
    // 5
    CIFilter *composite = [CIFilter filterWithName:@"CIHardLightBlendMode"];
    [composite setValue:sepia.outputImage forKey:kCIInputImageKey];
    [composite setValue:croppedImage forKey:kCIInputBackgroundImageKey];
    
    // 6
    CIFilter *vignette = [CIFilter filterWithName:@"CIVignette"];
    [vignette setValue:composite.outputImage forKey:kCIInputImageKey];
    [vignette setValue:@(intensity * 2) forKey:@"inputIntensity"];
    [vignette setValue:@(intensity * 30) forKey:@"inputRadius"];
    
    // 7
    return vignette.outputImage;
}
@end
