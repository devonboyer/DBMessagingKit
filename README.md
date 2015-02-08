#DBMessagingKit

######TimestampStyleHidden                             TimestampStyleSliding######

![alt tag](https://cloud.githubusercontent.com/assets/5367914/5310054/ceb41222-7bfa-11e4-858e-2c6a7fe4c055.gif)
        
![alt tag](https://cloud.githubusercontent.com/assets/5367914/6097248/707975a4-af84-11e4-989e-a19cb0ca4708.gif)
####What is this repository for?####

An open-source messaging UI framework for iOS, built with simplicity and customization in mind.

####Supports####
 Supports the following MIME types (Internet Media Type):
 - Text
 - Image
 - Movie
 - GIF
 - Location (In development)

####Features####
- Multiple timestamp styles
- Interactive Keyboard Dismiss

Supports iOS 7.0+, Portrait/Landscape iPhone/iPad

####How do I get set up?####
#####View Controller#####
- Subclass DBMessagingViewController.
- Implement the required and optional methods in the DBMessagingCollectionViewDataSource protocol.
- Implement the optional methods in the DBMessagingCollectionViewDelegateFlowLayout protocol.
- Set the 'timestampStyle' of your view controller subclass to DBMessagingTimestampStyleNone, DBMessagingTimestampStyleHidden, or DBMessagingTimestampStyleSliding.

#####Message Bubbles#####
- For complex message bubble layouts (such as Facebook Messenger) you can use a DBMessageBubbleController to figure out for you which message bubble should be displayed for a given message.
- Message bubbles can be created by passing "template" images to an instance of DBMessageBubbleController.
- Message bubbles will revert to the "default" message bubble if a top, middle, or bottom message bubble has not been specified. A "default" message bubble must be specified.
- You can optionally return a message bubble (UIImageView) in the appropriate dataSource method of your choice or use the convience method messageBubbleForItemAtIndexPath: of a DBMessageBubbleController.

#####Customization#####
- The library is well-commented. This should help you configure your view however you like.

####What's Next?####

- Springy bubbles
- Support for 'DBMessagingInputToolbarItemPositionTop' and 'DBMessagingInputToolbarItemPositionBottom'
