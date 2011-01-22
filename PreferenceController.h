#import <Cocoa/Cocoa.h>

extern NSString *JKBMessageCheckInterval;
extern NSString *JKBCountInboxOrAll;
extern NSString *JKBOpenOnLogin;
extern NSString *JKBLaunchMailOnCount;

@interface PreferenceController : NSWindowController {
	IBOutlet NSTextField *intervalSecondsTextField;
	IBOutlet NSMatrix *countInboxOrAll;
	IBOutlet NSButton *launchMailOnCountCheckbox;
	IBOutlet NSButton *openOnLoginCheckbox;
}

- (int) checkInterval;
- (int) countInboxOrAll;
- (BOOL)launchMailOnCount;
- (BOOL) openOnLogin;

- (IBAction)showWindow:(id)sender;
- (IBAction)changeCheckInterval:(id)sender;
- (IBAction)changeCountInboxOrAll:(id)sender;
- (IBAction)changeLaunchMailOnCount:(id)sender;
- (IBAction)changeOpenOnLogin:(id)sender;

@end
