# sppb_rgb (Image Collection Application)

This is a Flutter-based mobile application designed for collecting images of individuals performing specific balance postures. The application is intended for use in research and development of machine learning models for balance posture classification, particularly in the context of frailty assessment in elderly individuals.

## Features

- **Label Selection:** Users can select the specific balance posture they wish to capture images for, including feet-together, semi-tandem, tandem, and no-balance positions.
- **Continuous Image Capture:** The application captures a stream of high-resolution images for a duration of 15 seconds per session.
- **Review and Share:** Users can review captured images, select specific images, and share them via email, messaging apps, or directly upload them to Google Drive.
- **Camera Switching:** Users can switch between the front and rear cameras of the device.

## Installation

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (Ensure you have Flutter installed and configured on your machine)
- A compatible device (Android or iOS) for running the application

### Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/agascocompte/tfm-sppb-rgb.git
   ```

2. **Navigate to the project directory:**

   ```bash
   cd tfm-sppb-rgb
   ```

3. **Install dependencies:**

   Run the following command to install all required dependencies:
   
   ```bash
   flutter pub get
   ```
   
4. **Run the application:**

   Connect your mobile device or start an emulator, then run:
   
   ```bash
   flutter run
   ```

## Usage

1. **Start the application:** Open the app on your mobile device.
2. **Select a balance posture:** Choose the desired posture label from the top menu.
3. **Capture images:** Press the capture button to start recording images. The application will automatically capture images for 15 seconds.
4. **Review images:** After capturing, you can review the images in the gallery.
5. **Share images:** Select the images you want to share and use the sharing options to send them via email, messaging apps, or upload them to Google Drive.

## Contact

For any questions or inquiries, please contact [agasco@uji.es](mailto:agasco@uji.es).
