# Dynamic Form Builder V3

A powerful Flutter application for creating and managing dynamic forms with real-time configuration through Firebase Remote Config. This project enables users to build, customize, and deploy forms without code changes, supporting both single-page and multi-page form layouts.

## 🚀 Features

### Core Functionality
- **Dynamic Form Generation**: Create forms from JSON configuration files
- **Multi-Page Forms**: Support for complex multi-step form workflows with navigation
- **Real-Time Configuration**: Firebase Remote Config integration for instant form updates
- **Form Builder Interface**: Visual form builder with drag-and-drop functionality
- **Form Templates**: Save and reuse form configurations locally
- **Form Sharing**: Share forms via unique URLs with deep linking support
- **Form Preview**: Real-time preview of forms during building

### Form Components
- **Text Fields**: Single-line text input with validation and icons
- **Text Areas**: Multi-line text input with configurable rows and character limits
- **Date/Time Pickers**: Date and time selection components with custom formatting
- **Date Range Pickers**: Date range selection with validation and constraints
- **Selector Buttons**: Radio button and checkbox alternatives with custom styling
- **Switches**: Toggle components with custom styling and animations
- **Text Field Tags**: Tag-based input with autocomplete and validation
- **Dynamic Buttons**: Configurable buttons with custom actions and styling

### Advanced Features
- **Form Validation**: Real-time validation with custom error messages and regex patterns
- **State Management**: BLoC pattern for robust state handling across the app
- **Email Integration**: Automatic email notifications for form submissions via Mailjet
- **Form Submissions**: Store and manage form responses in Firestore
- **Responsive Design**: Works on web, mobile, and desktop platforms
- **Dark Theme**: Modern dark UI with customizable styling and color schemes
- **Component States**: Different visual states (base, error, success) for components
- **Form Variants**: Multiple variants for each component type

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/                    # Core utilities and services
│   ├── enums/              # Application enums and constants
│   ├── services/           # Core services (Email, Firestore)
│   └── utils/              # Utility functions and helpers
├── data/                   # Data layer
│   ├── models/             # Data models
│   │   ├── components/     # Form component models
│   │   ├── dynamic_form/   # Dynamic form models
│   │   ├── form_builder/   # Form builder models
│   │   ├── form_submission/# Form submission models
│   │   └── style/          # Styling models
│   └── repositories/       # Data repositories
├── domain/                 # Business logic layer
│   └── services/           # Domain services
├── presentation/           # UI layer
│   ├── blocs/             # State management with BLoC
│   ├── screens/           # Application screens
│   │   ├── form_builder/  # Form builder screens
│   │   ├── multi_screen/  # Multi-page form screens
│   │   └── watch_components_forms/ # Form viewing screens
│   └── widgets/           # Reusable widgets
└── config_json_files/     # Form configuration templates
```

### Technology Stack
- **Framework**: Flutter 3.8+
- **State Management**: flutter_bloc with BLoC pattern
- **Backend**: Firebase (Firestore, Remote Config)
- **Navigation**: GoRouter for deep linking
- **HTTP Client**: Dio for API calls
- **Email Service**: Mailjet integration
- **Storage**: SharedPreferences for local data
- **Environment**: flutter_dotenv for configuration management

## 📋 Prerequisites

- Flutter SDK 3.8.0 or higher
- Dart SDK 3.8.0 or higher
- Firebase project with Remote Config enabled
- Mailjet account for email functionality
- Git for version control

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dynamic_form_bi
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Enable Firestore and Remote Config
   - Download `google-services.json` for Android
   - Update `firebase_options.dart` with your project configuration

4. **Configure environment variables**
   - Copy `lib/dotenv_example` to `lib/dotenv`
   - Add your Mailjet credentials and backend URL:
   ```
   MAILJET_FROM_EMAIL=your-email@domain.com
   MAILJET_FROM_NAME=Your Name
   BACKEND_URL=https://your-backend-url.com
   BASE_URL=https://your-frontend-url.com
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 🎯 Usage

### Creating Forms

1. **Using Form Builder**
   - Navigate to the Form Builder screen
   - Drag and drop components to create your form
   - Configure component properties and validation rules
   - Preview the form in real-time
   - Save the form as a template

2. **Using JSON Configuration**
   - Create a JSON configuration file following the schema
   - Upload to Firebase Remote Config
   - The form will be automatically available in the app

### Form Configuration Schema

```json
{
  "formId": "unique_form_id",
  "name": "Form Name",
  "pages": [
    {
      "pageId": "page_1",
      "title": "Page Title",
      "order": 1,
      "show_previous_button": false,
      "show_next_button": true,
      "show_submit_button": false,
      "components": [
        {
          "id": "component_id",
          "type": "textFieldFormType",
          "config": {
            "placeholder": "Enter text",
            "is_required": true,
            "icon": "mail"
          },
          "style": {
            "border_color": "0xFF888888",
            "border_radius": 6,
            "font_size": 15,
            "text_color": "0xFFe0e0e0",
            "background_color": "0xFF000000"
          },
          "variants": {
            "with_icon": {
              "style": {
                "icon_position": "left",
                "icon_size": 18,
                "icon_color": "0xFFffffff"
              }
            }
          },
          "states": {
            "base": {
              "style": {
                "border_color": "0xFF888888"
              }
            },
            "error": {
              "style": {
                "border_color": "0xFFff4d4f",
                "text_color": "0xFFff4d4f",
                "helper_text": "Error message",
                "helper_text_color": "0xFFff4d4f"
              }
            },
            "success": {
              "style": {
                "border_color": "0xFF00b96b",
                "text_color": "0xFF00b96b"
              }
            }
          },
          "input_types": {
            "text": {
              "validation": {
                "regex": "^[a-zA-Z]+$",
                "error_message": "Only letters allowed",
                "min_length": 1,
                "max_length": 100
              }
            }
          }
        }
      ]
    }
  ]
}
```

### Component Types

- `textFieldFormType`: Single-line text input with validation
- `textAreaFormType`: Multi-line text input with configurable rows
- `dateTimePickerFormType`: Date/time picker with custom formatting
- `dateTimeRangePickerFormType`: Date range picker with validation
- `selectorButtonFormType`: Radio/checkbox buttons with custom styling
- `switchFormType`: Toggle switch with animations
- `textFieldTagsFormType`: Tag-based input with autocomplete
- `buttonFormType`: Custom buttons with actions

### Form Actions

- `nextPage`: Navigate to next page
- `previousPage`: Navigate to previous page
- `submitForm`: Submit the form
- `custom`: Custom action handling

## 📱 Screens

### Home Screen (`home_screen.dart`)
- Displays available form configurations
- Allows form selection and navigation
- Shows form templates and saved forms
- Quick access to form builder

### Dynamic Form Screen (`dynamic_form_screen.dart`)
- Renders single-page forms
- Handles form validation and submission
- Supports custom styling and themes
- Real-time validation feedback

### Multi-Page Form Screen (`dynamic_form_multi_screen.dart`)
- Manages multi-step form workflows
- Navigation between form pages
- Progress tracking and validation
- Page-specific validation rules

### Form Builder Screen (`form_builder_screen.dart`)
- Visual form builder interface
- Drag-and-drop component placement
- Real-time preview and configuration
- Component library and templates

### Form Builder Preview Screen (`form_builder_preview_screen.dart`)
- Live preview of forms being built
- Export to Firebase Remote Config
- JSON configuration generation
- Form testing and validation

### Saved Forms Screen (`saved_forms_screen.dart`)
- Lists saved form templates
- Template management (edit, delete, share)
- Form submission history
- Local storage management

### Shared Form Screen (`shared_form_screen.dart`)
- Public form access via URL
- Form submission without authentication
- Email notification integration
- Deep linking support

### Existing Forms Screen (`existing_forms_screen.dart`)
- Browse available form configurations
- Form selection and preview
- Configuration management

## 🎨 Styling System

The app uses a comprehensive styling system with:

### Component Styling
- **Border Styling**: Color, radius, width, opacity
- **Text Styling**: Font size, color, style, weight
- **Background**: Colors and transparency
- **Padding & Margins**: Spacing control
- **Icons**: Size, color, position

### State-based Styling
- **Base State**: Default component appearance
- **Error State**: Visual feedback for validation errors
- **Success State**: Positive feedback styling
- **Focus State**: Active component styling

### Theme System
- **Dark Theme**: Modern dark UI design
- **Custom Colors**: Configurable color schemes
- **Responsive Layout**: Adaptive design for different screen sizes
- **Component Variants**: Multiple styling options per component

## 🔧 Configuration

### Firebase Remote Config
The app uses Firebase Remote Config to manage form configurations:

1. Go to Firebase Console > Remote Config
2. Add new parameters with your form configurations
3. Set parameter values to JSON configurations
4. Publish the changes
5. Forms will be available in the app

### Email Configuration
Configure email notifications in the `lib/dotenv` file:
```
MAILJET_FROM_EMAIL=your-email@domain.com
MAILJET_FROM_NAME=Your Name
BACKEND_URL=https://your-backend-url.com
BASE_URL=https://your-frontend-url.com
```

### Environment Variables
The app uses environment variables for sensitive configuration:
- `MAILJET_FROM_EMAIL`: Email address for sending notifications
- `MAILJET_FROM_NAME`: Display name for email sender
- `BACKEND_URL`: Backend API endpoint
- `BASE_URL`: Frontend application URL

## 🔒 Security

- **Firestore Rules**: Configured security rules for data access
- **Input Validation**: Client-side and server-side validation
- **Email Verification**: Secure email delivery through Mailjet
- **Deep Link Security**: Protected form sharing URLs
- **Environment Variables**: Sensitive data stored in environment files

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
firebase deploy --only hosting
```

### Mobile Deployment
```bash
flutter build apk
flutter build ios
```

### Environment Setup
1. Configure production environment variables
2. Set up Firebase production project
3. Configure Mailjet production settings
4. Deploy backend services

## 📊 Monitoring & Analytics

- **Firebase Analytics**: Track form usage and submissions
- **Error Logging**: Comprehensive error tracking and reporting
- **Performance Monitoring**: Monitor app performance and user experience
- **Form Analytics**: Track form completion rates and user behavior

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes following the coding standards
4. Add tests if applicable
5. Update documentation
6. Submit a pull request

### Coding Standards
- Follow Flutter/Dart conventions
- Use BLoC pattern for state management
- Add proper error handling
- Include debug prints for tracing
- Write clear comments for complex logic

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation in the `docs/` folder
- Review the example configurations in `lib/config_json_files/`
- Contact the development team

## 🔄 Version History

### V3.0.0 (Current)
- **Multi-page forms**: Support for complex multi-step workflows
- **Enhanced form builder**: Improved drag-and-drop interface
- **Component variants**: Multiple styling options per component
- **State-based styling**: Different visual states for components
- **Real-time preview**: Live form preview during building
- **Export functionality**: Export forms to Firebase Remote Config
- **Improved validation**: Enhanced validation with custom messages
- **Better error handling**: Comprehensive error management

### V2.0.0
- **Form builder interface**: Visual form creation
- **Template system**: Save and reuse form configurations
- **Email integration**: Automatic email notifications
- **Form sharing**: Share forms via URLs
- **Enhanced styling**: Customizable component styling

### V1.0.0
- **Basic dynamic forms**: Single-page form support
- **Firebase integration**: Remote Config and Firestore
- **Component library**: Basic form components
- **Form validation**: Basic validation rules

## 🎯 Roadmap

### Upcoming Features
- [ ] **Advanced validation**: Complex validation rules and dependencies
- [ ] **Form analytics**: Detailed form usage analytics
- [ ] **User authentication**: User accounts and permissions
- [ ] **Form templates**: Pre-built form templates
- [ ] **API integration**: Connect forms to external APIs
- [ ] **File uploads**: Support for file attachments
- [ ] **Multi-language**: Internationalization support
- [ ] **Offline support**: Work offline with sync
- [ ] **Advanced styling**: CSS-like styling system
- [ ] **Form branching**: Conditional form logic

### Performance Improvements
- [ ] **Lazy loading**: Load components on demand
- [ ] **Caching**: Intelligent data caching
- [ ] **Optimization**: Performance optimizations
- [ ] **Bundle size**: Reduce app bundle size

---

**Built with ❤️ using Flutter and Firebase**