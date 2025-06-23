# Select Input Component Guide

## Tổng quan

Select Input component đã được thêm vào Dynamic Form Renderer để hỗ trợ các dropdown selection với nhiều tính năng đa dạng.

## Các tính năng chính

### 1. Select cơ bản

-  Dropdown đơn giản với danh sách options
-  Hỗ trợ placeholder và validation
-  Các trạng thái: base, error, success

### 2. Select với Icon

-  Hiển thị icon bên trái hoặc phải
-  Icon thay đổi theo trạng thái (check, close, etc.)
-  Hỗ trợ nhiều loại icon khác nhau

### 3. Select với Label

-  Label hiển thị phía trên select
-  Label color thay đổi theo trạng thái
-  Có thể tùy chỉnh font size và color

### 4. Multiple Selection

-  Cho phép chọn nhiều options
-  Giới hạn số lượng selection tối đa
-  Hiển thị dạng chips hoặc text

### 5. Searchable Select

-  Tìm kiếm trong danh sách options
-  Placeholder tùy chỉnh cho search box
-  Thông báo khi không tìm thấy kết quả

## Cấu trúc JSON

### Cấu trúc cơ bản

```json
{
   "id": "select_example",
   "type": "select",
   "order": 1,
   "config": {
      "label": "Label text",
      "placeholder": "Placeholder text",
      "icon": "icon_name",
      "isRequired": true,
      "multiple": false,
      "searchable": false,
      "options": [
         { "value": "value1", "label": "Label 1" },
         { "value": "value2", "label": "Label 2" }
      ]
   },
   "style": {
      "padding": "10px 12px",
      "borderColor": "#888888",
      "borderRadius": 6,
      "fontSize": 15,
      "color": "#e0e0e0",
      "backgroundColor": "#000000"
   },
   "variants": {
      "withLabel": {
         "style": { "labelTextSize": 14, "labelColor": "#3b82f6" }
      },
      "withIcon": {
         "style": {
            "iconPosition": "left",
            "iconSize": 18,
            "iconColor": "#ffffff"
         }
      },
      "multiple": {
         "style": { "maxSelections": 3, "selectionDisplay": "chips" }
      },
      "searchable": {
         "style": {
            "searchPlaceholder": "Tìm kiếm...",
            "noResultsText": "Không tìm thấy kết quả"
         }
      }
   },
   "states": {
      "base": { "style": { "borderColor": "#888888" } },
      "error": {
         "style": {
            "borderColor": "#ff4d4f",
            "color": "#ff4d4f",
            "icon": "close",
            "iconColor": "#ff4d4f",
            "labelColor": "#ff4d4f",
            "fontStyle": "italic",
            "helperText": "Error message",
            "helperTextColor": "#ff4d4f"
         }
      },
      "success": {
         "style": {
            "borderColor": "#00b96b",
            "color": "#00b96b",
            "icon": "check",
            "iconColor": "#00b96b",
            "labelColor": "#00b96b",
            "fontStyle": "italic",
            "helperText": "Success message",
            "helperTextColor": "#00b96b"
         }
      }
   },
   "validation": {
      "required": {
         "isRequired": true,
         "error_message": "Trường này là bắt buộc"
      },
      "maxSelections": {
         "max": 3,
         "error_message": "Chỉ được chọn tối đa 3 options"
      }
   }
}
```

## Các thuộc tính Config

| Thuộc tính    | Kiểu    | Mô tả                                  |
| ------------- | ------- | -------------------------------------- |
| `label`       | String  | Label hiển thị phía trên select        |
| `placeholder` | String  | Text hiển thị khi chưa chọn            |
| `icon`        | String  | Tên icon (xem danh sách icon bên dưới) |
| `isRequired`  | Boolean | Có bắt buộc hay không                  |
| `multiple`    | Boolean | Cho phép chọn nhiều options            |
| `searchable`  | Boolean | Có tính năng tìm kiếm                  |
| `options`     | Array   | Danh sách các options                  |

## Các thuộc tính Style

| Thuộc tính        | Kiểu   | Mô tả                     |
| ----------------- | ------ | ------------------------- |
| `padding`         | String | Padding của container     |
| `margin`          | String | Margin của container      |
| `borderColor`     | String | Màu viền                  |
| `borderRadius`    | Number | Bo góc                    |
| `fontSize`        | Number | Kích thước font           |
| `color`           | String | Màu text                  |
| `backgroundColor` | String | Màu nền                   |
| `labelTextSize`   | Number | Kích thước font label     |
| `labelColor`      | String | Màu label                 |
| `iconSize`        | Number | Kích thước icon           |
| `iconColor`       | String | Màu icon                  |
| `iconPosition`    | String | Vị trí icon (left/right)  |
| `fontStyle`       | String | Kiểu font (italic/normal) |
| `helperText`      | String | Text hỗ trợ               |
| `helperTextColor` | String | Màu text hỗ trợ           |

## Danh sách Icon hỗ trợ

### Icon cơ bản

-  `mail`, `check`, `close`, `error`, `user`, `lock`

### Icon cho Select

-  `chevron-down`, `chevron-up`, `globe`, `heart`, `search`
-  `location`, `calendar`, `phone`, `email`
-  `home`, `work`, `school`, `shopping`, `food`
-  `sports`, `music`, `movie`, `book`
-  `car`, `plane`, `train`, `bus`, `bike`, `walk`

## Cách sử dụng

### 1. Chạy ứng dụng

```bash
flutter run
```

### 2. Test với file JSON

Sử dụng file `test_select_input.json` để test các component select:

```dart
// Trong main.dart hoặc screen
Navigator.pushNamed(
  context,
  DynamicFormScreen.routeName,
  arguments: {
    'configKey': 'test_select_input',
    'title': 'Test Select Input',
  },
);
```

### 3. Tạo JSON config

Tạo file JSON với cấu trúc như ví dụ trên và load vào ứng dụng.

## Ví dụ sử dụng

### Select đơn giản

```json
{
   "id": "simple_select",
   "type": "select",
   "config": {
      "placeholder": "Chọn một tùy chọn",
      "isRequired": true,
      "options": [
         { "value": "1", "label": "Tùy chọn 1" },
         { "value": "2", "label": "Tùy chọn 2" }
      ]
   }
}
```

### Select với icon và label

```json
{
   "id": "icon_label_select",
   "type": "select",
   "config": {
      "label": "Chọn quốc gia",
      "placeholder": "Chọn quốc gia của bạn",
      "icon": "globe",
      "options": [
         { "value": "vn", "label": "Việt Nam" },
         { "value": "us", "label": "Hoa Kỳ" }
      ]
   }
}
```

### Multiple select

```json
{
   "id": "multiple_select",
   "type": "select",
   "config": {
      "label": "Chọn sở thích",
      "multiple": true,
      "options": [
         { "value": "reading", "label": "Đọc sách" },
         { "value": "music", "label": "Âm nhạc" }
      ]
   },
   "validation": {
      "maxSelections": {
         "max": 3,
         "error_message": "Chỉ được chọn tối đa 3 sở thích"
      }
   }
}
```

## Lưu ý

1. **Validation**: Select sử dụng field `validation` thay vì `inputTypes` như textfield
2. **Multiple Selection**: Khi `multiple: true`, component sẽ quản lý danh sách selected values
3. **Searchable**: Chỉ hoạt động khi `searchable: true` và có nhiều options
4. **States**: Các trạng thái base, error, success được áp dụng tự động dựa trên validation
5. **Icons**: Icon sẽ thay đổi theo trạng thái (check cho success, close cho error)

## Troubleshooting

### Lỗi thường gặp

1. **Icon không hiển thị**: Kiểm tra tên icon có trong danh sách hỗ trợ
2. **Validation không hoạt động**: Đảm bảo cấu trúc `validation` đúng format
3. **Multiple select không lưu**: Kiểm tra `multiple: true` trong config
4. **Search không hoạt động**: Đảm bảo `searchable: true` và có đủ options
