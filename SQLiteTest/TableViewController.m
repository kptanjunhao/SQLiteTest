//
//  TableViewController.m
//  SQLiteTest
//
//  Created by 谭钧豪 on 16/6/21.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController{
    sqlite3 *dataBase;
    NSMutableArray *msgArray;
    NSArray *dirPaths;
    NSString *docsDir;

}

@synthesize myname;

-(int)execSQL:(NSString *)sql{
    char *errorMsg;
    int result = sqlite3_exec(dataBase,[sql UTF8String], NULL,NULL,&errorMsg);
    return result;
}

- (NSMutableArray*)getResult{
    sqlite3_stmt *statement;
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    const char* dbPath = [[[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"info.db"]] UTF8String];
    if (sqlite3_open(dbPath, &dataBase)==SQLITE_OK){
        
        if ([myname isEqualToString:@""]){
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController.title = @"提醒";
            [alertController addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            alertController.message = @"你的姓名为空了！为什么呢？";
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            NSString *searchsql = [NSString stringWithFormat:@"SELECT * FROM MSG WHERE SENDER='%@'",myname];
            const char *searchstatement = [searchsql UTF8String];
            if (sqlite3_prepare_v2(dataBase,searchstatement,-1,&statement,nil)==SQLITE_OK){
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    
                    char* Ccontent = (char*)sqlite3_column_text(statement, 1);
                    if (Ccontent == nil){
                        Ccontent = "";
                    }
                    NSInteger msgID = [[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)] integerValue];
                    NSString *content = [NSString stringWithCString:Ccontent encoding:NSUTF8StringEncoding];
                    NSString *sender = [NSString stringWithCString:(char*)sqlite3_column_text(statement,2) encoding:NSUTF8StringEncoding];
                    NSString *reciver = [NSString stringWithCString:(char*)sqlite3_column_text(statement,3) encoding:NSUTF8StringEncoding];
                    MSG *msg = [[MSG alloc] initWithID:msgID Content:content Sender:sender Reciver:reciver];
                    [resultArray addObject:msg];
                }
            }

            
            sqlite3_finalize(statement);
            sqlite3_close(dataBase);
        }
    }
    return resultArray;
}

- (BOOL)deleteByID:(NSInteger)msgID{
    const char* dbPath = [[[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"info.db"]] UTF8String];
    int msgid = (int)msgID;
    if (sqlite3_open(dbPath, &dataBase)==SQLITE_OK){
        NSString *deletesql = [NSString stringWithFormat:@"DELETE FROM MSG WHERE ID=%d",msgid];
        if ([self execSQL:deletesql]==SQLITE_OK){
            sqlite3_close(dataBase);
            return true;
        }else{
            sqlite3_close(dataBase);
            return false;
        }
    }else{
        return false;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    msgArray = [self getResult];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
    self.navigationItem.leftBarButtonItem = backItem;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)dismissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    MSG *msg = msgArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"收件人:%@",msg.reciver];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",msg.content];
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger msgID = [(MSG*)msgArray[indexPath.row] msgID];
        if([self deleteByID:msgID]){
            // Delete the row from the data source
            [msgArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController.title = @"提醒";
            [alertController addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDestructive handler:nil]];
            alertController.message = @"删除失败！为什么呢？";
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
