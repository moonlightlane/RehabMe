//
// ChooseExerciseViewController.m
//
// Copyright (c) 2015 , Dan Volz @djvolz
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ChooseExerciseViewController.h"
#import "Exercise.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "CBZSplashView.h"
#import "UIColor+HexString.h"
#import "UIBezierPath+Shapes.h"

static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChooseExerciseViewController ()
@property (nonatomic, strong) NSMutableArray *exercises;
@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *nopeButton;
@property (nonatomic, strong) CBZSplashView *splashView;

@end

@implementation ChooseExerciseViewController

#pragma mark - Object Lifecycle

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        // This view controller maintains a list of ChoosePersonView
//        // instances to display.
//        _exercises = [[self defaultPeople] mutableCopy];
//    }
//    return self;
//}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDeck];
    
    
    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
//    [self constructNopeButton];
//    [self constructLikedButton];
    

}

- (void) viewDidAppear:(BOOL)animated {
    [self animateButton];
}

// Constructs splash that splashes green check button that grows across screen
- (void) constructSplashScreen {
    UIImage *icon = [UIImage imageNamed:@"checkButton"];
    UIColor *color = [UIColor greenColor];
    CBZSplashView *splashView = [CBZSplashView splashViewWithIcon:icon backgroundColor:color];
    
    splashView.animationDuration = 1.4;
    
    [self.view addSubview:splashView];
    
    self.splashView = splashView;

}

// Make the reload button pulse
- (void)animateButton {
    CABasicAnimation *pulseAnimation;
    
    pulseAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    pulseAnimation.duration=1.0;
    pulseAnimation.repeatCount=HUGE_VALF;
    pulseAnimation.autoreverses=YES;
    pulseAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue=[NSNumber numberWithFloat:0.7];
    [self.reloadButton.layer addAnimation:pulseAnimation forKey:@"animateOpacity"];
}

- (void)loadDeck {
    // This view controller maintains a list of ChoosePersonView
    // instances to display.
    _exercises = [[self defaultPeople] mutableCopy];
    
    // Display the first ChoosePersonView in front. Users can swipe to indicate
    // whether they like or dislike the person displayed.
    self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
    [self.view addSubview:self.frontCardView];
    
    // Display the second ChoosePersonView in back. This view controller uses
    // the MDCSwipeToChooseDelegate protocol methods to update the front and
    // back views after each user swipe.
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
    
}

- (void) endOfDeck {
    [self constructSplashScreen];
    
    [self.splashView startAnimation];
    
    self.view.backgroundColor = [UIColor greenColor];
}



- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentExercise.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentExercise.name);
        
        // No more backcard so after completing this swipe is the end of the deck
        if (self.backCardView == nil) {
            [self endOfDeck];
        }
    } else {
        NSLog(@"You liked %@.", self.currentExercise.name);
        // No more backcard so after completing this swipe is the end of the deck
        if (self.backCardView == nil) {
            [self endOfDeck];
        }
    }

    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(ChooseExerciseView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    self.currentExercise = frontCardView.exercise;
}

- (NSArray *)defaultPeople {
    // It would be trivial to download these from a web service
    // as needed, but for the purposes of this sample app we'll
    // simply store them in memory.
    return @[
        [[Exercise alloc] initWithName:@"Calf Raises"
                               image:[UIImage imageNamed:@"calf_raises"]
                                 count:15
               numberOfSharedFriends:3
             numberOfSharedInterests:2
                      timeRequired:1],
        [[Exercise alloc] initWithName:@"Half Squats"
                               image:[UIImage imageNamed:@"half_squats"]
                                 count:28
               numberOfSharedFriends:2
             numberOfSharedInterests:6
                      timeRequired:8],
        [[Exercise alloc] initWithName:@"Hamstring Curls"
                               image:[UIImage imageNamed:@"hamstring_curls"]
                                 count:14
               numberOfSharedFriends:1
             numberOfSharedInterests:3
                      timeRequired:5],
        [[Exercise alloc] initWithName:@"Heel Cord Stretch"
                               image:[UIImage imageNamed:@"heel_cord_stretch"]
                                 count:18
               numberOfSharedFriends:1
             numberOfSharedInterests:1
                      timeRequired:2],
        [[Exercise alloc] initWithName:@"Hip Abduction"
                                 image:[UIImage imageNamed:@"hip_abduction"]
                                 count:15
                 numberOfSharedFriends:3
               numberOfSharedInterests:2
                          timeRequired:1],

        [[Exercise alloc] initWithName:@"Hip Adduction"
                                 image:[UIImage imageNamed:@"hip_adduction"]
                                 count:15
                 numberOfSharedFriends:3
               numberOfSharedInterests:2
                          timeRequired:1],

        [[Exercise alloc] initWithName:@"Leg Extensions"
                                 image:[UIImage imageNamed:@"leg_extensions"]
                                 count:15
                 numberOfSharedFriends:3
               numberOfSharedInterests:2
                          timeRequired:1],

        [[Exercise alloc] initWithName:@"Leg Presses"
                                 image:[UIImage imageNamed:@"leg_presses"]
                                 count:15
                 numberOfSharedFriends:3
               numberOfSharedInterests:2
                          timeRequired:1],

    ];
}

- (ChooseExerciseView *)popPersonViewWithFrame:(CGRect)frame {
    if ([self.exercises count] == 0) {
        return nil;
    }

    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };

    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    ChooseExerciseView *personView = [[ChooseExerciseView alloc] initWithFrame:frame
                                                                    person:self.exercises[0]
                                                                   options:options];
    [self.exercises removeObjectAtIndex:0];
    return personView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 100.f;
    CGFloat bottomPadding = 180.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    UIButton *nopeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"xButton"];
    nopeButton.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [nopeButton setImage:image forState:UIControlStateNormal];
    [nopeButton setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
    [nopeButton addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nopeButton];
}

// Create and add the "OK" button.
- (void)constructLikedButton {
    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"checkButton"];
    likeButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [likeButton setImage:image forState:UIControlStateNormal];
    [likeButton setTintColor:[UIColor colorWithRed:29.f/255.f
                                         green:245.f/255.f
                                          blue:106.f/255.f
                                         alpha:1.f]];
    [likeButton addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:likeButton];
}

#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    if(self.exercises.count != 0)
        [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
    else {
        NSLog(@"All done!");
    }

}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    if(self.exercises.count != 0)
        [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
    else {
        NSLog(@"All done!");
    }
}



- (IBAction)pressedReloadButton:(UIButton *)sender {
//    /* wait a beat before animating in */
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    });
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadDeck];
}



//- (void)viewDidAppear:(BOOL)animated
//{
//    self.gradient = [CAGradientLayer layer];
//    self.gradient.frame = self.view.bounds;
//    self.gradient.colors = @[(id)[UIColor lightGrayColor].CGColor,
//                             (id)[UIColor whiteColor].CGColor];
//
//    [self.view.layer insertSublayer:self.gradient atIndex:0];
//
//    [self animateLayer];
//}
//
//-(void)animateLayer
//{
//
//    NSArray *fromColors = self.gradient.colors;
//    NSArray *toColors = @[(id)[UIColor lightGrayColor].CGColor,
//                          (id)[UIColor whiteColor].CGColor];
//
//    [self.gradient setColors:toColors];
//
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
//
//    animation.fromValue             = fromColors;
//    animation.toValue               = toColors;
//    animation.duration              = 7.00;
//    animation.removedOnCompletion   = YES;
//    animation.fillMode              = kCAFillModeForwards;
//    animation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    animation.delegate              = self;
//
//    // Add the animation to our layer
//
//    [self.gradient addAnimation:animation forKey:@"animateGradient"];
//}


@end
