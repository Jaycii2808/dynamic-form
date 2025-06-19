# Dynamic UI BI - Firebase Remote Config

Hệ thống render UI động hoàn toàn từ JSON của Firebase Remote Config. Ban đầu UI trống, khi thêm JSON vào Firebase Remote Config thì UI sẽ được render động.

## Cấu trúc Project

```
lib/
├── core/
│   ├── models/
│   │   └── ui_component_model.dart        # Model cho UI components
│   ├── services/
│   │   └── remote_config_service.dart     # Service để fetch data từ Firebase
│   ├── bloc/
│   │   └── ui_bloc.dart                   # BLoC để quản lý state
│   ├── utils/
│   │   ├── loading_utils.dart             # Utility cho loading
│   │   └── style_utils.dart               # Utility để parse CSS styles
│   └── widgets/
│       ├── dynamic_page.dart              # Widget chính của page
│       └── dynamic_ui_renderer.dart       # Widget để render từng component
├── firebase_options.dart                  # Firebase configuration
└── main.dart                             # Entry point
```

## Cách sử dụng

### 1. Cài đặt dependencies

Đảm bảo các dependencies sau đã được thêm vào `pubspec.yaml`:

```yaml
dependencies:
   flutter:
      sdk: flutter
   firebase_core: ^3.14.0
   firebase_remote_config: ^5.4.5
   firebase_remote_config_web: ^1.8.5
   flutter_bloc: ^9.1.1
   equatable: ^2.0.7
```

### 2. Cấu hình Firebase

1. Tạo project trên Firebase Console
2. Thêm app Android/iOS
3. Download `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)
4. Đặt file vào thư mục tương ứng
5. Cấu hình Firebase Remote Config với key `ui_page`

### 3. JSON Structure

Đây là cấu trúc JSON mẫu cho UI page:

```json
{
   "pageId": "home_page",
   "title": "Home Page",
   "components": [
      {
         "id": "header_text",
         "type": "text",
         "order": 0,
         "config": {
            "text": "Welcome to Dynamic UI"
         },
         "style": {
            "fontSize": 24,
            "color": "#333333",
            "fontWeight": "bold",
            "textAlign": "center",
            "padding": "20px 16px"
         }
      },
      {
         "id": "content_container",
         "type": "container",
         "order": 1,
         "config": {},
         "style": {
            "backgroundColor": "#f5f5f5",
            "padding": "16px",
            "margin": "16px",
            "borderRadius": 8
         },
         "children": [
            {
               "id": "description_text",
               "type": "text",
               "order": 0,
               "config": {
                  "text": "This UI is rendered dynamically from Firebase Remote Config JSON."
               },
               "style": {
                  "fontSize": 16,
                  "color": "#666666",
                  "textAlign": "center"
               }
            },
            {
               "id": "action_button",
               "type": "button",
               "order": 1,
               "config": {
                  "text": "Click Me!"
               },
               "style": {
                  "backgroundColor": "#007bff",
                  "color": "#ffffff",
                  "padding": "12px 24px",
                  "borderRadius": 6,
                  "margin": "16px 0px"
               }
            }
         ]
      },
      {
         "id": "form_section",
         "type": "card",
         "order": 2,
         "config": {},
         "style": {
            "margin": "16px",
            "elevation": 4,
            "borderRadius": 8,
            "contentPadding": "16px"
         },
         "children": [
            {
               "id": "form_title",
               "type": "text",
               "order": 0,
               "config": {
                  "text": "Contact Form"
               },
               "style": {
                  "fontSize": 20,
                  "fontWeight": "bold",
                  "color": "#333333",
                  "margin": "0px 0px 16px 0px"
               }
            },
            {
               "id": "name_field",
               "type": "textfield",
               "order": 1,
               "config": {
                  "label": "Name",
                  "placeholder": "Enter your name"
               },
               "style": {
                  "margin": "8px 0px",
                  "borderRadius": 4
               }
            },
            {
               "id": "email_field",
               "type": "textfield",
               "order": 2,
               "config": {
                  "label": "Email",
                  "placeholder": "Enter your email"
               },
               "style": {
                  "margin": "8px 0px",
                  "borderRadius": 4
               }
            }
         ]
      }
   ]
}
```

### 4. Sử dụng trong app

```dart
import 'package:flutter/material.dart';
import 'core/widgets/dynamic_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DynamicPage(
        title: 'My Dynamic Page',
        onAction: (data) {
          print('Action triggered: $data');
        },
      ),
    );
  }
}
```

## Các loại Component được hỗ trợ

### 1. Container (`container`)

-  Container cơ bản với styling
-  Có thể chứa children components

### 2. Text (`text`)

-  Hiển thị text
-  Hỗ trợ styling: fontSize, color, fontWeight, textAlign

### 3. Button (`button`)

-  Button có thể click
-  Hỗ trợ styling và text

### 4. TextField (`textfield`)

-  Input field
-  Hỗ trợ label, placeholder

### 5. Image (`image`)

-  Hiển thị hình ảnh từ URL
-  Hỗ trợ width, height

### 6. Column (`column`)

-  Layout dọc
-  Hỗ trợ mainAxisAlignment, crossAxisAlignment

### 7. Row (`row`)

-  Layout ngang
-  Hỗ trợ mainAxisAlignment, crossAxisAlignment

### 8. Card (`card`)

-  Card với elevation
-  Hỗ trợ contentPadding

### 9. ListView (`listview`)

-  Danh sách scrollable
-  Hỗ trợ height

## Styling Properties

### CSS Properties được hỗ trợ:

-  `padding`: "10px 12px" hoặc "10px 12px 8px 6px"
-  `margin`: Tương tự padding
-  `backgroundColor`: Hex color (#dddddd) hoặc named color
-  `color`: Text color
-  `borderColor`: Border color
-  `borderRadius`: Số nguyên (px)
-  `fontSize`: Số nguyên (px)
-  `fontWeight`: "bold", "normal", "light"
-  `textAlign`: "center", "left", "right", "justify"
-  `width`: Số nguyên (px)
-  `height`: Số nguyên (px)
-  `elevation`: Số thực (cho Card)

### Layout Properties:

-  `mainAxisAlignment`: "center", "start", "end", "spacebetween", "spacearound", "spaceevenly"
-  `crossAxisAlignment`: "center", "start", "end", "stretch"

## Firebase Remote Config Setup

1. Vào Firebase Console > Remote Config
2. Tạo parameter với key: `ui_page`
3. Set value là JSON string của UI page
4. Publish changes

## Testing

### Ban đầu (UI trống):

-  Chạy app sẽ thấy màn hình "No UI Components Found"
-  Hướng dẫn thêm JSON vào Firebase

### Sau khi thêm JSON:

1. Copy JSON mẫu từ trên
2. Vào Firebase Console > Remote Config
3. Tạo parameter `ui_page`
4. Paste JSON vào value
5. Publish changes
6. Refresh app hoặc pull-to-refresh

## Troubleshooting

### Lỗi thường gặp:

1. **Firebase not initialized**: Đảm bảo đã gọi `Firebase.initializeApp()`
2. **JSON parsing error**: Kiểm tra cú pháp JSON
3. **Component not rendering**: Kiểm tra `type` field có đúng không
4. **Style not applying**: Kiểm tra property names

### Debug:

```dart
// Log UI page
final page = RemoteConfigService().getUIPage();
print('Page: ${page?.title}');
print('Components: ${page?.components.length}');

// Log component details
for (final component in page?.components ?? []) {
  print('Component: ${component.id} - ${component.type}');
}
```

## Ví dụ JSON phức tạp

```json
{
   "pageId": "dashboard",
   "title": "Dashboard",
   "components": [
      {
         "id": "header",
         "type": "row",
         "order": 0,
         "config": {},
         "style": {
            "backgroundColor": "#007bff",
            "padding": "16px",
            "mainAxisAlignment": "spacebetween"
         },
         "children": [
            {
               "id": "logo",
               "type": "text",
               "order": 0,
               "config": {
                  "text": "🚀 Dynamic UI"
               },
               "style": {
                  "fontSize": 20,
                  "color": "#ffffff",
                  "fontWeight": "bold"
               }
            },
            {
               "id": "menu_button",
               "type": "button",
               "order": 1,
               "config": {
                  "text": "Menu"
               },
               "style": {
                  "backgroundColor": "#ffffff",
                  "color": "#007bff",
                  "padding": "8px 16px",
                  "borderRadius": 4
               }
            }
         ]
      },
      {
         "id": "content_grid",
         "type": "column",
         "order": 1,
         "config": {},
         "style": {
            "padding": "16px"
         },
         "children": [
            {
               "id": "stats_row",
               "type": "row",
               "order": 0,
               "config": {},
               "style": {
                  "mainAxisAlignment": "spacearound",
                  "margin": "0px 0px 24px 0px"
               },
               "children": [
                  {
                     "id": "stat_card_1",
                     "type": "card",
                     "order": 0,
                     "config": {},
                     "style": {
                        "elevation": 2,
                        "borderRadius": 8,
                        "contentPadding": "16px"
                     },
                     "children": [
                        {
                           "id": "stat_value_1",
                           "type": "text",
                           "order": 0,
                           "config": {
                              "text": "1,234"
                           },
                           "style": {
                              "fontSize": 24,
                              "fontWeight": "bold",
                              "color": "#007bff",
                              "textAlign": "center"
                           }
                        },
                        {
                           "id": "stat_label_1",
                           "type": "text",
                           "order": 1,
                           "config": {
                              "text": "Users"
                           },
                           "style": {
                              "fontSize": 14,
                              "color": "#666666",
                              "textAlign": "center"
                           }
                        }
                     ]
                  }
               ]
            }
         ]
      }
   ]
}
```

## Contributing

1. Fork project
2. Tạo feature branch
3. Commit changes
4. Push to branch
5. Tạo Pull Request

## License

MIT License
