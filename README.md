#DBMessagingKit

######TimestampStyleHidden                             TimestampStyleSliding######

![alt tag](https://cloud.githubusercontent.com/assets/5367914/5310054/ceb41222-7bfa-11e4-858e-2c6a7fe4c055.gif)
        
![alt tag](https://cloud.githubusercontent.com/assets/5367914/6097248/707975a4-af84-11e4-989e-a19cb0ca4708.gif)
####What is this repository for?####

An open-source Messaging UI Kit for iOS, built with simplicity and customization in mind. The kit provides the tools to create a messaging interface while allowing it to work with your app's schema.

####Supports####
 Supports the following MIME types (Internet Media Type):
 - Text
 - Image
 - Video (In development)
 - Location (In development)

Supports iOS 7.0+, Portrait/Landscape iPhone/iPad

####Features####
- Multiple timestamp styles
- Interactive Keyboard Dismiss
- Customize cell labels
- Customize toolbar buttons
- Arbitrary message sizes
- Data detectors
- Dynamic input text view resizing
- Timestamp formatting

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

####Components####

A component is built to handle a common task in a messging interface. Components are completly optional.

#####DBMessagingPhotoPickerController#####

A 'DBMessagingPhotoPickerController' provides an interface to quickly choose a photo from the user's recent photos. This component was modelled after a similar photo picker found in iMessage.

