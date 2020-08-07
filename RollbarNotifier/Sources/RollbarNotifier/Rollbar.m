//  Copyright (c) 2018 Rollbar, Inc. All rights reserved.

@import RollbarCommon;

#import "Rollbar.h"
//#import "RollbarKSCrashInstallation.h"
#import "RollbarLogger.h"
#import "RollbarConfig.h"
#import "RollbarDestination.h"
#import "RollbarTelemetryOptions.h"
#import "RollbarTelemetryOptionsObserver.h"
#import "RollbarScrubbingOptions.h"

@implementation Rollbar

static RollbarLogger *logger = nil;
static RollbarTelemetryOptionsObserver *telemetryOptionsObserver = nil;

+ (void)initialize {
    if (self == [Rollbar class]) {
        telemetryOptionsObserver = [RollbarTelemetryOptionsObserver new];
    }
}

//+ (void)enableCrashReporter {
//    
//    RollbarKSCrashInstallation *installation = [RollbarKSCrashInstallation sharedInstance];
//    [installation install];
//    [installation sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error) {
//        if (error) {
//            SdkLog(@"Could not enable crash reporter: %@", [error localizedDescription]);
//        } else if (completed) {
//            [loger processSavedItems];
//        }
//    }];
//}

+ (void)initWithAccessToken:(NSString *)accessToken {

    [Rollbar initWithAccessToken:accessToken
                   configuration:nil];
}

+ (void)initWithConfiguration:(RollbarConfig *)configuration {

    [Rollbar initWithAccessToken:nil
                   configuration:configuration];
//             enableCrashReporter:YES];
}

+ (void)initWithAccessToken:(NSString *)accessToken
              configuration:(RollbarConfig *)configuration {
//        enableCrashReporter:(BOOL)enable {

    [RollbarTelemetry sharedInstance]; // Load saved data, if any
    if (logger) {
        RollbarSdkLog(@"Rollbar has already been initialized.");
    } else {
        RollbarConfig *config = configuration ? configuration : [RollbarConfig new];
        if (accessToken && accessToken.length > 0) {
            config.destination.accessToken = accessToken;
        }
        [Rollbar updateConfiguration:config];
//        if (enable) {
//            [Rollbar enableCrashReporter];
//        }
//        [logger.configuration save];
    }
}

+ (RollbarConfig *)currentConfiguration {
    
    return logger.configuration;
}

+ (RollbarLogger *)currentLogger {
    
    return logger;
}

+ (void)updateConfiguration:(RollbarConfig *)configuration {
    
//    if (logger && logger.configuration && logger.configuration.telemetry) {
//        [telemetryOptionsObserver unregisterAsObserverForTelemetryOptions:logger.configuration.telemetry];
//    }

    if (logger) {
        [logger updateConfiguration:configuration];
    }
    else {
        logger = [[RollbarLogger alloc] initWithConfiguration:configuration];
    }
    
//    if (logger && logger.configuration && logger.configuration.telemetry) {
//        [telemetryOptionsObserver registerAsObserverForTelemetryOptions:logger.configuration.telemetry];
//    }
    
    if (configuration && configuration.telemetry) {
        [RollbarTelemetry sharedInstance].enabled = configuration.telemetry.enabled;
        [RollbarTelemetry sharedInstance].scrubViewInputs = configuration.telemetry.viewInputsScrubber.enabled;
        [RollbarTelemetry sharedInstance].viewInputsToScrub =
            [NSSet setWithArray:configuration.telemetry.viewInputsScrubber.scrubFields].mutableCopy;
        [[RollbarTelemetry sharedInstance] setCaptureLog:configuration.telemetry.captureLog];
        [[RollbarTelemetry sharedInstance] setDataLimit:configuration.telemetry.maximumTelemetryData];
    }
}

+ (void)reapplyConfiguration {
    [Rollbar updateConfiguration:Rollbar.currentConfiguration];
}

#pragma mark - Logging methods

+ (void)log:(RollbarLevel)level
    message:(NSString *)message {

    [Rollbar log:level message:message exception:nil];
}

+ (void)log:(RollbarLevel)level
    message:(NSString *)message
  exception:(NSException *)exception {

    [Rollbar log:level message:message exception:exception data:nil];
}

+ (void)log:(RollbarLevel)level
    message:(NSString *)message
  exception:(NSException *)exception
       data:(NSDictionary<NSString *, NSObject *> *)data {

    [Rollbar log:level message:message exception:exception data:data context:nil];
}

+ (void)log:(RollbarLevel)level
    message:(NSString *)message
  exception:(NSException *)exception
       data:(NSDictionary<NSString *, NSObject *> *)data
    context:(NSString *)context {

    [logger log:[RollbarLevelUtil RollbarLevelToString:level]
          message:message
        exception:exception
             data:data
          context:context];
}

// Debug

+ (void)debug:(NSString *)message {

    [Rollbar debug:message exception:nil];
}

+ (void)debug:(NSString *)message
    exception:(NSException *)exception {

    [Rollbar debug:message
         exception:exception
              data:nil];
}

+ (void)debug:(NSString *)message
    exception:(NSException *)exception
         data:(NSDictionary<NSString *, NSObject *> *)data {

    [Rollbar debug:message
         exception:exception
              data:data
           context:nil];
}

+ (void)debug:(NSString *)message
    exception:(NSException *)exception
         data:(NSDictionary<NSString *, NSObject *> *)data
      context:(NSString *)context {

    [Rollbar log:RollbarLevel_Debug
         message:message
       exception:exception
            data:data
         context:context];
}

// Info

+ (void)info:(NSString *)message {

    [Rollbar info:message exception:nil];
}

+ (void)info:(NSString *)message
   exception:(NSException *)exception {

    [Rollbar info:message
        exception:exception
             data:nil];
}

+ (void)info:(NSString *)message
   exception:(NSException *)exception
        data:(NSDictionary<NSString *, NSObject *> *)data {

    [Rollbar info:message
        exception:exception
             data:data
          context:nil];
}

+ (void)info:(NSString *)message
   exception:(NSException *)exception
        data:(NSDictionary<NSString *, NSObject *> *)data
     context:(NSString *)context {

    [Rollbar log:RollbarLevel_Info
         message:message
       exception:exception
            data:data
         context:context];
}

// Warning

+ (void)warning:(NSString *)message {

    [Rollbar warning:message
        exception:nil];
}

+ (void)warning:(NSString *)message
      exception:(NSException *)exception {

    [Rollbar warning:message
        exception:exception
             data:nil];
}

+ (void)warning:(NSString *)message
      exception:(NSException *)exception
           data:(NSDictionary<NSString *, NSObject *> *)data {

    [Rollbar warning:message
        exception:exception
             data:data
          context:nil];
}

+ (void)warning:(NSString *)message
      exception:(NSException *)exception
           data:(NSDictionary<NSString *, NSObject *> *)data
        context:(NSString *)context {

    [Rollbar log:RollbarLevel_Warning
         message:message
       exception:exception
            data:data
         context:context];
}

// Error

+ (void)error:(NSString *)message {

    [Rollbar error:message
         exception:nil];
}

+ (void)error:(NSString *)message
    exception:(NSException *)exception {

    [Rollbar error:message
         exception:exception
              data:nil];
}

+ (void)error:(NSString *)message
    exception:(NSException *)exception
         data:(NSDictionary<NSString *, NSObject *> *)data {

    [Rollbar error:message
         exception:exception
              data:data
           context:nil];
}

+ (void)error:(NSString *)message
    exception:(NSException *)exception
         data:(NSDictionary<NSString *, NSObject *> *)data
      context:(NSString *)context {

    [Rollbar log:RollbarLevel_Error
         message:message
       exception:exception
            data:data
         context:context];
}

// Critical

+ (void)critical:(NSString *)message {
    [Rollbar critical:message exception:nil];
}

+ (void)critical:(NSString *)message
       exception:(NSException *)exception {

    [Rollbar critical:message
            exception:exception
                 data:nil];
}

+ (void)critical:(NSString *)message
       exception:(NSException *)exception
            data:(NSDictionary<NSString *, NSObject *> *)data {

    [Rollbar critical:message
            exception:exception
                 data:data
              context:nil];
}

+ (void)critical:(NSString *)message
       exception:(NSException *)exception
            data:(NSDictionary<NSString *, NSObject *> *)data
         context:(NSString *)context {

    [Rollbar log:RollbarLevel_Critical
         message:message
       exception:exception
            data:data
         context:context];
}

+ (void)sendJsonPayload:(NSData *)payload {

    [logger sendPayload:payload];
}


// Crash Report

+ (void)logCrashReport:(NSString *)crashReport {

    [logger logCrashReport:crashReport];
}

#pragma mark - Telemetry logging methods

#pragma mark - Dom

+ (void)recordViewEventForLevel:(RollbarLevel)level
                        element:(NSString *)element {
    [self recordViewEventForLevel:level
                          element:element
                        extraData:nil];
}

+ (void)recordViewEventForLevel:(RollbarLevel)level
                        element:(NSString *)element
                      extraData:(NSDictionary<NSString *, NSObject *> *)extraData {
    [[RollbarTelemetry sharedInstance] recordViewEventForLevel:level
                                                       element:element
                                                     extraData:extraData];
}

#pragma mark - Network

+ (void)recordNetworkEventForLevel:(RollbarLevel)level
                            method:(NSString *)method
                               url:(NSString *)url
                        statusCode:(NSString *)statusCode {
    [self recordNetworkEventForLevel:level
                              method:method
                                 url:url
                          statusCode:statusCode
                           extraData:nil];
}

+ (void)recordNetworkEventForLevel:(RollbarLevel)level
                            method:(NSString *)method
                               url:(NSString *)url
                        statusCode:(NSString *)statusCode
                         extraData:(NSDictionary<NSString *, NSObject *> *)extraData {
    [[RollbarTelemetry sharedInstance] recordNetworkEventForLevel:level
                                                           method:method
                                                              url:url
                                                       statusCode:statusCode
                                                        extraData:extraData];
}

#pragma mark - Connectivity

+ (void)recordConnectivityEventForLevel:(RollbarLevel)level
                                 status:(NSString *)status {
    [self recordConnectivityEventForLevel:level
                                   status:status
                                extraData:nil];
}

+ (void)recordConnectivityEventForLevel:(RollbarLevel)level
                                 status:(NSString *)status
                              extraData:(NSDictionary *)extraData {
    [[RollbarTelemetry sharedInstance] recordConnectivityEventForLevel:level
                                                                status:status
                                                             extraData:extraData];
}

#pragma mark - Error

+ (void)recordErrorEventForLevel:(RollbarLevel)level
                         message:(NSString *)message {
    [self recordErrorEventForLevel:level
                           message:message
                         extraData:nil];
}

+ (void)recordErrorEventForLevel:(RollbarLevel)level
                       exception:(NSException *)exception {
    [self recordErrorEventForLevel:level
                           message:exception.reason
                         extraData:@{@"description": exception.description,
                                     @"class": NSStringFromClass(exception.class)}
     ];
}

+ (void)recordErrorEventForLevel:(RollbarLevel)level
                         message:(NSString *)message
                       extraData:(NSDictionary<NSString *, NSObject *> *)extraData {
    [[RollbarTelemetry sharedInstance] recordErrorEventForLevel:level
                                                        message:message
                                                      extraData:extraData];
}

#pragma mark - Navigation

+ (void)recordNavigationEventForLevel:(RollbarLevel)level
                                 from:(NSString *)from
                                   to:(NSString *)to {
    [self recordNavigationEventForLevel:level
                                   from:from
                                     to:to
                              extraData:nil];
}

+ (void)recordNavigationEventForLevel:(RollbarLevel)level
                                 from:(NSString *)from
                                   to:(NSString *)to
                            extraData:(NSDictionary<NSString *, NSObject *> *)extraData {
    [[RollbarTelemetry sharedInstance] recordNavigationEventForLevel:level
                                                                from:from
                                                                  to:to
                                                           extraData:extraData];
}

#pragma mark - Manual

+ (void)recordManualEventForLevel:(RollbarLevel)level
                         withData:(NSDictionary<NSString *, NSObject *> *)extraData {
    [[RollbarTelemetry sharedInstance] recordManualEventForLevel:level
                                                        withData:extraData];
}

#pragma mark - Log

+ (void)recordLogEventForLevel:(RollbarLevel)level
                       message:(NSString *)message {
    [self recordLogEventForLevel:level
                         message:message
                       extraData:nil];
}

+ (void)recordLogEventForLevel:(RollbarLevel)level
                       message:(NSString *)message
                     extraData:(NSDictionary<NSString *, NSObject *> *)extraData {
    [[RollbarTelemetry sharedInstance] recordLogEventForLevel:level
                                                      message:message
                                                    extraData:extraData];
}

@end
