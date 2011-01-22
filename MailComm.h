#import <Cocoa/Cocoa.h>


@interface MailComm : NSObject {
	NSAppleScript *composeMessageScript;
	NSAppleScript *openInboxScript;
	NSAppleScript *checkForNewMessagesScript;
	NSAppleScript *unreadMessagesInInboxScript;
	NSAppleScript *unreadMessagesInAllMailboxesScript;
	NSAppleScript *launchMailScript;
}

- (void)composeMessage;
- (void)openInbox;
- (void)checkForNewMessages;
- (void)launchMail;
- (void)executeScript: (NSAppleScript *) scriptToExecute;
- (void)executeScriptWithIntReturn: (NSAppleScript *) scriptToExecute returningInt: (int *) result;
- (int)countUnreadMessagesInInbox;
- (int)countUnreadMessagesInAllMailboxes;
- (NSAppleScript *)getScript: (NSString *) scriptName;

@end
