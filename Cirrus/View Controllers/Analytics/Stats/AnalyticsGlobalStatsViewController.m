#import "AnalyticsGlobalStatsViewController.h"
#import "AnalyticsRingCollectionViewCell.h"
#import "AnalyticsListCollectionViewCell.h"

@interface AnalyticsGlobalStatsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) CFAnalyticsResults * data;
@property (strong, nonatomic) OCSelector * dataSelector;
@end

@implementation AnalyticsGlobalStatsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) setParent:(AnalyticsViewController *)parent {
    _parent = parent;
    self.dataSelector = [OCSelector selectorWithTarget:self action:@selector(didRecieveData:)];
    [parent setDataObservationsWithRecievedData:self.dataSelector loadStarted:nil];
}

- (void) didRecieveData:(CFAnalyticsResults *)results {
    self.data = results;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data == nil ? 0 : 4;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            AnalyticsRingCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Ring" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"Bandwidth Saved");
            unsigned long long cached = [self.data.totals.bandwidth.cached unsignedLongLongValue];
            unsigned long long uncached = [self.data.totals.bandwidth.uncached unsignedLongLongValue];
            unsigned long long total = cached + uncached;
            (void)total;
            return cell;
        } case 1: {
            AnalyticsRingCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Ring" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"Traffic Using SSL");
            unsigned long long encrypted = [self.data.totals.requests.encrypted unsignedLongLongValue];
            unsigned long long all = [self.data.totals.requests.all unsignedLongLongValue];
            (void)encrypted;
            (void)all;
            return cell;
        } case 2: {
            AnalyticsListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"List" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"Traffic Origins");
            [cell setItems:self.data.totals.requests.top3Countries];
            return cell;
        } case 3: {
            AnalyticsListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"List" forIndexPath:indexPath];
            cell.titleLabel.text = l(@"Threat Origins");
            [cell setItems:self.data.totals.threats.top3Countries];
            return cell;
        } default: break;
    }

    return nil;
}

@end
