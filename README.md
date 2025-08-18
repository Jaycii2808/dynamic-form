This Flutter application creates dynamic forms with easy customization and sharing capabilities.
### Images
<img width="1412" height="650" alt="image" src="https://github.com/user-attachments/assets/b5219374-8fe1-4b1a-bea2-5bdd63e09f37" />
<img width="1495" height="669" alt="image" src="https://github.com/user-attachments/assets/011e89ca-7072-40a4-b7cf-9b3ac2447442" />

### Completed Features
* Create new forms from scratch
* Import JSON from clipboard or file
* User's form list
* Available form templates
* Delete forms with confirmation
* Add, remove, and rearrange components in form builder
* Preview form
* Configure properties of each component
* Basic validation for inputs
* Support Short Answer (text input) and Dropdown components with drag & drop
* Export complete JSON
* Import JSON with validation
* Share forms via link (web version)
* Public access for forms
* Form submission interface
* Validation upon submission
* Store responses in Firestore
* Send results via email from API

---

### Required Files

Ask admin to provide these files, then place them in the correct locations:

```
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
```

---

### Build for Web

```bash
flutter build web --release
```

---

### Deploy to Firebase Hosting

```bash
firebase deploy --only hosting:dynamicformbiwo
```

