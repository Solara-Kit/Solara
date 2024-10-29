# Changelog

## Version 0.7.4

- CodeGenerator bug fix: the list items are referencing the same data

## Version 0.7.3

Refactor Code Generator: Address Issues and Limitations of Previous Implementation
    - Redesigned the code generator to enhance reliability and performance.
    - Resolved multiple issues associated with the old approach.

## Version 0.7.2

- Bug fix: user-defined JSON files not displaying in dashboard

## Version 0.7.1

- Bug fixes

## Version 0.7.0

- Display user-defined JSON files in dashboard
- Add mechanism to sync existing brand with template changes

## Version 0.6.0

- Hybrid JSON processing with optional manifest configuration. Implement flexible JSON file handling that:
  - Automatically processes all JSON files in directory
  - Allows customization via manifest configuration (class names, types)
  - Removes need to manually add new files to manifest
  - Provides override capability when specific configuration needed
- Add JSON manifest for generating platform-specific code from JSON files
  - This commit introduces a JSON manifest that enables the generation of platform-specific code based on the provided
    JSON files. This
    enhancement streamlines the development process and ensures better code organization for different platforms.
- Disable mandatory resource checks in ResourceManifestProcessor during brand onboarding
- Implement rollback mechanism if an error occurs during the onboarding process.
- Optimize .gitignore: Use root-relative paths to avoid unintended ignores
- Display checkbox for boolean value
- Only switch the brand on changing the values in dashboard if it's the current brand.
- Dashboard UI improvements

## Version 0.4.0 & 0.5.0

Enhance Dashboard: Implement Comprehensive Support for JSON Objects

- Added functionality to fully process and display JSON objects within the dashboard.
- Updated data handling methods to accommodate nested structures and arrays.
- Improved UI components to render JSON data dynamically.
- Bug fixes and improvements

## Version 0.1.0 & 0.2.0 & 0.3.0

### Enhancements

- **Brand Configuration Code Generation**
  - Added support for **JSON format** and **serialization** to streamline configuration management.
  - Introduced a static JSON string, `asJson`, in each class for **dynamic parsing** of configuration properties,
    enhancing accessibility and ease of use.

These updates significantly improve the flexibility and usability of the brand configuration system.