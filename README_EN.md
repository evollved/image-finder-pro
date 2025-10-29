# Image Finder Pro for OpenCart 3

![OpenCart 3](https://img.shields.io/badge/OpenCart-3.x-blue.svg)
![Version](https://img.shields.io/badge/Version-1.1-green.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Advanced module for finding and managing unused images in OpenCart 3 administration panel. Helps clean up your image catalog by identifying files not linked to products, categories, manufacturers, or banners.

## 🚀 Features

### 🔍 Smart Image Detection
- **Comprehensive Database Scan** - Checks products, categories, manufacturers, and banners
- **Recursive Directory Search** - Optional deep scan of subdirectories
- **Configurable Limits** - Set maximum files to process
- **Multiple Image Formats** - Supports JPG, PNG, GIF, WebP

### 👁️ Advanced Preview System
- **Modal Image Preview** - View images in full-size modal window
- **File Information** - Display file size and dimensions
- **Quick Preview Toggle** - Enable/disable preview functionality

### 🛠️ Bulk Management
- **Multiple Selection** - Checkbox-based file selection
- **Select All/None** - Quick selection controls
- **Bulk Delete Operations** - Delete multiple files at once
- **Individual File Management** - Single file preview and deletion

### 🔒 Security & Safety
- **Permission Checking** - Strict user authentication
- **Safe Deletion** - Confirmation dialogs for all delete operations
- **Directory Restrictions** - Only operates within `/image/catalog/`
- **Cache Cleaning** - Automatically removes cached image versions

## 📦 Installation

### Method 1: OCMod Installer (Recommended)
1. Download the `image_finder_pro_v1.1.ocmod.zip` file
2. Go to **Extensions → Installer** in your OpenCart admin
3. Upload the ZIP file
4. Wait for successful installation message

### Method 2: Manual Installation
1. Extract the ZIP file contents
2. Upload all files from the `upload` folder to your OpenCart root directory
3. Go to **Extensions → Extensions → Modules**
4. Find "Image Finder Pro" and click Install

## ⚙️ Configuration

After installation, configure the module settings:

1. Go to **Extensions → Extensions → Modules**
2. Find **Image Finder Pro** and click Edit
3. Adjust settings:
   - **Recursive Search**: Enable to search subdirectories
   - **Image Preview**: Enable/disable image preview functionality  
   - **Max Files**: Limit number of files to process (100-10000)

## 🎯 Usage

### Finding Unused Images
1. Navigate to the module through the Extensions menu or find it in **Extensions → Image Finder Pro**
2. Configure your search preferences
3. Click **"Find Unused Images"**
4. Wait for the scan to complete

### Managing Results
- **Preview Images**: Click the "Preview" button for any image
- **Select Files**: Use checkboxes to select individual files
- **Bulk Selection**: Use "Select All" / "Unselect All" buttons
- **View File Info**: See file size and dimensions for each image

### Deleting Images
1. Select one or multiple images using checkboxes
2. Click **"Delete Selected (X)"** where X is the number of selected files
3. Confirm the deletion in the dialog
4. Review results and any errors

## 🗂️ Database Tables Scanned

The module checks images in the following database tables:
- `oc_product` (main product images)
- `oc_product_image` (additional product images) 
- `oc_category` (category images)
- `oc_manufacturer` (manufacturer logos)
- `oc_banner_image` (banner images)

## 🔧 Technical Details

### Requirements
- OpenCart 3.0.x or higher
- PHP 7.4 or higher
- MySQL 5.7 or higher
- GD Library enabled

### File Structure
upload/

├── admin/

│ ├── controller/extension/module/image_finder_pro.php

│ ├── language/en-gb/extension/module/image_finder_pro.php

│ ├── view/template/extension/module/image_finder_pro.twig

│ ├── view/stylesheet/image_finder_pro.css

│ └── view/javascript/image_finder_pro.js

└── install.xml
### API Endpoints
- `findUnusedImages` - Scan for unused images
- `deleteImages` - Delete selected images  
- `save` - Save module settings

## ⚠️ Important Notes

### Backup Recommendation
**Always backup your files and database before deleting any images.** While the module includes safety checks, accidental deletion is possible.

### Performance Considerations
- Large catalogs (10,000+ images) may take several minutes to scan
- Enable recursive search only when necessary
- Adjust max files limit based on your server capabilities

### Security
- Module requires administrator permissions
- Only users with modify permissions can delete files
- Files are validated before deletion

## 🐛 Troubleshooting

### Common Issues

**"No unused images found" but I know there are some**
- Check if recursive search is enabled
- Verify the images are in `/image/catalog/` directory
- Ensure file extensions are supported (jpg, png, gif, webp)

**"Error deleting file" messages**
- Check file permissions in the image directory
- Verify files aren't locked by other processes
- Ensure files exist at the specified paths

**Module not appearing in admin**
- Clear OpenCart modification cache
- Check if OCMod modifications are enabled
- Verify XML installation was successful

### Support
For bugs and feature requests, please create an issue in the GitHub repository.

## 📄 License

This module is released under the MIT License. See LICENSE file for details.

## 🔄 Version History

- **v1.1** (Current) - Added image preview, multiple selection, bulk operations
- **v1.0** - Initial release with basic image finding functionality

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

**Disclaimer**: Use this module at your own risk. Always backup your site before making changes. The authors are not responsible for any data loss.
