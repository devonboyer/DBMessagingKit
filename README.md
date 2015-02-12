#DBMessagingKit

![alt tag](https://cloud.githubusercontent.com/assets/5367914/5310054/ceb41222-7bfa-11e4-858e-2c6a7fe4c055.gif)
                 
![alt tag](https://cloud.githubusercontent.com/assets/5367914/6097248/707975a4-af84-11e4-989e-a19cb0ca4708.gif)

*DBMessagingTimestampStyleHidden                  DBMessagingTimestampStyleSliding*


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
- Subclass ```DBMessagingViewController```
- Implement the required and optional methods in ```DBMessagingCollectionViewDataSource```
- Implement the optional methods in ```DBMessagingCollectionViewDelegateFlowLayout```
- Set the 'timestampStyle' of your view controller subclass to ```DBMessagingTimestampStyleNone```, ```DBMessagingTimestampStyleHidden```, or ```DBMessagingTimestampStyleSliding```.

#####Message Bubbles#####
- For complex message bubble layouts (such as Facebook Messenger) you can use a ```DBMessageBubbleController``` to figure out for you which message bubble should be displayed for a given message.
- Message bubbles can be created by passing 'template' images to an instance of ```DBMessageBubbleController```.
- You can optionally return a message bubble (UIImageView) in the appropriate dataSource method of your choice or use the convience method ```messageBubbleForItemAtIndexPath:``` of a ```DBMessageBubbleController```.

#####Input Toolbar#####

The input toolbar's buttons are totally up to you. It is recommended that you add a 'send' button and set it as the toolbar's send button property. You are in charge of handling each button's 'action'.

```objectiveC
    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera_button"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraButtonTapped:)];
    UIBarButtonItem *sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonTapped:)];
    
    [self.messageInputToolbar addItem:cameraBarButtonItem position:DBMessagingInputToolbarItemPositionLeft animated:false];
    [self.messageInputToolbar addItem:locationBarButtonItem position:DBMessagingInputToolbarItemPositionRight animated:false];
```

#####Mime Types#####

You can choose the 'mime' type that should correspond to each cell. The 'mime' type is used to decide which
type of view should be used to display the value for a given message. The mime type can be accessed at any 
time by calling [DBMessagingTextCell mimeType].

Examples of possible mime types and associated values (again these are totally up to your app's schema):
- mime -> 'image/url'       value -> The URL for the remote image or video.
- mime -> 'image/plain'   value -> A base64 encoded string representing an image or video from a socket.
- mime -> 'geo/json'        value -> A JSON string representing a geolocation.
- mime -> 'image/jpeg',   value -> An image retrieved from disk.

```objectiveC
    [DBMessagingTextCell setMimeType:@"text/plain"];
    [DBMessagingImageMediaCell setMimeType:@"image/jpeg"];
    [DBMessagingVideoMediaCell setMimeType:@"video/mp4"];
    [DBMessagingLocationMediaCell setMimeType:@"geo"];
```

#####Customization#####
- The library is well-commented. This should help you configure your view however you like.

####Components####

A component is built to handle a common task in a messging interface. Components are completly optional.

#####DBMessagingPhotoPickerController#####

A 'DBMessagingPhotoPickerController' provides an interface to quickly choose a photo from the user's recent photos. This component was modelled after a similar photo picker found in iMessage.

The 'DBMessagingPhotoPickerController' is only available in iOS8.

![alt tag](https://cloud.githubusercontent.com/assets/5367914/6176598/2ad436ea-b2ce-11e4-9760-8ab1647d174d.png)
