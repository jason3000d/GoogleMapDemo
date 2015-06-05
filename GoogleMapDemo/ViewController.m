//
//  ViewController.m
//  GoogleMapDemo
//
//  Created by Seraph.Lin on 2015/5/28.
//  Copyright (c) 2015年 CP-9. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSPanoramaView *panoView;
@property (strong, nonatomic) UIImage *imgEnable;
@property (strong, nonatomic) UIImage *imgEvent;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    _geocoder   = [[CLGeocoder alloc] init];
    _imgEnable  = [UIImage imageNamed:@"acti_a1_enable"];
    _imgEvent   = [UIImage imageNamed:@"acti_a1_event"];


    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    NSLog(@"User's location: %@", _mapView.myLocation);
    _mapView.settings.myLocationButton = YES;
    _mapView.settings.compassButton = YES;
    _mapView.settings.indoorPicker = YES;
    _mapView.mapType = kGMSTypeNormal;
    _mapView.indoorEnabled = YES;
    _mapView.accessibilityElementsHidden = YES;
    _mapView.padding = UIEdgeInsetsMake(20, 0, 0, 0);
    self.view = _mapView;
    
#if 0

    //Create a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = _mapView;
    
    CLLocationCoordinate2D vancouver = CLLocationCoordinate2DMake(49.26, -123.11);
    CLLocationCoordinate2D calgary = CLLocationCoordinate2DMake(51.05, -114.05);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:vancouver coordinate:calgary];
    GMSCameraPosition *newCamera = [_mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
    _mapView.camera = newCamera;
    
    //Zoom in one zoom level
    GMSCameraUpdate *zoomCamera = [GMSCameraUpdate zoomIn];
    [_mapView animateWithCameraUpdate:zoomCamera];
    
    //Center the camera
    GMSCameraUpdate *vancouverCam = [GMSCameraUpdate setTarget:vancouver];
    [_mapView animateWithCameraUpdate:vancouverCam];
    
    //Move the camera 100 points down, and 200 points to the right.
    GMSCameraUpdate *downwards = [GMSCameraUpdate scrollByX:100 Y:200];
    [_mapView animateWithCameraUpdate:downwards];
    
    
    
#endif
    
#if 0
    _panoView = [[GMSPanoramaView alloc] initWithFrame:CGRectZero];
    self.view = _panoView;
    
    [_panoView moveNearCoordinate:CLLocationCoordinate2DMake(-33.732, 150.312)];
    GMSPanoramaCamera *camera = [GMSPanoramaCamera cameraWithHeading:180 pitch:-30 zoom:1];
    _panoView.camera = camera;
    
    // Create a marker at the Eiffel Tower
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(-33.730,150.310);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.panoramaView = _panoView;

#endif
    
#if 0
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(10, 10);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = @"Hello, world!";
    marker.map = _mapView;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [UIImage imageNamed:@"acti_a1_enable"];
#endif
    
#if 0
    CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake(37.35, -122.0);
    GMSCircle *circ = [GMSCircle circleWithPosition:circleCenter radius:1000];
    circ.map = _mapView;
    [_mapView animateToLocation:circleCenter];
    
#endif
    
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    switchBtn.frame = CGRectMake(0, 0, 80, 80);
    [switchBtn setTitle:@"Switch" forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(changeIcon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchBtn];
    
}

- (void)changeIcon:(id)sender {
    GMSMarker *marker = _mapView.selectedMarker;
    if (marker) {
        if (marker.icon != _imgEnable) {
            dispatch_async(dispatch_get_main_queue(), ^{ marker.icon = _imgEnable; });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ marker.icon = _imgEvent; });
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMSMapViewDelegate methods
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"You tapped at %f, %f", coordinate.latitude, coordinate.longitude);
    
    [_mapView clear];

    id handler = ^(NSArray *placemark, NSError *error){
        if (error == nil) {
            @autoreleasepool {                
                CLPlacemark *result = placemark.firstObject;
                GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
                marker.title = result.name;
                marker.snippet = result.thoroughfare;
                marker.appearAnimation = kGMSMarkerAnimationPop;
                //            marker.icon = [UIImage imageNamed:@"acti_a1_enable"];
                //            marker.groundAnchor = CGPointMake(0.5, 0.5);
                //            marker.rotation = 90;
                marker.map = _mapView;
                
                
                NSAttributedString *attrStr = [self attributedStringWithString:result.name fontSize:18];
                UILabel *label = [[UILabel alloc] init];
                label.attributedText = attrStr;
                [label sizeToFit];
                
                UIImage *icon = [self renderImageWithView:label];
                marker.icon = icon;
                
            }
        }
    };
    
    [_geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionHandler:handler];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
//    dispatch_async(dispatch_get_main_queue(), ^{ marker.icon = _imgEvent; });
    
    
    return NO;
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
//    [_mapView clear];
    mapView.selectedMarker.icon = nil;
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
#if 0
    id handler = ^(NSArray *placemark, NSError *error){
        if (error == nil) {
            CLPlacemark *result = placemark.firstObject;
            GMSMarker *marker = [GMSMarker markerWithPosition:position.target];
            marker.icon = [GMSMarker markerImageWithColor:[UIColor blackColor]];
            marker.title = result.name;
            marker.snippet = result.thoroughfare;
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.icon = [UIImage imageNamed:@"acti_a1_enable"];
//            marker.groundAnchor = CGPointMake(0.5, 0.5);
//            marker.rotation = 90;
            marker.map = _mapView;
        }
    };
    [_geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:position.target.latitude longitude:position.target.longitude] completionHandler:handler];
#endif
    
#if 0
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:CLLocationCoordinate2DMake(37.36, -122.0)];
    [path addCoordinate:CLLocationCoordinate2DMake(37.45, -122.0)];
    [path addCoordinate:CLLocationCoordinate2DMake(37.45, -122.2)];
    [path addCoordinate:CLLocationCoordinate2DMake(37.36, -122.2)];
    [path addCoordinate:CLLocationCoordinate2DMake(37.36, -122.0)];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 5;
    polyline.strokeColor = [UIColor blueColor];
//    polyline.geodesic = YES;
    
    polyline.map = _mapView;
#endif
    
#if 0
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(40.712216,-74.22655);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(40.773941,-74.12544);
    GMSCoordinateBounds *overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:southWest coordinate:northEast];
    UIImage *icon = [UIImage imageNamed:@"acti_a1_enable"];
    GMSGroundOverlay *overlay = [GMSGroundOverlay groundOverlayWithBounds:overlayBounds icon:icon];
    overlay.map = _mapView;
    
#endif
}

#pragma mark - Assistant methods
- (UIImage *)renderImageWithView:(UIView *)sourceView {

    UIImageView *imgView = [[UIImageView alloc] initWithImage:_imgEnable];
    CGRect renderRect = CGRectMake(0, 0,
                                   MAX(CGRectGetWidth(imgView.bounds), CGRectGetWidth(sourceView.bounds)),
                                   CGRectGetHeight(imgView.bounds) + CGRectGetHeight(sourceView.bounds));
    
    UIGraphicsBeginImageContextWithOptions(renderRect.size, NO, [UIScreen mainScreen].scale);
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGRectGetWidth(renderRect)/2 - CGRectGetWidth(imgView.frame)/2, 0);
    [imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, CGRectGetHeight(imgView.frame));
    [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return renderedImage;
}

- (NSAttributedString *)attributedStringWithString:(NSString *)textString fontSize:(CGFloat)fontSize {
    
    NSShadow *shadowAttr = [[NSShadow alloc] init];
    shadowAttr.shadowColor      = [UIColor blackColor];
    shadowAttr.shadowBlurRadius = 3;
    NSDictionary *attrDict = @{NSFontAttributeName              : [UIFont boldSystemFontOfSize:fontSize],
                               NSForegroundColorAttributeName   : [UIColor whiteColor],
                               NSShadowAttributeName            : shadowAttr
                               };
    return [[NSAttributedString alloc] initWithString:textString attributes:attrDict];
}

@end
