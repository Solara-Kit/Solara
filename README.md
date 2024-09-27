# Solara

<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/solara/lib/core/dashboard/solara.png?raw=true" alt="Solara Logo" width="300"/>
</p> <br>

---

[![Gem Version](https://badge.fury.io/rb/solara.svg)](https://badge.fury.io/rb/solara)
![Version](https://img.shields.io/badge/ruby-3.0.0-blue)

## Quick Ascess

- **[Solara Website](https://Solara-Kit.github.io/)**
- **[Online Dashboard](https://github.com/Solara-Kit/Solara/wiki/Online-Dashboard)**
- **[Infinite Project](https://github.com/Solara-Kit/Infinite)**
- **[Getting Started](https://github.com/Solara-Kit/Solara/wiki)**
- **[Brand Management](https://github.com/Solara-Kit/Solara/wiki/Brand-Management)**
- **[Brand Overview](https://github.com/Solara-Kit/Solara/wiki/Brands-Overview)**
- **[Code Signing](https://github.com/Solara-Kit/Solara/wiki/Code-Signing)**
- **[Advanced Topics](https://github.com/Solara-Kit/Solara/wiki/Advanced-Topics)**

## Table of Contents

1. **[What is Solara?](#what-is-solara)**
2. **[Why Solara?](#why-solara)**
3. **[How to Manage Brands With Solara?](#how-to-manage-brands-with-solara)**
4. **[How to Integrate Solara?](#how-to-integrate-solara)**
5. **[What is The Brand?](#what-is-the-brand)**
6. **[How Does Solara Work with Brands?](#how-does-solara-work-with-brands)**
7. **[The Flow of Brand Switching Operation](#the-flow-of-brand-switching-operation)**
8. **[Brand Artifacts](#brand-artifacts)**
9. **[Brand Configurations](#brand-configurations)**
10. **[Codebase Development](#codebase-development)**
11. **[Getting Started](#getting-started)**
12. **[Solara Development](#solara-development)**
13. **[Contributing](#contributing)**
14. **[License](#license)**
15. **[Code of Conduct](#code-of-conduct)**

---

# Promotional Video

Check out our promotional video!

[![Watch the video](https://img.youtube.com/vi/X8kAIFBa-sU/hqdefault.jpg)](https://www.youtube.com/watch?v=X8kAIFBa-sU)

## What is Solara?

**Solara** is a comprehensive Ruby library designed to streamline the setup and management of white label applications
across various platforms, including iOS, Android, Flutter, and Web (Web COMING SOON).

With **Solara**, you can effortlessly manage the dynamic components of your white label apps using a user-friendly
Command Line Interface (CLI) and a powerful dashboard that simplifies the administration of multiple brands,
enabling efficient control over app configurations.

The library allows for quick adjustments to resources and configurations, ensuring that
your applications remain consistent and aligned with brand guidelines.

Whether you are launching a new product or maintaining existing apps, **Solara** empowers you to handle
everything from a single location.

> White label apps are ready-made apps that businesses can personalize with their own branding. They help companies
> quickly launch their services without needing to build an app from scratch. This approach saves time and money while
> allowing businesses to focus on their brand and customers.

### Solara diagram

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/solara-diagram.png?raw=true" alt="Solara Diagram" width="1000"/>
</p>
<br>

As illustrated in the previous diagram, Solara utilizes a single codebase that allows you to create an infinite number of apps
simply by adding a new brand for each one. In the context of Solara, a brand consists of a set of **Configurations** and **Resources**
tailored for a specific app, as detailed in [What is The Brand?](#what-is-the-brand) below. Solara streamlines the management of these brands,
automatically preparing the codebase to support them without requiring any manual intervention.

## The Motivation to Use Solara

Imagine you've developed (or planning to develop) an e-commerce app and need to sell it to countless customers. To achieve this, your **e-commerce** codebase must be dynamic enough to accommodate essential changes, such as the app name, identifier, icon, theme, version, base URL, and custom configurations—like whether to enable or disable specific features—and more. This is
illustrated in the diagram below:

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/e-commerce-diagram.png?raw=true" alt="Diagram" width="1000"/>
</p>
<br>

<!--
```
      +----------------------------------------------------------------+
      |                       E-commerce Codebase                      |
      +----------------------------------------------------------------+
               |                      |                       |
               v                      v                       v
      +-----------------+     +-----------------+     +----------------+
      |      App 1      |     |      App 2      |     |      App...    |
      +-----------------+     +-----------------+     +----------------+
               |                       |                      |
               v                       v                      v
      +-----------------+     +-----------------+     +----------------+
      |  Customer 1     |     |  Customer 2     |     |  Customer...   |
      +-----------------+     +-----------------+     +----------------+
```
-->

Solara addresses this challenge by introducing a centralized brand management system, enabling you to generate an infinite number of apps efficiently, as illustrated below:

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/solara-e-commerce-diagram.png?raw=true" alt="Diagram" width="1000"/>
</p>
<br>

<!--
```
      +----------------------------------------------------------------+
      |                             Solara                             |
      +----------------------------------------------------------------+
               |                       |                      |
               v                       v                      v
      +-----------------+     +-----------------+     +----------------+
      |     Brand 1     |     |      Brand 2    |     |     Brand...   |
      +-----------------+     +-----------------+     +----------------+
               |                       |                      |
               v                       v                      v
      +----------------------------------------------------------------+
      |                       E-commerce Codebase                      |
      +----------------------------------------------------------------+
               |                       |                      |
               v                       v                      v
      +-----------------+     +-----------------+     +----------------+
      |      App 1      |     |      App 2      |     |      App...    |
      +-----------------+     +-----------------+     +----------------+
```
-->

This centralized approach not only simplifies brand management but also enhances the flexibility of your codebase, allowing you to serve a diverse customer base with ease.

The same applies if you need to publish countless apps to your personal store account, simply by changing the content and theme of each app.

---

## Why Solara?

Here are some advantages of using **Solara**:

### Cross-Platform Compatibility

Solara supports iOS, Android, and Flutter, allowing for cohesive management across different platforms.

### Centralized Configurations

Solara offers a single point of control for managing all dynamic components of white label apps, making updates and
consistency easier to achieve.

### User-Friendly Dashboard

The intuitive dashboard allows for quick navigation and management of multiple brands, streamlining the administrative
process.

### Powerful CLI Support

With robust command-line interface commands, developers can efficiently configure and control app settings without
needing to navigate through the interfaces. Solara’s robust command-line interface integrates seamlessly with dev ops
tools like Fastlane, GitHub Actions, and other tools, allowing for automated deployment, continuous integration, and
streamlined workflows. This enhances efficiency and reduces manual effort in managing white label apps.

### Seamless Brand Switching

Switching between brands is a piece of cake with Solara’s CLI or centralized dashboard. This functionality allows
developers to change configurations without altering the Git repository, facilitating smooth team collaboration and
development.

### Easy Onboarding and Offboarding

Adding or removing brands is straightforward with Solara’s CLI or centralized dashboard. This feature simplifies the
process of editing configurations, ensuring that teams can quickly adapt to changes without any hassle.

### Solara Doctor

This powerful feature automatically detects issues in application or brand configurations, running health checks every
time you use Solara. Users can also manually trigger it through the CLI or dashboard, ensuring that your brands remain
in optimal condition and reducing potential problems before they arise.

### Effortless Brand Management

Easily switch and manage multiple brands, ensuring that each app remains aligned with its specific branding
requirements.

### Streamlined Development Workflow

By automating and simplifying configuration tasks, Solara enhances developer productivity and reduces the potential for
errors.

### Scalability

As your app portfolio grows, Solara can easily adapt to manage additional brands and dynamic components without a hitch.

### Consistent User Experience

Ensure that all apps maintain a uniform look and feel, enhancing user experience across different platforms.

---

## How to Manage Brands With Solara?

Solara offers powerful tools for managing your brands.
The Solara Management Tools Diagram below illustrates these tools:

#### Solara Management Tools Diagram
<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/solara-management-tools-diagram.png?raw=true" alt="Diagram" width="1000"/>
</p>
<br>

<!--
```
      +-----------------------------------------------------------------------+
      |                          Solara Management Tools                      |
      +-----------------------------------------------------------------------+
                  |                           |                      |
                  v                           v                      v
      +------------------------+     +-----------------+     +----------------+
      | Command Line Interface |     |      Local      |     |     Online     |
      |    (CLI or Terminal    |     |    Dashboard    |     |    Dashboard   |
      +------------------------+     +-----------------+     +----------------+
                   |                          |                     |
                   v                          v                     v
      +------------------------+     +-----------------+     +----------------+
      |     solara init        |     |  Browse brands  |     |  Import brand  |
      |     solara onboard     |     |  Switch brand   |     |  Edit   brand  |
      |     solara switch      |     |  Clone  brand   |     |  New    brand  |
      |     solara doctor      |     |  Edit   brand   |     |  Export brand  |
      |          ...           |     |       ...       |     |      ...       |
      +------------------------+     +-----------------+     +----------------+

```
-->

> For the detailed guidance, please refer to [Brand Management](https://github.com/Solara-Kit/Solara/wiki/Brand-Management).

# How to Integrate Solara?

To integrate Solara into your project, you must first initialize it at the root directory.
Open your terminal, ensure your current directory is set to the root of your project, and then run the following
command:

```bash
solara init
```

> Check the full documentation in [Getting Started](https://github.com/Solara-Kit/Solara/wiki).

Once initialization is complete, two directories will be created in the root of your project: `solara` and `.solara`.
Refer to the image below for a visual guide:

#### Solara Initialized in Flutter Project

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/flutter-solara-initialized.png?raw=true" alt="Solara initialized in Flutter" width="300"/>
</p>
<br>

> Check [Infinite Project](https://github.com/Solara-Kit/Infinite) for the full details.

## Solara Directory

The `solara` directory contains all the essential files required for Solara. Below is its structure:

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/solara-dir-structure-diagram.png?raw=true" alt="Diagram" width="500"/>
</p>
<br>

> For comprehensive details, check
> the [Brand Overview](https://github.com/Solara-Kit/Solara/wiki/Brands-Overview).

The most critical directory is `solara/brand/brands/`, which we will explore in more detail below:

## The Brands Directory

The `solara/brand/brands/` directory houses all brand-specific content.

This raises an important question: **What is a brand in the context of Solara?** Below are the details:

## What is The Brand?

The brand in the context of Solara is a set of configurations and resources for a specific app. The brand includes:

1. Configurations: JSON files, or other formats, describing the requirement of the final app.
2. Resources: Include images, icons, layouts, and other assets.

See the diagram below

#### Brand Structure Diagram

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/solara-brand-diagram.png?raw=true" alt="Diagram" width="1000"/>
</p>
<br>

<!--
```
      +----------------------------------------------------------------------+
      |                                Brand                                 |
      +----------------------------------------------------------------------+
                  |                                            |
                  v                                            v
       +---------------------+                      +---------------------+
       |    Configurations   |                      |      Resources      |
       +---------------------+                      +---------------------+
                  |                                            |
                  v                                            v
 +---------------------------------+        +-------------------------------------+
 | theme.json, brand_config.json,..|        | app icon, images, layouts, assets,..|
 +---------------------------------+        +-------------------------------------+

```
-->

---

## How Does Solara Work with Brands?

In the previous [Solara Diagram](#solara-diagram), we explored how Solara transforms a single codebase into multiple
apps, each tailored to specific brand configurations.

This transformation process is referred to as **Brand Switching** in the context of Solara. Below is a diagram
illustrating this process:

#### Brand Switching Diagram

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/solara-switch-diagram.png?raw=true" alt="Diagram" width="1000"/>
</p>
<br>

<!--
```
                    +-----------------------+
                    |     Solara Library    |
                    +-----------------------+
                                |
                                v
      +---------------------------------------------------+
      |                   Switch Brand                    |
      +---------------------------------------------------+
             |                  |                 |
             v                  v                 v
      +-------------+    +-------------+    +-------------+
      |    App 1    |    |    App 2    |    |    App...   |
      +-------------+    +-------------+    +-------------+
```
-->

## The Flow of Brand Switching Operation

The brand switching process runs in a sequential flow illustrated
by the diagram below:

#### Brand Switching Flow Diagram

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/switch-flow-diagram.png?raw=true" alt="Diagram" width="300"/>
</p>
<br>

<!--
```
+-----------------------+
|  Codebase Preparation |
+-----------------------+
            |
            v
+-----------------------+
|    Code Generation    |
+-----------------------+
            |
            v
+-----------------------+
|  Resource Deployment  |
+-----------------------+
```
-->

This diagram illustrates the sequential flow from preparing the codebase to generating code and finally deploying
resources. Each phase builds upon the previous one, leading to a smooth transition for managing brand configurations.

And here is the details:

1. **Codebase Preparation**
    - **Description**: This phase transforms the existing codebase into a dynamic structure capable of accommodating
      various brand configurations. It ensures that the application can seamlessly adapt to different brand
      requirements. For example, the codebase will enable the dynamic display of the app launcher (or app icon) based on
      each brand's specific configurations. This foundational work allows the application to respond flexibly to brand
      identity changes, enhancing user experience and consistency across different brand environments.

2. **Code Generation**
    - **Description**: Generate essential configuration files tailored for each brand. This includes, for instance,
      converting `brand_config.json` into platform-specific files such as `BrandConfig.swift` for iOS, `BrandConfig.kt`
      for Android, and `brand_config.dart` for Flutter. These files serve as the foundation for brand-specific
      customization.

   > Explained in detail in [Brand Configuration](#brand-configurations)

3. **Resource Deployment**
    - **Description**: Transfer brand-specific resources, including images, icons, layouts, and other assets, to their
      designated locations within each platform. For example:
        - Android: Copy `res` to `src/main/res/solara_artifacts`
        - iOS: Copy `assets` to `Assets.xcassets/SolaraArtifacts`
        - Flutter: Copy `assets` to the `./assets/solara_artifacts` folder

This is explained in detail in the next section **Brand Artifacts**

---

### Brand Artifacts

Solara deploys resources and generated code into specific directories within the codebase, referred to as **Solara Artifacts**. The following diagram illustrates the deployment of artifacts across each platform:

### Solara Artifacts Diagram

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/solara-artifacts-diagram.png?raw=true" alt="Solara Artifacts Diagram" width="1000"/>
</p>
<br>

<!--
```
      +--------------------------------------------------------------------------------------------------------------+
      |                                       Solara Artifacts                                                       |
      +--------------------------------------------------------------------------------------------------------------+
                         |                                         |                                |
                         v                                         v                                v
               +--------------------+                   +--------------------+           +---------------------+
               |       Android      |                   |         iOS        |           |      Flutter        |
               +--------------------+                   +--------------------+           +---------------------+
                         |                                         |                                |
                         v                                         v                                v
      +---------------------------------------+   +--------------------------------+   +---------------------------+
      | ./solara_artifacts                    |   | SolaraArtifacts                |   | ./lib/solara_artifacts    |
      | ./app/src/main/solara_artifacts       |   | Assets.xcassets/SolaraArtifacts|   | ./assets/solara_artifacts |
      | ./app/src/main/java/solara_artifacts  |   |                                |   | ./assets/solara_fonts     |
      | ./app/src/main/assets/solara_artifacts|   |                                |   |                           |
      +---------------------------------------+   +--------------------------------+   +---------------------------+
```
-->

1. **Android**
   - **Paths**:
     - `./solara_artifacts`: Contains the generated `brand.properties` file.
     - `./app/src/main/solara_artifacts`:
       - This path is where the brand's `res` directory is deployed.
       - It is included as a `sourceSet` in the `app/build.gradle` to generate resources for Android.
     - `./app/src/main/java/solara_artifacts`:
       - This directory holds the `BrandConfig.kt` and `BrandTheme.kt` files.
     - `./app/src/main/assets/solara_artifacts`:
       - Contains assets that are directly utilized in the Android application.

2. **iOS**
   - **Paths**:
     - `SolaraArtifacts`:
       - This directory includes `BrandConfig.kt`, `BrandTheme.kt`, `Brand.xcconfig`, and the `Fonts` folder.
     - `Assets.xcassets/SolaraArtifacts`:
       - A dedicated location for assets deployed by Solara.

3. **Flutter**
   - **Paths**:
     - `./lib/solara_artifacts`:
       - Contains the `brand_config.dart` and `brand_theme.dart` files.
     - `./assets/solara_artifacts`:
       - A directory for various assets used in the Flutter application.
     - `./assets/solara_fonts`:
       - Specifically designated for font assets utilized in Flutter.

---

### Brand Configurations

Solara allows for flexible and customizable configurations for each brand, enabling tailored settings based on specific
needs. These configurations are stored in the `BRAND_KEY/shared/brand_config.json` file, serving as the central hub for
brand-specific settings.

#### Brand Configurations Generation Diagram

The diagram below illustrates how the `brand_config.json` is generated for each platform, ensuring that all necessary
configurations are appropriately formatted and accessible.

<br>
<p align="center">
  <img src="https://github.com/Solara-Kit/Solara/blob/main/etc/screenshots/diagram/brand-config-diagram.png?raw=true" alt="Diagram" width="1000"/>
</p>
<br>

<!--
```
      +-----------------------------------------------------------------------+
      |                   BRAND_KEY/shared/brand_config.json                  |
      +-----------------------------------------------------------------------+
                 |                        |                       |
                 v                        v                       v
      +--------------------+   +--------------------+   +---------------------+
      |       Fluttter     |   |       Android      |   |        iOS          |
      +--------------------+   +--------------------+   +---------------------+
                 |                        |                       |
                 v                        v                       v
      +--------------------+   +--------------------+   +---------------------+
      | brand_config.dart  |   |   BrandConfig.kt   |   | BrandConfig.swift   |
      +--------------------+   +--------------------+   +---------------------+
```
-->

1. **Central Configuration File**
    - **`BRAND_KEY/shared/brand_config.json`**: This is the main configuration file that includes all customizable
      settings for your brand. It acts as a template for generating platform-specific configuration files.

2. **Platform-Specific Configurations**:
    - **Flutter**:
        - **`brand_config.dart`**: This Dart file contains `BrandConfig` class which is generated from the central
          configuration for use in Flutter applications. It allows developers to access brand settings directly within
          the Flutter framework.

    - **Android**:
        - **`BrandConfig.kt`**: For Android applications, this Kotlin file is generated from the central configuration
          file, making them available for seamless integration into Android app development.

    - **iOS**:
        - **`BrandConfig.swift`**: This Swift file is generated for iOS applications, providing access to the brand
          configurations for iOS developers.

The generation of these platform-specific files from the central `brand_config.json` ensures that your brand
configurations are consistently applied and easily manageable across different environments, enhancing the development
process and user experience.

---

# Codebase Development

In Solara, brand management is handled by Solara itself, while the responsibility for codebase development lies with the developer. As a developer, your role is to implement the codebase according to the specified requirements, using the **Solara** artifacts generated during the **switch** operation.

For comprehensive details, please refer to the following links in [Infinite Project](https://github.com/Solara-Kit/Infinite):

- **[Flutter Development](https://github.com/Solara-Kit/Infinite/wiki/Flutter-Development)**: Comprehensive guidelines for integrating Solara into your Flutter project.
- **[iOS Development](https://github.com/Solara-Kit/Infinite/wiki/iOS-Development)**: Step-by-step instructions for incorporating Solara into your iOS project.
- **[Android Development](https://github.com/Solara-Kit/Infinite/wiki/Android-Development)**: Detailed instructions for adding Solara to your Android project.

---

## Getting Started

Please visit the [Wiki](https://github.com/Solara-Kit/Solara/wiki/), for a comprehensive guide on installation and
getting started.

---

## Solara Development

To contribute to Solara development, please refer to the [Solara Development Documentation](https://github.com/Solara-Kit/Solara/wiki/Solara-Development).

---

## Contributing

Bug reports and pull requests are welcome on GitHub at [Solara](https://github.com/Solara-Kit/Solara). This project is
intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/Solara-Kit/Solara/blob/main/etc/md/CODE_OF_CONDUCT.md).

---

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

---

## Code of Conduct

Everyone interacting in the Solara project's codebases, issue trackers, chat rooms, and mailing lists is expected to
follow the [code of conduct](https://github.com/Solara-Kit/Solara/blob/main/etc/md/CODE_OF_CONDUCT.md).

---

Explore the [Wiki](https://github.com/Solara-Kit/Solara/wiki) for more information on effectively using Solara! If you have any questions or need further assistance,
feel free to reach out.