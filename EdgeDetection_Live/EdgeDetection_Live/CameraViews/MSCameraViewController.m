//
//  CameraViewController.m
//  FaceDetection
//
//  Created by mostafizur on 5/3/17.
//  Copyright © 2017 Mostafizur Rahman. All rights reserved.
//

#import "MSCameraViewController.h"


#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MSCameraViewController (){
    TCCameraSession *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    BOOL glcontextSetupCompleted;
}
@end

@implementation MSCameraViewController
@synthesize openglView;






- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!glcontextSetupCompleted){
        [openglView setupContext];
        captureSession = [[TCCameraSession alloc] init];
        [captureSession initSessionWithView:openglView];
    }
    [captureSession startSession];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [captureSession stopSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private methods



- (IBAction)captureImage:(id)sender {
    [captureSession capturePhoto];
    NSLog(@"capture image");
}


@end
