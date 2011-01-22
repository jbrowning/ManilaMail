#import "MailComm.h"


@implementation MailComm

- (id)init
{
	self = [super init];
	composeMessageScript = [self getScript: @"ComposeMessageScript"];
	openInboxScript = [self getScript: @"OpenInboxScript"];
	checkForNewMessagesScript = [self getScript: @"CheckForNewMessagesScript"];
	unreadMessagesInInboxScript = [self getScript: @"CountUnreadMessagesInInboxScript"];
	unreadMessagesInAllMailboxesScript = [self getScript: @"CountUnreadMessagesInAllMailboxesScript"];
	launchMailScript = [self getScript: @"LaunchMailScript"];
	
	return self;
}

- (int)countUnreadMessagesInInbox
{
	int result; 
	[self executeScriptWithIntReturn: unreadMessagesInInboxScript returningInt:&result];
	NSLog(@"Unread message count: %i", result);
	return result;
}

- (int)countUnreadMessagesInAllMailboxes
{
	int result;
	[self executeScriptWithIntReturn: unreadMessagesInAllMailboxesScript returningInt:&result];
	return result;
} 

- (void)composeMessage 
{	
	[self executeScript: composeMessageScript];
}

- (void)openInbox 
{
	[self executeScript: openInboxScript];
}

- (void)launchMail
{
	[self executeScript: launchMailScript];
}

- (void)checkForNewMessages
{
	[self executeScript: checkForNewMessagesScript];
}

- (NSAppleScript *)getScript: (NSString *) scriptName
{
	NSString *scriptPath = [[NSBundle mainBundle] pathForResource:scriptName ofType:@"scpt"];
	NSURL *url = [NSURL fileURLWithPath: scriptPath];
	NSDictionary *errors = [NSDictionary dictionary];
	NSAppleScript *newScript = [[NSAppleScript alloc] initWithContentsOfURL: url error: &errors];
	
	if (newScript != nil)
		return newScript;
	else
		return nil;
}

- (void)executeScript: (NSAppleScript *) scriptToExecute
{
	NSAppleEventDescriptor *returnDescriptor = NULL;
	NSDictionary *errorDict;
	
	returnDescriptor = [scriptToExecute executeAndReturnError: &errorDict];

}

- (void)executeScript: (NSAppleScript *) scriptToExecute withReturningDescriptor: (NSAppleEventDescriptor **) descriptor
{
	NSDictionary *errorDict;
	
	*descriptor = [scriptToExecute executeAndReturnError: &errorDict];
	// Put error handling stuff here
	
	if (descriptor = nil) {
		NSLog(@"There was an error executing the script");
	}
	
}

- (void)executeScriptWithIntReturn: (NSAppleScript *) scriptToExecute returningInt: (int *) result
{
	NSAppleEventDescriptor *descriptor;
	
	[self executeScript: scriptToExecute withReturningDescriptor:&descriptor];
	
	if (descriptor == nil) {
		NSLog(@"There was an error executing the script");
	} else {
		// NSLog("Int value of descriptor: %i", [descriptor int32Value]);
		// return (int *) [descriptor int32Value];
		*result = [descriptor int32Value];
	}
}

- (void)dealloc
{
	[composeMessageScript release];
	[openInboxScript release];
	[checkForNewMessagesScript release];
	[super dealloc];
}

@end
