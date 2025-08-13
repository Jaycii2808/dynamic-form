This Flutter application creates dynamic forms with easy customization and sharing capabilities.
## Completed Features

1. Home Management
✅ Create new forms from scratch
✅ Import JSON from clipboard or file
✅ User's form list
✅ Available form templates
✅ Delete forms with confirmation
2. Form Builder
✅ Add/remove/rearrange components
✅ Comprehensive validation
✅ Preview of the form
✅ Configure properties of each component
3. Supported Component Types with drag and drop
✅ Short Answer - Input short text
✅ Dropdown - Select from a list
4. Export/Import System
✅ Export complete JSON
✅ Import JSON with validation
✅ Share form via link to the screen (web version)
✅ Public access for forms
5. Form Submission
✅ Beautiful form filling interface
✅ Validation upon submission
✅ Send results via email from API
✅ Store responses in Firestore

## Required Files

Ask admin to provide these files, then paste them into the correct locations:

project_root/
│
├── android/
│   └── app/
│       └── google-services.json       <-- Provided by admin
│
├── lib/
│   ├── dotenv                         <-- Provided by admin
│   ├── firebase_options.dart           <-- Provided by admin
│
├── firebase.json                       <-- Provided by admin

---

## Build for Web

flutter build web --release

---

## Deploy to Firebase Hosting

firebase deploy --only hosting:dynamicformbiwo
