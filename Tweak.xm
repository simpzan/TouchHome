/**
 * Use TouchID sensor for Home button click
 * MartinPham.com
**/

#include <notify.h>

#import <Foundation/Foundation.h>

/*
// For real simulating button
#include <mach/mach_time.h>
typedef uint32_t IOHIDEventOptionBits;
extern "C" {
	typedef struct __IOHIDEvent
	* IOHIDEventRef;
	IOHIDEventRef IOHIDEventCreateKeyboardEvent(CFAllocatorRef allocator, AbsoluteTime timeStamp, uint16_t usagePage, uint16_t usage, Boolean down, IOHIDEventOptionBits flags);
}

// For vibe
#import <AudioToolbox/AudioToolbox.h> 
extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);
*/


#define TouchIDFingerUp    0
#define TouchIDFingerDown  1
// #define TouchIDFingerHeld  2
// #define TouchIDMatched     3
// #define TouchIDUnlocked    4
// #define TouchIDNotMatched  10


// Interfaces needed, I'm too lazy to include full header files
/*
@interface SBHomeHardwareButton
- (_Bool)emulateHomeButtonEventsIfNeeded:(struct __IOHIDEvent *)arg1;
@end
*/

@interface UIApplication (Z)
// @property(readonly, nonatomic) SBHomeHardwareButton *homeHardwareButton;
- (void)_simulateHomeButtonPress;
- (void)_simulateLockButtonPress;
@end

@interface SBMainSwitcherViewController
+ (SBMainSwitcherViewController *)sharedInstance;
- (_Bool)toggleSwitcherNoninteractively;
@end



static NSDate* lastTouchDate = nil;
static int numberOfTouch = 0;
static NSTimer* touchTimer = nil;


%hook SBReachabilityManager
// Enable Reachability on all devices
+ (_Bool)reachabilitySupported {
	return YES;
}

// Show appswitcher instead
- (void)_handleReachabilityActivated {
	numberOfTouch = 0;
	[[%c(SBMainSwitcherViewController) sharedInstance] toggleSwitcherNoninteractively];
}
%end

%hook SBDashBoardViewController
// Handle TouchID event
- (void)handleBiometricEvent:(unsigned long long)arg1 {
	%orig;

	/*
	// NSLog(@">> handleBiometricEvent >> %lld", arg1);

	if (arg1 == TouchIDFingerDown) {
		uint64_t abTime = mach_absolute_time();
		IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, *(AbsoluteTime *)&abTime, 0xC, 0x40, YES, 0);
		[[[UIApplication sharedApplication] homeHardwareButton] emulateHomeButtonEventsIfNeeded:event];
		CFRelease(event);

		NSLog(@">> handleBiometricEvent >> DOWN >>>");
		

		// NSDate *currentTouchDate = [[NSDate date] retain];
		// NSTimeInterval diffFromLastTouchDate = 999;
		
		// if (lastTouchDate != nil) {
		// 	diffFromLastTouchDate = [currentTouchDate timeIntervalSinceDate:lastTouchDate];
		// }
		
		// lastTouchDate = currentTouchDate;
		
		// if (diffFromLastTouchDate <= 0.8f) {
		// 	// continous tap
		// 	// numberOfTouch++;
		// } else {
		// 	// reset tap
		// 	numberOfTouch = 1;
		// }
		
		// if (touchTimer != nil) {
		// 	[touchTimer invalidate];
		// }
		// touchTimer = [[NSTimer scheduledTimerWithTimeInterval:0.18f repeats:NO block:^(NSTimer * _Nonnull timer) {
		// 	if (numberOfTouch == 1) {
		// 		// Play short viberation
		// 		// NSMutableDictionary* VibrationDictionary = [NSMutableDictionary dictionary];
		// 		// NSMutableArray* VibrationArray = [NSMutableArray array ];
		// 		// [VibrationArray addObject:[NSNumber numberWithBool:YES]];
		// 		// [VibrationArray addObject:[NSNumber numberWithInt:50]];
		// 		// [VibrationDictionary setObject:VibrationArray forKey:@"VibePattern"];
		// 		// [VibrationDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
		// 		// AudioServicesPlaySystemSoundWithVibration(4095,nil,VibrationDictionary);

		// 		// Press home
		// 		[[UIApplication sharedApplication] _simulateHomeButtonPress];
		// 	} 
		// }] retain];
	} 
	else if (arg1 == TouchIDFingerUp) {

		NSLog(@">> handleBiometricEvent >> UP >>>");

		uint64_t abTime = mach_absolute_time();
		IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, *(AbsoluteTime *)&abTime, 0xC, 0x40, NO, 0);
		[[[UIApplication sharedApplication] homeHardwareButton] emulateHomeButtonEventsIfNeeded:event];
		CFRelease(event);
	} 
	*/

	NSDate *currentTouchDate = [[NSDate date] retain];
	NSTimeInterval diffFromLastTouchDate = 999;
	if (lastTouchDate != nil) {
		diffFromLastTouchDate = [currentTouchDate timeIntervalSinceDate:lastTouchDate];
	}

	if (arg1 == TouchIDFingerDown) {
		lastTouchDate = currentTouchDate;
		
		if (diffFromLastTouchDate <= 0.8f) {
			// continous tap
			// numberOfTouch++;
		} else {
			// reset tap
			numberOfTouch = 1;
		}
		
		if (touchTimer != nil) {
			[touchTimer invalidate];
		}
		touchTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1f repeats:NO block:^(NSTimer * _Nonnull timer) {
			if (numberOfTouch == 1) {
				// Play short viberation
				// NSMutableDictionary* VibrationDictionary = [NSMutableDictionary dictionary];
				// NSMutableArray* VibrationArray = [NSMutableArray array ];
				// [VibrationArray addObject:[NSNumber numberWithBool:YES]];
				// [VibrationArray addObject:[NSNumber numberWithInt:50]];
				// [VibrationDictionary setObject:VibrationArray forKey:@"VibePattern"];
				// [VibrationDictionary setObject:[NSNumber numberWithInt:1] forKey:@"Intensity"];
				// AudioServicesPlaySystemSoundWithVibration(4095,nil,VibrationDictionary);

				// Press home
				[[UIApplication sharedApplication] _simulateHomeButtonPress];
			} 
		}] retain];
	} 
	/*else if (arg1 == TouchIDFingerUp) {
		if (diffFromLastTouchDate >= 1.5f) {
			// too long
			numberOfTouch = 1;
			[[UIApplication sharedApplication] _simulateLockButtonPress];
		}
	}*/
}
%end

