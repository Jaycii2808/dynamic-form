# JSON-Driven Validation Guide

## Tổng quan

BLoC đã được refactor để sử dụng hoàn toàn **JSON-driven validation** thay vì hard-code logic trong BLoC. Tất cả validation rules, error messages, và UI states đều được định nghĩa trong JSON configuration.

## Cấu trúc JSON Validation

### 1. Input Types & Validation Rules

```json
{
   "input_types": {
      "text": {
         "validation": {
            "regex": "^[a-zA-Z0-9]{3,20}$",
            "error_message": "Tên đăng nhập phải từ 3-20 ký tự, chỉ chứa chữ cái và số",
            "min_length": 3,
            "max_length": 20
         }
      },
      "email": {
         "validation": {
            "regex": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
            "error_message": "Định dạng email không hợp lệ",
            "min_length": 5,
            "max_length": 100
         }
      }
   }
}
```

### 2. Required Field Configuration

```json
{
   "config": {
      "is_required": true,
      "required_message": "Tên đăng nhập không được để trống"
   }
}
```

### 3. States & Dynamic Styling

```json
{
   "states": {
      "base": {
         "style": {
            "border_color": "#E5E7EB",
            "helper_text": "Tên đăng nhập từ 3-20 ký tự",
            "helper_text_color": "#6B7280"
         }
      },
      "error": {
         "style": {
            "border_color": "#EF4444",
            "border_width": 2,
            "color": "#EF4444",
            "helper_text_color": "#EF4444"
         }
      },
      "success": {
         "style": {
            "border_color": "#10B981",
            "border_width": 2,
            "icon": "check",
            "icon_color": "#10B981",
            "helper_text": "Tên đăng nhập hợp lệ",
            "helper_text_color": "#10B981"
         }
      }
   }
}
```

## Validation Rules Supported

### 1. Text Validation

-  `regex`: Pattern validation
-  `min_length`: Minimum character length
-  `max_length`: Maximum character length
-  `error_message`: Custom error message

### 2. Email Validation

```json
{
   "regex": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
   "error_message": "Định dạng email không hợp lệ"
}
```

### 3. Password Validation

```json
{
   "regex": "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$",
   "error_message": "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường và số"
}
```

### 4. Phone Number Validation (Vietnam)

```json
{
   "regex": "^(0[3|5|7|8|9])+([0-9]{8})$",
   "error_message": "Số điện thoại không đúng định dạng (VD: 0901234567)"
}
```

## BLoC Events

### 1. Auto Validation on Input Change

```dart
// Tự động validate khi user nhập
context.read<DynamicFormBloc>().add(
  UpdateFormFieldEvent(
    componentId: 'username_field',
    value: 'user_input_text'
  )
);
```

### 2. Validate All Fields

```dart
// Validate tất cả fields và hiện lỗi ngay lập tức
context.read<DynamicFormBloc>().add(
  ValidateAllFormFieldsEvent(showErrorsImmediately: true)
);

// Validate nhưng không hiện lỗi (chỉ check)
context.read<DynamicFormBloc>().add(
  ValidateAllFormFieldsEvent(showErrorsImmediately: false)
);
```

## Flow Hoạt động

### 1. User Input → Auto Validation

```
User types → UpdateFormFieldEvent → BLoC validates using JSON rules → Update component state
```

### 2. Form Submission → Full Validation

```
Submit button pressed → ValidateAllFormFieldsEvent → Check all fields → Show errors if any
```

### 3. Dynamic UI State Changes

```
Validation result → Update component state (base/error/success) → Apply JSON-defined styles
```

## Ví dụ Implementation

### 1. Component với Validation

```json
{
   "id": "username_field",
   "type": "textFieldFormType",
   "config": {
      "label": "Tên đăng nhập",
      "is_required": true,
      "required_message": "Tên đăng nhập không được để trống"
   },
   "input_types": {
      "text": {
         "validation": {
            "regex": "^[a-zA-Z0-9]{3,20}$",
            "error_message": "Tên đăng nhập phải từ 3-20 ký tự, chỉ chứa chữ cái và số",
            "min_length": 3,
            "max_length": 20
         }
      }
   },
   "states": {
      "error": {
         "style": {
            "border_color": "#EF4444",
            "color": "#EF4444"
         }
      },
      "success": {
         "style": {
            "border_color": "#10B981",
            "icon": "check",
            "icon_color": "#10B981"
         }
      }
   }
}
```

### 2. Button với Conditions

```json
{
   "id": "submit_button",
   "config": {
      "conditions": [
         {
            "componentId": "username_field",
            "rule": "not_empty",
            "expectedValue": true,
            "errorMessage": "Tên đăng nhập chưa được nhập"
         }
      ]
   }
}
```

## Lợi ích

✅ **Không hard-code**: Tất cả validation logic nằm trong JSON  
✅ **Flexible**: Dễ dàng thay đổi rules mà không cần build lại app  
✅ **Consistent**: Validation logic nhất quán trên toàn app  
✅ **Dynamic UI**: Styles thay đổi theo state validation từ JSON  
✅ **Maintainable**: Code BLoC sạch, logic validation tập trung

## Testing

Để test validation, chỉ cần tạo JSON config với rules khác nhau:

```dart
// Test validation
context.read<DynamicFormBloc>().add(
  ValidateAllFormFieldsEvent(showErrorsImmediately: true)
);

// Check validation results in BLoC state
final validationErrors = state.page?.components
  .where((c) => c.config['error_text'] != null)
  .length ?? 0;
```
