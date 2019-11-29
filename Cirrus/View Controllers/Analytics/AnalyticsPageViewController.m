#import "AnalyticsPageViewController.h"
#import "AnalyticsViewController.h"
#import "AnalyticsGraphViewController.h"
#import "AnalyticsGlobalStatsViewController.h"
#import "DNSAnalyticsGraphViewController.h"

@interface AnalyticsPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) NSArray<UIViewController *> * pages;
@property (strong, nonatomic) UIPageControl * pageControl;

@end

@implementation AnalyticsPageViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    AnalyticsGraphViewController * graphViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Graph"];
    DNSAnalyticsGraphViewController * dnsGraphViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DNSGraph"];
    AnalyticsGlobalStatsViewController * statsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Stats"];
    self.pages = @[graphViewController, dnsGraphViewController, statsViewController];
    self.delegate = self;
    self.dataSource = self;
    self.doubleSided = YES;
    [self setViewControllers:@[graphViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void) didMoveToParentViewController:(AnalyticsViewController *)parent {
    [super didMoveToParentViewController:parent];
    self.pageControl = parent.pageControl;
    self.pageControl.numberOfPages = self.pages.count;
    ((AnalyticsGraphViewController *)self.pages[0]).parent = parent;
    ((DNSAnalyticsGraphViewController *)self.pages[1]).parent = parent;
    ((AnalyticsGlobalStatsViewController *)self.pages[2]).parent = parent;
    [self.pageControl setCurrentPage:0];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (nullable UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger currentIndex = [self.pages indexOfObject:viewController];
    if (currentIndex > 0 && currentIndex < self.pages.count) {
        return self.pages[currentIndex - 1];
    }

    return nil;
}

- (nullable UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger currentIndex = [self.pages indexOfObject:viewController];
    if (currentIndex >= 0 && currentIndex < self.pages.count - 1) {
        return self.pages[currentIndex + 1];
    }

    return nil;
}

- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed && finished) {
        [self.pageControl setCurrentPage:[self.pages indexOfObject:self.viewControllers[0]]];
    }
}

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.pages.count;
}

@end
