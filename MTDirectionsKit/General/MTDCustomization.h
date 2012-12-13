//
//  MTDCustomization.h
//  MTDirectionsKit
//
//  Created by Matthias Tretter
//  Copyright (c) 2012 Matthias Tretter (@myell0w). All rights reserved.
//


// Used to annotate classes in the headers, that support customization by overriding
#define MTD_CUSTOMIZATION_SUPPORTED


/**
 Use this to use specific subclasses instead of the default MTD* classes.

 E.g. add an entry for [MTDDirectionsOverlayView class] / [MyCustomOverlayView class] to use a custom subclass instead of MTDDirectionsOverlayView.
 MyCustomOverlayView must be a subclass of MTDDirectionsOverlayView, otherwise an exception is thrown.

 Note: Currently the only supported class for this usage is MTDDirectionsOverlayView
 */
void MTDOverrideClass(Class classToOverride, Class classToUseInstead);

/**
 In case baseClass was previously overridden with a valid subclass by using MTDOverrideClass the subclass is returned.

 @param baseClass the class we want to check
 @return an overridden subclass or baseClass in case there is no valid override
 */
Class MTDOverriddenClass(Class baseClass);
