//
//  ViewController.m
//  SQLiteTest
//
//  Created by 谭钧豪 on 16/6/21.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"
#define screen [UIScreen mainScreen].bounds

@interface ViewController ()

@property sqlite3 *dataBase;

@end

@implementation ViewController
{
    NSString *databasePath;
    __weak IBOutlet UILabel *statusLabel;
    __weak IBOutlet UITextField *senderNameLabel;
    __weak IBOutlet UITextField *reciverNameLabel;
    __weak IBOutlet UITextView *contentTextView;
}
@synthesize dataBase;

- (IBAction)saveMsg:(id)sender {
    sqlite3_stmt *statement;
    
    const char *dbPath = [databasePath UTF8String];
    
    if (sqlite3_open(dbPath, &dataBase)==SQLITE_OK){
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"提醒";
        [alertController addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDestructive handler:nil]];
        if ([senderNameLabel.text isEqualToString:@""]){
            alertController.message = @"你的姓名不能为空";
            [self presentViewController:alertController animated:YES completion:nil];
        }else if ([reciverNameLabel.text isEqualToString:@""]){
            alertController.message = @"接受人姓名不能为空";
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            alertController = nil;
            NSString *insertsql = [NSString stringWithFormat:@"INSERT INTO MSG(SENDER,RECIVER,CONTENT) VALUES('%@','%@','%@')",senderNameLabel.text,reciverNameLabel.text,contentTextView.text];
            const char *insertstatement = [insertsql UTF8String];
            sqlite3_prepare_v2(dataBase,insertstatement,-1,&statement,nil);
            if (sqlite3_step(statement)==SQLITE_DONE){
                [self clearText];
                statusLabel.text = @"成功保存到数据库";
            }else{
                statusLabel.text = @"保存失败";
            }
            sqlite3_finalize(statement);
            sqlite3_close(dataBase);
        }
    }

}
- (IBAction)search:(id)sender {
    if ([senderNameLabel.text isEqualToString:@""]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"你的姓名不能为空。" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *alert){
            [senderNameLabel becomeFirstResponder];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        [self performSegueWithIdentifier:@"search" sender:self];
    }
    
    
}

- (IBAction)clearText:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:@"确定要清除文本框内容吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self clearText];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)clearText{
    statusLabel.text = @"";
    senderNameLabel.text = @"";
    reciverNameLabel.text = @"";
    contentTextView.text = @"";
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"info.db"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSLog(@"数据库文件路径：%@",databasePath);
    
    if ([fileManager fileExistsAtPath:databasePath] == NO){
        const char *dbPath = [databasePath UTF8String];
        if (sqlite3_open(dbPath, &dataBase)==SQLITE_OK){
            char *errmsg;
            const char *createsql = "CREATE TABLE IF NOT EXISTS MSG(ID INTEGER PRIMARY KEY AUTOINCREMENT,CONTENT TEXT,SENDER TEXT,RECIVER TEXT)";
            if (sqlite3_exec(dataBase, createsql, NULL, NULL, &errmsg)!=SQLITE_OK){
                statusLabel.text = @"创建表失败";
            }else{
                NSLog(@"创建成功");
            }
        }else{
            statusLabel.text = @"创建或打开失败";
        }
    }
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [statusLabel resignFirstResponder];
    [senderNameLabel resignFirstResponder];
    [reciverNameLabel resignFirstResponder];
    [contentTextView resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UINavigationController *navController = [segue destinationViewController];
    navController.title = senderNameLabel.text;
    TableViewController *tableViewController = [navController viewControllers][0];
    tableViewController.myname = senderNameLabel.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
