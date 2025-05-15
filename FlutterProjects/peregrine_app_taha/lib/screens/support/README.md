# Support Team Screens

This directory contains the screens for the Support Team role in the Peregrine App.

## Screens

### 1. SupportDashboardScreen

The main dashboard for support team members, displaying a list of client requests with:
- Beautiful animated cards for each request
- Status indicators (new, pending, resolved)
- Client information
- Request details
- Time elapsed since request creation

Features:
- Smooth animations when loading the list
- Hero animations when transitioning to details
- Pull to refresh functionality
- Empty state handling

### 2. SupportRequestDetailsScreen

Detailed view of a specific support request with:
- Full request information
- Chat-like message history with styled bubbles
- Reply functionality
- Option to mark requests as resolved

Features:
- RTL-friendly chat interface
- Animated transitions
- Status management
- Real-time message updates

## Implementation Details

Both screens follow the app's design guidelines:
- Golden-brown color theme from AppTheme
- Cairo font for Arabic text
- RTL layout support
- Shadowed cards with rounded corners
- Proper spacing and visual hierarchy
- Animations for enhanced user experience

## Models

The screens use the `SupportRequest` and `Message` models defined in `lib/models/support_request.dart`.

## Utilities

Date formatting is handled by the `DateFormatter` utility in `lib/utils/date_formatter.dart`.