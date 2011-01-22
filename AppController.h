#import <Cocoa/Cocoa.h>
@class MailComm;
@class PreferenceController;

@interface AppController : NSObject
{
    IBOutlet NSMenu *appMenu;
	NSStatusItem *mailThingMenu;
	MailComm *mailComm;
	NSTimer *mailboxCheckTimer;
	PreferenceController *preferenceController;
}

- (IBAction)composeMessage:(id)sender;
- (IBAction)openInbox:(id)sender;
- (IBAction)checkForNewMessages:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;

- (void)updateUnreadMessages;
- (void)updateMenuUnreadCount:(int)count;
- (void)setupTimerWithInterval: (int)interval;
- (void)addToLoginItems;
- (void)removeFromLoginItems;

- (void)handleIntervalChangeNotification: (NSNotification *) notification;
- (void)handleOpenOnLoginNotification: (NSNotification *) notification;

@end
