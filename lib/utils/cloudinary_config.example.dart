/// ============================================================
/// CLOUDINARY CONFIG TEMPLATE (user app)
/// ============================================================
/// 1. Copy this file to cloudinary_config.dart (same folder).
/// 2. Sign up at https://cloudinary.com (no card needed).
/// 3. Dashboard → copy your "Cloud name".
/// 4. Settings → Upload → add an UNSIGNED upload preset, copy its name.
/// 5. Paste both below.
///
/// cloudinary_config.dart is gitignored — only this template is committed.
/// ============================================================
library;

/// Your Cloudinary cloud name (from the dashboard).
const String kCloudinaryCloudName = 'YOUR_CLOUD_NAME';

/// Your UNSIGNED upload preset name.
const String kCloudinaryUploadPreset = 'YOUR_UNSIGNED_PRESET';

/// Auto endpoint — accepts both images AND videos.
String get kCloudinaryUploadUrl =>
    'https://api.cloudinary.com/v1_1/$kCloudinaryCloudName/auto/upload';

bool get isCloudinaryConfigured =>
    kCloudinaryCloudName != 'YOUR_CLOUD_NAME' &&
    kCloudinaryUploadPreset != 'YOUR_UNSIGNED_PRESET';
