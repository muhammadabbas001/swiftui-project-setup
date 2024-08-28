# iOS App Project Setup with SwiftUI, Swinject, Combine, and URLSession

This repository contains a boilerplate setup for an iOS application built with SwiftUI, leveraging Swinject for dependency injection, Combine for reactive programming, and URLSession for network requests. The template provides a solid foundation for building scalable and maintainable iOS apps.

## Features

- **SwiftUI**: Modern UI framework for declarative UI development.
- **Swinject**: Dependency Injection (DI) framework for managing dependencies.
- **Combine**: Reactive programming framework for handling asynchronous events and data.
- **URLSession**: Network requests handling with Combine integration.
- **UserAuthenticationManager**: A centralized manager for user authentication and related operations.

## Project Structure

- **Network Request**: A generic network request implementation using Combine and URLSession that can be used throughout the project.
- **UserAuthenticationManager**: Manages user authentication flow, including login, logout, and session management.
- **SwiftUI Views**: Sample SwiftUI views to demonstrate the use of dependency injection and network requests.

## Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/muhammadabbas001/swiftui-project-setup.git
   
2. **Navigate to the Project Directory**
   ```bash
   cd swiftui-project-setup

3. **Open the Project in Xcode**
   ```bash
   open YourProjectName.xcodeproj

4. **Install Dependencies**
   ```bash
   pod install

## Usage

1. **Setting Up Dependency Injection**
   Initialize and configure Swinject in the AppDelegate or SceneDelegate. Define your dependencies and register them with the Swinject container.
   
3. **Making Network Requests**
   Use the provided network request manager to handle API calls. The network manager integrates seamlessly with Combine publishers for reactive data handling.
   
4. **Managing User Authentication**
   Utilize the UserAuthenticationManager to handle login, logout, and session management throughout your app. Integrate it into your views and view models as needed.

4. **Contributing**
   We welcome contributions to this project! If you'd like to contribute, please review the contributing guidelines for details on how to submit changes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.


