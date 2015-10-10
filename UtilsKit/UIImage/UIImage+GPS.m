//
// Created by sunlantao on 15/4/16.
// Copyright (c) 2015 sunlantao. All rights reserved.
//

#import "UIImage+GPS.h"
#import <ImageIO/ImageIO.h>
#import <MapKit/MapKit.h>


NSDictionary * gpsDictionaryForLocation(CLLocation *location){
    CLLocationDegrees exifLatitude  = location.coordinate.latitude;
    CLLocationDegrees exifLongitude = location.coordinate.longitude;

    NSString * latRef;
    NSString * longRef;
    if (exifLatitude < 0.0) {
        exifLatitude = exifLatitude * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }

    if (exifLongitude < 0.0) {
        exifLongitude = exifLongitude * -1.0f;
        longRef = @"W";
    } else {
        longRef = @"E";
    }

    return @{
            (NSString *) kCGImagePropertyGPSTimeStamp: location.timestamp,
            (NSString *) kCGImagePropertyGPSLatitudeRef: latRef,
            (NSString *) kCGImagePropertyGPSLatitude: @(exifLatitude),
            (NSString*)kCGImagePropertyGPSLongitudeRef:longRef,
            (NSString *)kCGImagePropertyGPSLongitude:  @(exifLongitude),
            (NSString*)kCGImagePropertyGPSDOP:@(location.horizontalAccuracy),
            (NSString*)kCGImagePropertyGPSAltitude:  @(location.altitude)
    };

}

@implementation UIImage(GPSImage)

+(UIImage *)makeGPSImage:(UIImage *)image location:(CLLocation *)location {

    NSData *data = UIImageJPEGRepresentation(image, 1.f);

    if (!data)
        return nil;

    CGImageSourceRef source =CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSDictionary *dict = (__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);

    NSMutableDictionary *metaDataDic = [dict mutableCopy];

    metaDataDic[(NSString *) kCGImagePropertyGPSDictionary] = gpsDictionaryForLocation(location);

    //其他exif信息
    NSMutableDictionary *exifDic =[metaDataDic[(NSString *) kCGImagePropertyExifDictionary] mutableCopy];
    if(!exifDic) {
        exifDic = [NSMutableDictionary dictionary];
    }
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc]init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *EXIFFormattedCreatedDate =[dateFormatter stringFromDate:[NSDate date]];
    exifDic[(NSString *) kCGImagePropertyExifDateTimeDigitized] = EXIFFormattedCreatedDate;

    metaDataDic[(NSString *) kCGImagePropertyExifDictionary] = exifDic;

    //写进图片
    CFStringRef UTI = CGImageSourceGetType(source);
    NSMutableData *data1 = [NSMutableData data];
    CGImageDestinationRef destination =CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data1, UTI, 1,NULL);
    if(!destination) {
        CFRelease((__bridge CFTypeRef)(dict));
        CFRelease(source);
        return nil;
    }

    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)metaDataDic);
    if(!CGImageDestinationFinalize(destination)) {
        CFRelease((__bridge CFTypeRef)(dict));
        CFRelease(destination);
        CFRelease(source);
        return nil;
    }

    CFRelease(destination);
    CFRelease(source);
    CFRelease((__bridge CFTypeRef)(dict));

    return [UIImage imageWithData:data1];
}

//获取图片的exif、gps等信息(path：图片路径)
+(BOOL)getGPSByImageFilePath:(NSString*)path latitude:(double*)lati longitude:(double*)longi date:(NSString **)dateString
{
    if(!path || [path length] == 0){

        return NO;
    }

    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageSourceRef source =CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if(!source)
    {
        return NO;
    }

    NSDictionary *dd = @{(NSString *) kCGImageSourceShouldCache : @NO};
    CFDictionaryRef dict =CGImageSourceCopyPropertiesAtIndex(source, 0, (__bridge CFDictionaryRef)dd);
    if(!dict){
        CFRelease(source);
        return NO;
    }

    CFDictionaryRef exif =CFDictionaryGetValue(dict, kCGImagePropertyExifDictionary);
    if(exif){
    }

    //获得GPS 的 dictionary
    CFDictionaryRef gps =CFDictionaryGetValue(dict, kCGImagePropertyGPSDictionary);
    if(!gps){
        CFRelease(dict);
        CFRelease(source);
        return NO;
    }

    //获取经纬度
    NSString *lat = (__bridge NSString*)CFDictionaryGetValue(gps, kCGImagePropertyGPSLatitude);
    NSString *lon = (__bridge NSString*)CFDictionaryGetValue(gps, kCGImagePropertyGPSLongitude);

    *lati = [lat doubleValue];
    *longi = [lon doubleValue];

    if(exif){
        //日期
        *dateString = (__bridge NSString*)(CFDictionaryGetValue(exif, kCGImagePropertyExifDateTimeDigitized));
    }

    CFRelease(dict);
    CFRelease(source);
   // CFRelease(exif);
  //  CFRelease(gps);

    return YES;
}
@end