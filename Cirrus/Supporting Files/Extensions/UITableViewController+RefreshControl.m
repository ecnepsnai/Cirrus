@implementation UITableViewController (RefreshControl)

- (void) addRefreshControlToTableWithAction:(OCSelector * _Nonnull)action {
    [self addRefreshControlToTableWithTitle:nil action:action];
}

- (void) addRefreshControlToTableWithTitle:(NSString *)title action:(OCSelector * _Nonnull)action {
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:action.sender action:action.action forControlEvents:UIControlEventValueChanged];
    self.refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];

    if (title) {
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:title];
    }
}

- (void) toggleRefresh:(BOOL)show updateOffset:(BOOL)shouldUpdateOffset {
    // Ensure this is run on the main thread
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self toggleRefresh:show updateOffset:shouldUpdateOffset];
        });
        return;
    }

    if (show) {
        [self.refreshControl beginRefreshing];
        if (shouldUpdateOffset) {
            [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        }
    } else {
        [self.refreshControl endRefreshing];
    }
}

- (void) showRefreshControlWithUpdatedOffset:(BOOL)updateOffset {
    [self toggleRefresh:YES updateOffset:updateOffset];
}

- (void) hideRefreshControl {
    [self toggleRefresh:NO updateOffset:NO];
}

@end
