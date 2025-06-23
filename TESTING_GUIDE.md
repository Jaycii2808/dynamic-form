# Hướng dẫn Test Dynamic UI với Variants và States

## Cách thêm JSON vào Firebase Remote Config

### 1. Truy cập Firebase Console

-  Vào [Firebase Console](https://console.firebase.google.com/)
-  Chọn project của bạn
-  Vào **Remote Config** trong menu bên trái

### 2. Thêm JSON Configuration

-  Click **Add your first parameter** hoặc **Add parameter**
-  **Parameter key**: `ui_page`
-  **Value**: Copy toàn bộ nội dung từ file `test_complete_ui.json`
-  Click **Publish changes**

## Các trường hợp test

### 1. Text Input Template

**Component ID**: `text_input_template`

**Variants test**:

-  ✅ **withLabel**: Hiển thị label "Working remotely"
-  ✅ **withIcon**: Sẽ áp dụng khi có icon (hiện tại chưa có icon)
-  ✅ **normal**: Style mặc định

**States test**:

-  ✅ **default**: Border màu #dddddd
-  ✅ **focus**: Khi click vào input, border chuyển sang #007bff
-  ✅ **disabled**: Khi editable = false

**Validation test**:

-  ✅ **text**: Regex `^[a-zA-ZÀ-ỹ\\s]{2,50}$`
   -  Test với: "Nguyễn Văn A" ✅
   -  Test với: "A" ❌ (quá ngắn)
   -  Test với: "123" ❌ (có số)
-  ✅ **email**: Regex `^[^@]+@[^@]+\\.[^@]+$`
   -  Test với: "test@example.com" ✅
   -  Test với: "invalid-email" ❌
-  ✅ **password**: Regex `^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$`
   -  Test với: "Password123" ✅
   -  Test với: "123456" ❌ (thiếu chữ)
   -  Test với: "abcdef" ❌ (thiếu số)
-  ✅ **tel**: Regex cho số điện thoại Việt Nam
   -  Test với: "0123456789" ✅
   -  Test với: "+84123456789" ✅
   -  Test với: "123" ❌ (quá ngắn)

### 2. Email Input

**Component ID**: `email_input`

**Test cases**:

-  ✅ **Required field**: Bỏ trống sẽ hiển thị lỗi
-  ✅ **Email validation**: Chỉ chấp nhận email hợp lệ
-  ✅ **Focus state**: Border chuyển sang màu xanh khi focus
-  ✅ **Error state**: Border đỏ khi có lỗi validation

### 3. Password Input

**Component ID**: `password_input`

**Test cases**:

-  ✅ **Password visibility**: Text bị ẩn (obscureText = true)
-  ✅ **Required field**: Bỏ trống sẽ hiển thị lỗi
-  ✅ **Password validation**: Phải có cả chữ và số, tối thiểu 6 ký tự
-  ✅ **Focus state**: Border chuyển sang màu xanh khi focus

### 4. Phone Input

**Component ID**: `phone_input`

**Test cases**:

-  ✅ **Not required**: Có thể bỏ trống
-  ✅ **Phone validation**: Chỉ chấp nhận số điện thoại Việt Nam hợp lệ
-  ✅ **Keyboard type**: Hiển thị bàn phím số
-  ✅ **Focus state**: Border chuyển sang màu xanh khi focus

### 5. Submit Button

**Component ID**: `submit_button`

**Variants test**:

-  ✅ **primary**: Màu xanh (#2196f3)
-  ✅ **secondary**: Màu xám (#6c757d)
-  ✅ **success**: Màu xanh lá (#28a745)

**States test**:

-  ✅ **default**: Màu xanh mặc định
-  ✅ **hover**: Màu xanh đậm hơn (#1976d2)
-  ✅ **disabled**: Màu xám nhạt (#cccccc)

## Cách test từng trường hợp

### 1. Test Variants

```bash
# Trong Firebase Remote Config, thay đổi variant trong JSON:
"variants": {
  "withLabel": {
    "style": {
      "labelTextSize": 18,  // Thay đổi size
      "labelColor": "#ff0000"  // Thay đổi màu đỏ
    }
  }
}
```

### 2. Test States

```bash
# Thay đổi state styles:
"states": {
  "focus": {
    "style": {
      "borderColor": "#ff0000",  // Border đỏ khi focus
      "backgroundColor": "#ffffcc"  // Background vàng nhạt
    }
  }
}
```

### 3. Test Validation

```bash
# Thay đổi validation rules:
"validation": {
  "regex": "^[A-Za-z]+$",  // Chỉ chấp nhận chữ cái
  "error_message": "Chỉ được nhập chữ cái",
  "min_length": 3,
  "max_length": 20
}
```

## JSON Test Cases

### Test Case 1: Basic Form

```json
{
   "title": "Basic Form Test",
   "components": [
      {
         "id": "name_input",
         "type": "textfield",
         "config": {
            "label": "Họ và tên",
            "placeholder": "Nhập họ và tên",
            "isRequired": true
         },
         "style": {
            "padding": "12px 16px",
            "borderColor": "#e0e0e0",
            "borderRadius": 8,
            "fontSize": 16
         },
         "inputTypes": {
            "text": {
               "validation": {
                  "regex": "^[a-zA-ZÀ-ỹ\\s]{2,50}$",
                  "error_message": "Tên không hợp lệ",
                  "min_length": 2,
                  "max_length": 50
               }
            }
         },
         "variants": {
            "withLabel": {
               "style": {
                  "labelTextSize": 14,
                  "labelColor": "#333333"
               }
            }
         },
         "states": {
            "focus": {
               "style": {
                  "borderColor": "#2196f3"
               }
            },
            "error": {
               "style": {
                  "borderColor": "#f44336"
               }
            }
         }
      }
   ]
}
```

### Test Case 2: Advanced Form với nhiều variants

```json
{
   "title": "Advanced Form Test",
   "components": [
      {
         "id": "advanced_input",
         "type": "textfield",
         "config": {
            "label": "Advanced Input",
            "placeholder": "Test advanced features",
            "isRequired": true,
            "icon": "person"
         },
         "style": {
            "padding": "16px 20px",
            "borderColor": "#ddd",
            "borderRadius": 12,
            "fontSize": 18,
            "backgroundColor": "#f9f9f9"
         },
         "inputTypes": {
            "text": {
               "validation": {
                  "regex": "^[a-zA-Z0-9\\s]{3,30}$",
                  "error_message": "Chỉ được nhập chữ, số và khoảng trắng (3-30 ký tự)",
                  "min_length": 3,
                  "max_length": 30
               }
            }
         },
         "variants": {
            "withLabel": {
               "style": {
                  "labelTextSize": 16,
                  "labelColor": "#2196f3",
                  "fontWeight": "bold"
               }
            },
            "withIcon": {
               "style": {
                  "iconPosition": "left",
                  "iconSize": 20,
                  "padding": "16px 20px 16px 50px"
               }
            }
         },
         "states": {
            "default": {
               "style": {
                  "borderColor": "#ddd",
                  "backgroundColor": "#f9f9f9"
               }
            },
            "focus": {
               "style": {
                  "borderColor": "#2196f3",
                  "backgroundColor": "#ffffff",
                  "shadow": "0 0 0 3px rgba(33, 150, 243, 0.1)"
               }
            },
            "error": {
               "style": {
                  "borderColor": "#f44336",
                  "backgroundColor": "#ffebee"
               }
            },
            "disabled": {
               "style": {
                  "borderColor": "#ccc",
                  "backgroundColor": "#f5f5f5",
                  "color": "#999"
               }
            }
         }
      }
   ]
}
```

## Troubleshooting

### 1. UI không cập nhật sau khi thay đổi Remote Config

-  Đảm bảo đã **Publish changes** trong Firebase Console
-  Click nút **Refresh** trong app
-  Kiểm tra cache interval trong `RemoteConfigService`

### 2. Validation không hoạt động

-  Kiểm tra regex pattern có hợp lệ không
-  Đảm bảo `inputTypes` được định nghĩa đúng
-  Kiểm tra console log để xem lỗi regex

### 3. Styles không áp dụng

-  Kiểm tra tên property trong style có đúng không
-  Đảm bảo `StyleUtils` hỗ trợ property đó
-  Kiểm tra thứ tự ưu tiên: base style → variant → state

### 4. Variants không hoạt động

-  Đảm bảo điều kiện để áp dụng variant (ví dụ: có label cho withLabel)
-  Kiểm tra tên variant có đúng không
-  Đảm bảo variant style được định nghĩa đúng format

## Tips

1. **Test từng component một**: Thay vì test toàn bộ form, test từng component riêng biệt
2. **Sử dụng console log**: Thêm print statements để debug
3. **Test edge cases**: Thử với giá trị null, empty, special characters
4. **Test responsive**: Thay đổi kích thước màn hình để test responsive design
5. **Test accessibility**: Đảm bảo app có thể sử dụng với screen readers
