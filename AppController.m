#import "AppController.h"
#import "MailComm.h"
#import "PreferenceController.h"

@implementation AppController

- (id) init
{
	self = [super init];
	
	mailComm = [[MailComm alloc] init];
	
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(handleIntervalChangeNotification:)
			   name:@"JKBTimerIntervalChanged"
			 object:nil];
			 
	[nc addObserver:self
		   selector:@selector(handleCheckInboxOrAllChangeNotification:)
			   name:@"JKBCheckInboxOrAllChanged"
			 object:nil];
			 
	[nc addObserver:self
		   selector:@selector(handleOpenOnLoginNotification:)
		       name:@"JKBCheckInboxOrAllChanged"
			object:nil];
			 	
	// Initialize the preference controller
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	
	return self;
}

// This method is called before any other method. It is used to 
// initialize the default values for user preferences.

+ (void) initialize 
{

	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
		
	[defaultValues setObject: [NSNumber numberWithInt: 10] forKey: JKBMessageCheckInterval];
	
	/* For the user preferences, the integer 1 will represent the preference to
	 * only count unread messages in the inbox. The integer 2 will represent the user's
	 * desire to count unread messages in all mailboxes. The default will be to count
	 * the unread messages in all mailboxes (not just the inbox)
	 */
	[defaultValues setObject: [NSNumber numberWithInt: 2] forKey: JKBCountInboxOrAll];
	[defaultValues setObject: [NSNumber numberWithBool: NO] forKey: JKBOpenOnLogin];
	[defaultValues setObject: [NSNumber numberWithBool: NO] forKey: JKBLaunchMailOnCount];
	
	// Register the default preferences for this app
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
	
}

// Creates the statusbar menu 
- (void)activateMenu
{
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	
	mailThingMenu = [statusBar statusItemWithLength: NSVariableStatusItemLength];
	[mailThingMenu retain];
		
	// Set the initial title for the menu. This is soon changed
	// as we do our initial count of unread messages right after
	// this method ends.
	[mailThingMenu setTitle: @"Mm"];
	
	[mailThingMenu setHighlightMode: YES];
	[mailThingMenu setMenu: appMenu];

	// [self updateUnreadMessages];	
}

-(void) awakeFromNib
{
	[self activateMenu];
	
	NSNumber *defaultTimerInterval;
	
	// Retrieve the default timer interval from the user's preferences
	defaultTimerInterval = [[NSUserDefaults standardUserDefaults] objectForKey: JKBMessageCheckInterval];
		
	// Set up the initial mail count timer
	[self setupTimerWithInterval: [defaultTimerInterval intValue]];
}

-(void)updateUnreadMessages
{
	int unreadCount;
	
	// Check to see if we should count unread messages in only the inbox
	// or in all mailboxes
	int inboxOrAll = [preferenceController countInboxOrAll];
		
	// Check to see if we should launch Mail if it is closed when we perform the count
	
	BOOL launchMailOnCount = [preferenceController launchMailOnCount];
	
	if (launchMailOnCount == YES)
		[mailComm launchMail];
		
	if (inboxOrAll == 1)
	{
		unreadCount = [mailComm countUnreadMessagesInInbox];
	}
	else if (inboxOrAll == 2)
	{
		unreadCount = [mailComm countUnreadMessagesInAllMailboxes];
	}
	
	[self updateMenuUnreadCount: unreadCount];
	
}

-(void)updateMenuUnreadCount: (int) count
{
	NSString *titleString;
	
	if (count == -1)
		titleString = @"Mm (?)";
	else if (count > 0) 
		titleString = [NSString stringWithFormat: @"Mm (%i)", count];
	else
		titleString = @"Mm";
	
	[mailThingMenu setTitle: titleString];
}

-(void) setupTimerWithInterval: (int)interval
{
	// Invalidate and release the previous timer.
	[mailboxCheckTimer invalidate];
	// We manually release the timer because invalidation does not guarantee
	// that the timer will be immediately released from the run loop
	[mailboxCheckTimer release];
	mailboxCheckTimer = [NSTimer scheduledTimerWithTimeInterval: interval
													     target: self 
													   selector: @selector(updateUnreadMessages)
													   userInfo: nil
														repeats: YES];
}

/* Notification handlers */

- (void)handleIntervalChangeNotification: (NSNotification *) notification
{
	PreferenceController *sender = [notification object];
	int newInterval = [sender checkInterval];
	[self setupTimerWithInterval: newInterval];
}

- (void)handleOpenOnLoginNotification: (NSNotification *) notification
{	
	PreferenceController *sender = [notification object];	
	BOOL newOpenOnLoginPreference = [sender openOnLogin];
	
	if (newOpenOnLoginPreference == YES) {
		[self addToLoginItems];
	} else if (newOpenOnLoginPreference == NO) {
		[self removeFromLoginItems];
	}
	
}

- (IBAction)showPreferencePanel:(id)sender
{
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	
	[preferenceController showWindow:self];
}

- (IBAction)composeMessage:(id)sender
{
	[mailComm composeMessage];
}

- (IBAction)openInbox:(id)sender
{
	[mailComm openInbox];
}

- (IBAction)checkForNewMessages:(id)sender
{
	[mailComm checkForNewMessages];
}

/* 
This method receives an array of dicionaries and looks in each dictionary to 
determine whether it contains a path to our app. If a path to our app is found,
then the matching dictionary is returned.
*/
- (NSDictionary *)pathToAppIsIn: (NSArray *) loginItems
{
	NSString *pathToApp = [[NSBundle mainBundle] bundlePath];
	NSDictionary *currentLoginItem;
	NSEnumerator *enumerator = [loginItems objectEnumerator];
	
	while (currentLoginItem = [enumerator nextObject]) {
	
		// This creates a fully qualified path from a string
		NSString *currentItem = [[currentLoginItem objectForKey:@"Path"] stringByStandardizingPath];
	
		// If the path to our app and the path in the "Path" object are equal, then we've found our app
		if([currentItem isEqualToString: pathToApp])
			return currentLoginItem;
	}
	
	return nil;
}

- (void)addToLoginItems
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *pathToApp = [[NSBundle mainBundle] bundlePath];
	NSDictionary *appDictionary;
	NSMutableDictionary *loginwindowDictionary = [[userDefaults persistentDomainForName: @"loginwindow"] mutableCopy];
	NSMutableArray *currentLoginItems;
	
	if (loginwindowDictionary == nil)
		// If "loginwindow" does not exist, we will create it
		loginwindowDictionary = [NSMutableDictionary dictionaryWithCapacity: 1];

	if(!(currentLoginItems = [[loginwindowDictionary objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy]))
		// If "AutoLaunchedApplicationDictionary does not exist, we will create it
		currentLoginItems = [NSMutableArray arrayWithCapacity: 1];
	
	// Check to see if our app is already in login items. If it is, remove it
	if ((appDictionary = [self pathToAppIsIn: currentLoginItems]) != nil) {
		[currentLoginItems removeObject: appDictionary];
	}
		
	// Create new login item for our app
	appDictionary = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithBool: YES], @"Hide", pathToApp, @"Path", nil];
	
	// Add our newly created login item dictionary to the array of login items
	[currentLoginItems addObject: appDictionary];
	
	// Add our array to the "loginwindow" dictionary
	[loginwindowDictionary setObject: currentLoginItems forKey: @"AutoLaunchedApplicationDictionary"];
	// Remove the current "loginwindow" dicionary and replace it with our own
	[userDefaults removePersistentDomainForName: @"loginwindow"];
	[userDefaults setPersistentDomain: loginwindowDictionary forName: @"loginwindow"];
	[userDefaults synchronize];
	
}

- (void)removeFromLoginItems
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *pathToApp = [[NSBundle mainBundle] bundlePath];
	NSDictionary *appDictionary;
	NSMutableDictionary *loginwindowDictionary = [[userDefaults persistentDomainForName: @"loginwindow"] mutableCopy];
	NSMutableArray *currentLoginItems;
	
	// If we don't have a "loginwindow" Persistent Domain, then our app
	// is surely not in the login items for the user
	if (!loginwindowDictionary)
				return;
	
	// Same as previous condition
	if(!(currentLoginItems = [[loginwindowDictionary objectForKey: @"AutoLaunchedApplicationDictionary"] mutableCopy]))
		return;
	
	if ((appDictionary = [self pathToAppIsIn: currentLoginItems]) != nil) {
		[currentLoginItems removeObject: appDictionary];
	}

	// As with the "addtoLoginItems" method, we are replacing the currently existing
	// "loginwindow" persistent domain with the one that we have just created
	[loginwindowDictionary setObject: currentLoginItems forKey: @"AutoLaunchedApplicationDictionary"];
	[userDefaults removePersistentDomainForName: @"loginwindow"];
	[userDefaults setPersistentDomain: loginwindowDictionary forName: @"loginwindow"];
	[userDefaults synchronize];

}


- (void) dealloc
{
	[mailComm release];
	[preferenceController release];
	
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	[super dealloc];
}

@end
