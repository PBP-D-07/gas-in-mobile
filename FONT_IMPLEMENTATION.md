# Font Implementation Guide - GAS.in App

## Status

✅ **Partially Implemented** - Foundation setup completed

## What's Been Done

### 1. Dependencies Added

- ✅ `google_fonts: ^6.1.0` added to pubspec.yaml

### 2. New Theme Files Created

#### `/lib/theme/app_theme.dart`

- Centralized theme configuration with Google Fonts
- **Heading Styles (Poppins):** h1-h5 with proper sizes and weights
- **Body Styles (Open Sans):** bodyL, bodyM, bodyS
- **Label & Button Styles:** Pre-configured for consistency
- **Caption Styles:** For secondary text

#### `/lib/theme/app_text.dart`

- Helper class for quick access to text styles
- Usage: `AppText.h1`, `AppText.bodyM`, `AppText.button`, etc.

### 3. Main App Updated

- ✅ `lib/main.dart` - Now uses `AppTheme.getThemeData()`

## Font Specifications

### Headers (Poppins)

```
h1: 32px, Bold
h2: 24px, W900
h3: 20px, Bold
h4: 18px, W600
h5: 16px, W600
```

### Body Text (Open Sans)

```
bodyL: 16px, W500
bodyM: 14px, W400 (Standard body text)
bodyS: 12px, W400
```

### Buttons

```
labelL: 14px, W600, White
labelM: 12px, W600, White
button: 16px, W600, White
```

## How to Use in Your Code

### Option 1: Direct Usage (Recommended)

```dart
import 'package:gas_in/theme/app_text.dart';

Text('Your Heading', style: AppText.h2),
Text('Body text here', style: AppText.bodyM),
```

### Option 2: With Modifications

```dart
Text(
  'Custom Text',
  style: AppText.h3.copyWith(color: Colors.red),
)
```

### Option 3: Theme Integration

```dart
// Already configured in main.dart
// The app-wide theme applies automatically
Text('This uses theme defaults') // Inherits from context theme
```

## Files That Need Updates (Priority Order)

### High Priority (Main User Screens)

1. `lib/screens/menu.dart` - Home page (partially done)
2. `lib/screens/login.dart` - Login screen
3. `lib/screens/register.dart` - Registration screen
4. `lib/EventMakerModule/screens/create_event.dart` - Event creation
5. `lib/EventMakerModule/screens/edit_event.dart` - Event editing

### Medium Priority (Secondary Screens)

6. `lib/ForumModule/screens/forumMenu.dart` - Forum page
7. `lib/ForumModule/screens/postlist_form.dart` - Post form
8. `lib/VenueModule/screens/venue_entry_list.dart` - Venue listing
9. `lib/VenueModule/screens/venue_form.dart` - Venue form

### Low Priority (Widgets & Components)

10. `lib/ForumModule/widgets/post_card_entry.dart` - Forum card
11. `lib/VenueModule/widgets/venue_entry_card.dart` - Venue card
12. `lib/widgets/left_drawer.dart` - Navigation drawer
13. `lib/screens/pop_up_logo.dart` - Splash screen

## Migration Example

### Before

```dart
Text(
  'Welcome',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  ),
)
```

### After

```dart
import 'package:gas_in/theme/app_text.dart';

Text(
  'Welcome',
  style: AppText.h2.copyWith(color: Colors.deepPurple),
)
```

## Key Benefits

✨ Consistency across the entire app
✨ Easy to update all fonts in one place
✨ Better readability on mobile devices
✨ Professional appearance
✨ Meets modern design standards

## Next Steps

To complete the implementation:

1. Replace `TextStyle(...)` with `AppText.[style]` in all screens
2. Use `.copyWith()` for custom color/weight variations
3. Test on different screen sizes
4. Run `flutter pub get` to install google_fonts package
5. Test on iOS and Android devices

## Quick Reference

| Use Case         | Style             |
| ---------------- | ----------------- |
| Page Title       | `AppText.h2`      |
| Section Title    | `AppText.h3`      |
| Subtitle         | `AppText.h4`      |
| Main body text   | `AppText.bodyM`   |
| Helper/hint text | `AppText.bodyS`   |
| Button text      | `AppText.button`  |
| Labels           | `AppText.labelL`  |
| Caption/metadata | `AppText.caption` |
