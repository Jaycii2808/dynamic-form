// import 'package:flutter/material.dart';
// import 'package:dynamic_form_bi/data/models/form_submission/form_submission_model.dart';
// import 'package:dynamic_form_bi/core/utils/form_submission_converter.dart';
// import 'package:dynamic_form_bi/data/models/components/component_values_model.dart';
// import 'package:dynamic_form_bi/data/models/dynamic_form_multi/dynamic_form_multi_model.dart';
// import 'package:dynamic_form_bi/data/models/config/config_model.dart';
// import 'package:dynamic_form_bi/data/models/style/style_model.dart';
// import 'package:dynamic_form_bi/core/enums/form_type_enum.dart';
//
// /// Demo class to test FormSubmissionModel functionality
// class FormSubmissionDemo {
//   /// Create a sample form submission to test
//   static void testFormSubmission() {
//     debugPrint('🧪 Testing FormSubmissionModel...');
//
//     // Create sample form data (simulating what we had before)
//     final componentValues = const ComponentValuesModel(
//       values: {
//         'FormTypeEnum.textFieldFormType_1754275031139': 'John Doe',
//         'FormTypeEnum.textFieldFormType_1754275049161': 'john@example.com',
//         'switch_component_123': true,
//         'next_page_btn_1754275314501': null,
//         'previous_page_btn_1754275314502': null,
//         'submit_btn_1754275314502': null,
//       },
//     );
//
//     // Create sample form model
//     final formModel = const DynamicMultiPageFormModel(
//       formId: 'demo_form_001',
//       name: 'Customer Registration Form',
//       navigationType: 'sequential',
//       pages: [
//         FormForMultiPageModel(
//           pageId: 'page_1',
//           title: 'Personal Information',
//           order: 1,
//           components: [
//             FormComponentMultiPageModel(
//               id: 'FormTypeEnum.textFieldFormType_1754275031139',
//               type: FormTypeEnum.textFieldFormType,
//               order: 1,
//               config: ConfigModel(label: 'Full Name', isRequired: true),
//               style: StyleModel(),
//             ),
//             FormComponentMultiPageModel(
//               id: 'FormTypeEnum.textFieldFormType_1754275049161',
//               type: FormTypeEnum.textFieldFormType,
//               order: 2,
//               config: ConfigModel(
//                 label: 'Email Address',
//                 isRequired: true,
//               ),
//               style: StyleModel(),
//             ),
//             FormComponentMultiPageModel(
//               id: 'switch_component_123',
//               type: FormTypeEnum.switchFormType,
//               order: 3,
//               config: ConfigModel(label: 'Subscribe to Newsletter'),
//               style: StyleModel(),
//             ),
//           ],
//         ),
//       ],
//     );
//
//     // Convert to readable submission model
//     final submissionModel = FormSubmissionConverter.convertToSubmissionModel(
//       componentValues: componentValues,
//       formModel: formModel,
//     );
//
//     // Test debug output
//     FormSubmissionConverter.debugPrintSubmission(submissionModel);
//
//     // Test email format
//     debugPrint('\n📧 EMAIL FORMAT (Ready to send):');
//     debugPrint(submissionModel.toEmailFormat());
//
//     // Test simple map
//     debugPrint('\n📊 SIMPLE MAP FORMAT:');
//     debugPrint(submissionModel.toSimpleMap().toString());
//
//     // Test JSON serialization
//     debugPrint('\n🔄 JSON FORMAT:');
//     debugPrint(submissionModel.toJson().toString());
//
//     debugPrint('\n✅ FormSubmissionModel test completed!');
//   }
//
//   /// Create example FormSubmissionModel manually
//   static FormSubmissionModel createExampleSubmission() {
//     return FormSubmissionModel(
//       formId: 'demo_form_001',
//       formName: 'Customer Registration Form',
//       submissionTime: DateTime.now(),
//       fields: const [
//         FormFieldData(
//           label: 'Full Name',
//           value: 'John Doe',
//           componentType: 'textField',
//           isRequired: true,
//         ),
//         FormFieldData(
//           label: 'Email Address',
//           value: 'john@example.com',
//           componentType: 'textField',
//           isRequired: true,
//         ),
//         FormFieldData(
//           label: 'Subscribe to Newsletter',
//           value: true,
//           componentType: 'switch',
//           isRequired: false,
//         ),
//       ],
//     );
//   }
//
//   /// Demo email format output
//   static String getEmailFormatExample() {
//     final submission = createExampleSubmission();
//     return submission.toEmailFormat();
//   }
// }
