UIImage+RoundedImage
=================================

A category for UIImage which takes and UIImage and applies a circular path as a mask.

+ (UIImage *)roundedImageWithImage:(UIImage *)image;

EXAMPLE:

UIImage *originalImage = [UIImage imageNamed:@"myimage.png"];
UImage *myRoundedImage = [UIImage roundedImageWithImage:originalImage];

IMPORTANT NOTE:

Your image needs to have an alpha channel, or it will have black background around the circle. You can fix that behavior either in Photoshop, or by using the UIImage+Alpha category. I have it forked.