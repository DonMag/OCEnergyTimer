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
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnRestart;

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
	
	if (timeInterval > 600) {
		
		// 10 minutes (or more) has already elapsed since the time was saved
		// so Show the Restart button
		_btnRestart.hidden = NO;
		
	} else {
		
		// less than 10 minutes elapsed since the time was saved
		// so Hide the Restart button
		_btnRestart.hidden = YES;
		
		// and start the Minute Timer
		[self restartTimer];
		
	}

	// show or hide Add and Subtract buttons as appropriate
	_btnSubtract.hidden = _btnAdd.hidden = !_btnRestart.hidden;
	
	[self updateInfoLabel];
	
	[self upgradeEnergyBar];
	
}

- (void)restartTimer {
	
	_minuteTimer = [NSTimer scheduledTimerWithTimeInterval: (1 * 60)
													target:self
												  selector:@selector(upgradeEnergyBar)
												  userInfo:nil
												   repeats:YES];
	
}

- (void)updateInfoLabel {
	
	_infoLabel.text = [NSString stringWithFormat:@"Saved Time:\n%@", _lastDate];

}

-(void)upgradeEnergyBar {
	NSDate *now = [NSDate date];

	NSTimeInterval timeInterval = [now timeIntervalSinceDate:_lastDate];

	NSInteger minutes = MIN(10, (NSInteger)(timeInterval / 60.0));
	
	_energyBar.progress = minutes * 0.1;
	
	_minutesLabel.text = [NSString stringWithFormat:@"Minutes: %ld  /  Percent: %ld%%", (long)minutes, (long)(minutes * 10)];
	
	if (minutes == 10) {
	
		// kill the timer
		[_minuteTimer invalidate];
		
		// show Restart button, hide Add/Subtract buttons
		_btnRestart.hidden = NO;
		_btnSubtract.hidden = _btnAdd.hidden = !_btnRestart.hidden;
		
		NSLog(@"end");
		
	}
}

- (IBAction)restartAll:(id)sender {

	// set lastDate to now, save it to User Defaults
	_lastDate = [NSDate date];
	[[NSUserDefaults standardUserDefaults] setObject:_lastDate forKey:@"open"];

	// hide Restart button, show Add/Subtract buttons
	_btnRestart.hidden = YES;
	_btnSubtract.hidden = _btnAdd.hidden = !_btnRestart.hidden;
	
	// start the timer
	[self restartTimer];

	// update the UI
	[self updateInfoLabel];
	[self upgradeEnergyBar];

}

- (IBAction)afAction:(id)sender {
	
	// subtract one minute (60 seconds) from the "lastTime" - will decrease time remaining
	_lastDate = [_lastDate dateByAddingTimeInterval:-60];
	
	// save it back to User Defaults
	[[NSUserDefaults standardUserDefaults] setObject:_lastDate forKey:@"open"];
	
	[self updateInfoLabel];
	[self upgradeEnergyBar];
	
}

- (IBAction)sfAction:(id)sender {
	
	// add one minute (60 seconds) to the "lastTime" - will increase time remaining
	_lastDate = [_lastDate dateByAddingTimeInterval:60];
	
	// get the current date/time
	NSDate *now = [NSDate date];
	
	// use the earlier date/time (to avoid a date/time in the future)
	_lastDate = [_lastDate earlierDate:now];
	
	// save it back to User Defaults
	[[NSUserDefaults standardUserDefaults] setObject:_lastDate forKey:@"open"];
	
	[self updateInfoLabel];
	[self upgradeEnergyBar];
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
