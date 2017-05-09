//
//  ViewController.m
//  payments
//
//  Created by Chan on 5/8/17.
//  Copyright © 2017 Chan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 
@property (strong, nonatomic) UITextField *creditCardField;
@property (strong) NSString *finalCCNumber;
@end

@implementation ViewController
NSString *previousTextFieldContent;
UITextRange *previousSelection;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.creditCardField = [[UITextField alloc] init];
    self.creditCardField.delegate = self;
    [self.creditCardField addTarget:self action:@selector(reformatAsCardNumber:) forControlEvents:UIControlEventEditingChanged];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    CGFloat height = screenRect.size.height;
    UIToolbar *numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)], [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    [numberToolbar sizeToFit];
    self.creditCardField.inputAccessoryView = numberToolbar;
    
    
    [self.creditCardField setBounds:CGRectMake(0, 0, 300, 44)];
    [self.creditCardField setFrame:CGRectMake(width / 2 - 150, height / 2 - 22, 300, 44)];
    self.creditCardField.placeholder = @"Enter credit-card number";
    self.creditCardField.keyboardType = UIKeyboardTypeNumberPad;
    self.creditCardField.layer.borderColor = [UIColor grayColor].CGColor;
    self.creditCardField.layer.borderWidth = 1.0;
    [self.view addSubview:self.creditCardField];
}

-(void)doneWithPad {
    [self.creditCardField resignFirstResponder];
}

-(void)reformatAsCardNumber:(UITextField *)textfield {
    NSUInteger targetCursorPosition = [textfield offsetFromPosition:textfield.beginningOfDocument toPosition:textfield.selectedTextRange.start];
    NSString *cardNumberWithoutSpace = [self removeNonDigits:textfield.text andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cardNumberWithoutSpace length] > 16) {
        [textfield setText:previousTextFieldContent];
        [textfield setSelectedTextRange:previousSelection];
        return;
    }
    
    NSString *cardNumberWithSpaces = [self addSpaceEveryFourDigits:cardNumberWithoutSpace andPreserverCursorPosition:&targetCursorPosition];
    
    textfield.text = cardNumberWithSpaces;
    UITextPosition *targetPosition = [textfield positionFromPosition:[textfield beginningOfDocument] offset:targetCursorPosition];
    [textfield setSelectedTextRange:[textfield textRangeFromPosition:targetPosition toPosition:targetPosition]];
    
}

-(NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPos {
    NSUInteger originalCursorPosition = *cursorPos;
    NSMutableString *digitsOnly = [NSMutableString new];
    for (NSUInteger i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (isdigit(c)) {
            NSString *stringToAdd = [NSString stringWithCharacters:&c length:1];
            [digitsOnly appendString:stringToAdd];
        } else {
            if (i < originalCursorPosition) {
                (*cursorPos)--;
            }
        }
    }
    return digitsOnly;
}

-(NSString *)addSpaceEveryFourDigits:(NSString *)string andPreserverCursorPosition:(NSUInteger *)cursorPos {
    NSUInteger originalCursorPosition = *cursorPos;
    NSMutableString *stringWithSpaces = [NSMutableString new];
    for (NSUInteger i = 0; i < [string length]; i++) {
        if (i % 4 == 0 && i > 0) {
            [stringWithSpaces appendString:@" "];
            if (i < originalCursorPosition) {
                (*cursorPos)++;
            }
        }
        unichar c = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&c length:1];
        [stringWithSpaces appendString:stringToAdd];
//        [stringWithSpaces appendString:[]
    }
    return stringWithSpaces;
}


# pragma mark - Textfield Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    // Note textField's current state before performing the change, in case
    // reformatTextField wants to revert it
    previousTextFieldContent = textField.text;
    previousSelection = textField.selectedTextRange;
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSRange visibleRange = NSMakeRange(textField.text.length - 4, textField.text.length);
    self.finalCCNumber = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableString *replaceStr = [NSMutableString new];
    

    for (int i=0;i < self.finalCCNumber.length;i++) {
        if (i < 12) {
            [replaceStr appendString:@"●"];
        } else {
            unichar c = [self.finalCCNumber characterAtIndex:i];
            [replaceStr appendString:[NSString stringWithCharacters:&c length:1]];
        }
    }
    
    textField.text = replaceStr;
    
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
