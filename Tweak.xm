/**
 * Use TouchID sensor for Home button click
 * MartinPham.com
**/
#include <notify.h>


#define TouchIDFingerUp    0
#define TouchIDFingerDown  1
#define TouchIDFingerHeld  2
#define TouchIDMatched     3
#define TouchIDUnlocked    4
#define TouchIDNotMatched  10

// Interfaces needed, I'm too lazy to include full header files
@interface UIApplication (Z)
- (void)_simulateHomeButtonPress;
@end
@interface SBMainSwitcherViewController
+ (SBMainSwitcherViewController *)sharedInstance;
- (_Bool)toggleSwitcherNoninteractively;
@end


%hook SBReachabilityManager
// Enable Reachability on all devices
+ (_Bool)reachabilitySupported {
	return YES;
}

// Show appswitcher instead
- (void)_handleReachabilityActivated {
	[[%c(SBMainSwitcherViewController) sharedInstance] toggleSwitcherNoninteractively];
}
%end

%hook SBDashBoardViewController
// Handle TouchID event
- (void)handleBiometricEvent:(unsigned long long)arg1 {
	%orig;

	if (arg1 == TouchIDFingerDown) {
		// Send notification to SpringBoard listener
		notify_post("com.martinpham.touchhome.touchIdDown");
	}
}
%end

// Implement listener, in this case we want to simulate Home button
static void TouchHome_TouchIdDown(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@try {
		[[UIApplication sharedApplication] _simulateHomeButtonPress];
	}
	@catch (NSException *exception) {
		NSLog(@">>>> Exception:%@",exception);
	}
}

%hook SpringBoard
// Register listener
- (void)applicationDidFinishLaunching: (id) application {
    %orig;

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, TouchHome_TouchIdDown, CFSTR("com.martinpham.touchhome.touchIdDown"), NULL, CFNotificationSuspensionBehaviorCoalesce);

}
%end

