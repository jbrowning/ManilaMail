#import "PreferenceController.h"

NSString *JKBMessageCheckInterval = @"MessageCheckInterval";
NSString *JKBCountInboxOrAll = @"CountInboxOrAll";
NSString *JKBOpenOnLogin = @"OpenOnLogin";
NSString *JKBLaunchMailOnCount = @"LaunchMailOnCount";

@implementation PreferenceController

- (id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)windowDidLoad
{

	// Set the preference window elements to reflect the user's preferences
	NSNumber *intervalSecondsUserDefaults;
	
	intervalSecondsUserDefaults = [[NSUserDefaults standardUserDefaults] objectForKey: JKBMessageCheckInterval];
	
	[intervalSecondsTextField setIntValue: [intervalSecondsUserDefaults intValue]];
	
	NSNumber *countInboxOrAllUserDefaults;
	
	countInboxOrAllUserDefaults = [[NSUserDefaults standardUserDefaults] objectForKey: JKBCountInboxOrAll];
	
	if ([countInboxOrAllUserDefaults intValue] == 1)
		[countInboxOrAll selectCellAtRow: 0 column: 0];
	else if ([countInboxOrAllUserDefaults intValue] == 2)
		[countInboxOrAll selectCellAtRow: 1 column: 0];
		
	BOOL launchMailOnCountUserDefaults;
	
	launchMailOnCountUserDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey: JKBLaunchMailOnCount] boolValue];
	
	if (launchMailOnCountUserDefaults == YES)
		[launchMailOnCountCheckbox setState: NSOnState];
	else
		[launchMailOnCountCheckbox setState: NSOffState];
		
	BOOL openAtLoginUserDefaults;
	
	openAtLoginUserDefaults = [[[NSUserDefaults standardUserDefaults] objectForKey: JKBOpenOnLogin] boolValue];
	
	if (openAtLoginUserDefaults == YES)
		[openOnLoginCheckbox setState: NSOnState];
	else
		[openOnLoginCheckbox setState: NSOffState];
}

// Because our application is only a status bar item, it is never activated.
// Therefore, we must activate the preference window manually when it is
// asked to display itself
- (IBAction)showWindow:(id)sender
{
	[super showWindow: sender];
	[[self window] orderFrontRegardless];
}

- (int) checkInterval
{
	NSNumber *checkIntervalUserDefaults;
	NSUserDefaults *userDefaults;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	checkIntervalUserDefaults = [userDefaults objectForKey: JKBMessageCheckInterval];
	
	NSLog(@"Interval checked. Returned %i", [checkIntervalUserDefaults intValue]);
	
	return [checkIntervalUserDefaults intValue];
}

- (int)countInboxOrAll
{
	NSNumber *countInboxOrAllUserDefaults;
	NSUserDefaults *userDefaults;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	countInboxOrAllUserDefaults = [userDefaults objectForKey: JKBCountInboxOrAll];
	
	return [countInboxOrAllUserDefaults intValue];


}

- (BOOL)launchMailOnCount
{
	BOOL launchMailOnCountUserDefaults;
	NSUserDefaults *userDefaults;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	launchMailOnCountUserDefaults = [[userDefaults objectForKey: JKBLaunchMailOnCount] boolValue];
	
	return launchMailOnCountUserDefaults;
}

- (BOOL)openOnLogin
{

	BOOL openAtLoginUserDefaults;
	NSUserDefaults *userDefaults;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	openAtLoginUserDefaults = [[userDefaults objectForKey: JKBOpenOnLogin] boolValue];
	
	return openAtLoginUserDefaults;
}


- (IBAction)changeCheckInterval:(id)sender
{
	NSNumber *newCheckInterval;
	
	newCheckInterval = [NSNumber numberWithInt: [sender intValue]];
	
	NSUserDefaults *userDefaults;
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject: newCheckInterval forKey: JKBMessageCheckInterval]; 
	
	NSLog(@"Changed value to the number: %i", [sender intValue]);
	
	NSNotificationCenter *nc;
	
	nc = [NSNotificationCenter defaultCenter];
	
	[nc postNotificationName: @"JKBTimerIntervalChanged" object: self];

}

- (IBAction)changeCountInboxOrAll:(id)sender
{

	NSNumber *newCountInboxOrAllValue;
	NSUserDefaults *userDefaults;
	
	if ([sender selectedRow] == 0)
		newCountInboxOrAllValue = [NSNumber numberWithInt: 1];
	else if ([sender selectedRow] == 1)
		newCountInboxOrAllValue = [NSNumber numberWithInt: 2];
	
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject: newCountInboxOrAllValue forKey: JKBCountInboxOrAll];
	
	NSLog(@"Changed Count Inbox or All value to: %i", [newCountInboxOrAllValue intValue]);
}

- (IBAction)changeLaunchMailOnCount:(id)sender
{
	BOOL newLaunchMailOnCountValue;
	NSUserDefaults *userDefaults;
	
	if ([sender state] == NSOnState)
		newLaunchMailOnCountValue = YES;
	else if ([sender state] == NSOffState)
		newLaunchMailOnCountValue = NO;
		
	userDefaults = [NSUserDefaults standardUserDefaults];
	
	[userDefaults setObject: [NSNumber numberWithBool: newLaunchMailOnCountValue] forKey: JKBLaunchMailOnCount];
}

- (IBAction)changeOpenOnLogin:(id)sender
{
	BOOL newOpenOnLoginValue;
	NSUserDefaults *userDefaults;
	
	if ([sender state] == NSOnState)
		newOpenOnLoginValue = YES;
	else if ([sender state] == NSOffState)
		newOpenOnLoginValue = NO;
		
	userDefaults = [NSUserDefaults standardUserDefaults];
		
	[userDefaults setObject: [NSNumber numberWithBool: newOpenOnLoginValue] forKey: JKBOpenOnLogin];
	
	NSNotificationCenter *nc;
	
	nc = [NSNotificationCenter defaultCenter];
	
	[nc postNotificationName: @"JKBCheckInboxOrAllChanged" object: self];
}

@end
