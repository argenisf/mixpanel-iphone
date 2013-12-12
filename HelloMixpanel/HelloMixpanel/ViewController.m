#import "Mixpanel.h"
#import "MPSurvey.h"
#import "MPNotification.h"

#import "ViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet UISegmentedControl *genderControl;
@property (nonatomic, weak) IBOutlet UISegmentedControl *weaponControl;
@property (nonatomic, weak) IBOutlet UIImageView *fakeBackground;
@property (nonatomic, weak) IBOutlet UITextField *surveyIDField;
@property (nonatomic, weak) IBOutlet UITextField *notificationIDField;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UISegmentedControl *notificationTypeControl;

@property (nonatomic, copy) NSString *showNotificationType;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.showNotificationType = MPNotificationTypeTakeover;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.contentSize = self.view.bounds.size;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)trackEvent:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *gender = [self.genderControl titleForSegmentAtIndex:(NSUInteger)self.genderControl.selectedSegmentIndex];
    NSString *weapon = [self.weaponControl titleForSegmentAtIndex:(NSUInteger)self.weaponControl.selectedSegmentIndex];
    [mixpanel track:@"Player Create" properties:@{@"gender": gender, @"weapon": weapon}];
}

- (IBAction)setPeopleProperties:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *gender = [self.genderControl titleForSegmentAtIndex:(NSUInteger)self.genderControl.selectedSegmentIndex];
    NSString *weapon = [self.weaponControl titleForSegmentAtIndex:(NSUInteger)self.weaponControl.selectedSegmentIndex];
    [mixpanel.people set:@{@"gender": gender, @"weapon": weapon}];
    // Mixpanel People requires that you explicitly set a distinct ID for the current user. In this case,
    // we're using the automatically generated distinct ID from event tracking, based on the device's MAC address.
    // It is strongly recommended that you use the same distinct IDs for Mixpanel Engagement and Mixpanel People.
    // Note that the call to Mixpanel People identify: can come after properties have been set. We queue them until
    // identify: is called and flush them at that time. That way, you can set properties before a user is logged in
    // and identify them once you know their user ID.
    [mixpanel identify:mixpanel.distinctId];
}

- (IBAction)setNotificationType:(id)sender
{
    NSArray *types = @[MPNotificationTypeTakeover, MPNotificationTypeMini];
    self.showNotificationType = types[self.notificationTypeControl.selectedSegmentIndex];
}

- (IBAction)showSurvey:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    if ([_surveyIDField.text length] > 0) {
        [mixpanel showSurveyWithID:(NSUInteger)([_surveyIDField.text integerValue])];

    } else {
        [mixpanel showSurvey];
    }
    [_surveyIDField resignFirstResponder];
}

- (IBAction)showNotif:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    if ([_notificationIDField.text length] > 0) {
        [mixpanel showNotificationWithID:(NSUInteger)_notificationIDField.text.integerValue];
    } else {
        [mixpanel showNotificationWithType:_showNotificationType];
    }
}

- (IBAction)changeBackground
{
    if (_fakeBackground.image) {
        _fakeBackground.image = nil;
        _fakeBackground.hidden = YES;
    } else {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    _fakeBackground.image = image;
    _fakeBackground.hidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard
{
    [_surveyIDField resignFirstResponder];
    [_notificationIDField resignFirstResponder];
}

- (IBAction)changeColor
{
    FCColorPickerViewController *colorPicker = [[FCColorPickerViewController alloc]
                                                initWithNibName:@"FCColorPickerViewController"
                                                bundle:[NSBundle mainBundle]];
    colorPicker.color = [[UINavigationBar appearance] barTintColor];
    colorPicker.delegate = self;

    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
}

- (void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
    [[UINavigationBar appearance] setBarTintColor:color];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
