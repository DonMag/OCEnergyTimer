//
//  ViewController.m
//  OCEnergyTimer
//
//  Created by Don Mag on 3/23/17.
//  Copyright © 2017 DonMag. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

// Display elements
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *energyBar;
@property (weak, nonatomic) IBOutlet UILabel *minutesLabel;

// buttons
@property (weak, nonatomic) IBOutlet UIButton *btnSubtract;

@end

// internal objects
NSTimer *_minuteTimer;
NSDate *_lastDate;

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	_lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"open"];
	if (!_lastDate) {
		_lastDate = [NSDate date];
		[[NSUserDefaults standardUserDefaults] setObject:_lastDate forKey:@"open"];
	}

	NSDate *now = [NSDate date];
	
	NSTimeInterval timeInterval = [now timeIntervalSinceDate:_lastDate];
	
	if (timeInterval >= 600) {
		
		// 10 minutes (or more) has already elapsed since the time was saved
		// so don't start the Timer
		
	} else {
		
		// less than 10 minutes elapsed since the time was saved
		// so start the Minute Timer
		
		[self restartTimer];
		
	}

	[self updateInfoLabel];
	
	[self upgradeEnergyBar];
	
}

- (void)restartTimer {

	// start the timer only if it is not already running
	if (!_minuteTimer || ![_minuteTimer isValid]) {
		
		_minuteTimer = [NSTimer scheduledTimerWithTimeInterval: (1)
														target:self
													  selector:@selector(upgradeEnergyBar)
													  userInfo:nil
													   repeats:YES];
	}
	
}

- (void)updateInfoLabel {
	
	_infoLabel.text = [NSString stringWithFormat:@"Saved Time:\n%@", _lastDate];

}

-(void)upgradeEnergyBar {
	NSDate *now = [NSDate date];

	NSTimeInterval timeInterval = [now timeIntervalSinceDate:_lastDate];

	// don't allow timeInterval to be greater than 10 minutes
	timeInterval = timeInterval < 600.0 ? timeInterval : 600.0;

	float pct = timeInterval / 600.0;

	// will never be > 1, but just in case
	_energyBar.progress = pct < 1.0 ? pct : 1.0;

	// convert elapsed time to time remaining
	NSTimeInterval remain = 600.0 - timeInterval;
	NSUInteger minutes = (NSUInteger)floor(remain / 60.0);
	NSUInteger seconds = (NSUInteger)remain % 60;
	
	_minutesLabel.text = [NSString stringWithFormat:@"Recover in %02ld:%02ld", minutes, seconds];
	
	if (timeInterval == 600.0) {
	
		// kill the timer
		[_minuteTimer invalidate];
		
	}
}

- (IBAction)sfAction:(id)sender {
	
	// add one minute (60 seconds) to the "lastTime" - will increase time remaining
	_lastDate = [_lastDate dateByAddingTimeInterval:60];
	
	// get the current date/time
	NSDate *now = [NSDate date];
	
	// use the earlier date/time (to avoid a date/time in the future)
	_lastDate = [_lastDate earlierDate:now];
	
	// IF _lastDate is older than 10 minutes ago (for example, app has been closed for an hour)
	// set _lastDate to 9 minutes ago
	NSTimeInterval timeInterval = [now timeIntervalSinceDate:_lastDate];
	if (timeInterval > 600) {
		_lastDate = [now dateByAddingTimeInterval:-540];
	}
	
	// save it back to User Defaults
	[[NSUserDefaults standardUserDefaults] setObject:_lastDate forKey:@"open"];
	
	// Timer will only restart if it's not running
	// If user has tapped Subtract, we ALWAYS want the Timer to be running
	[self restartTimer];

	[self updateInfoLabel];
	[self upgradeEnergyBar];
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
