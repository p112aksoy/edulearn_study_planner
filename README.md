# EduLearn - Study Planner

EduLearn is a Flutter-based mobile application designed to help university students manage their courses, track deadlines, use Pomodoro technique for focused study, and maintain quick notes.

## Features

- **User Authentication** – Register, login, password reset
- **Course Management** – Add, edit, delete courses with target hours and progress tracking
- **Pomodoro Timer** – Adjustable study/break sessions with course progress sync
- **Deadline Tracking** – Add deadlines with automatic date sorting
- **Scratchpad** – Quick todo notes with completion checkmarks
- **Ambient Sounds** – Calm rain, ocean waves, morning birds for focus
- **Profile** – View personal info and upload profile photo
- **Dark/Light Theme** – Toggle with persistent preference
- **Responsive Design** – Works on mobile, tablet, and desktop

## Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Database:** SQLite (sqflite)
- **Local Storage:** SharedPreferences
- **Audio:** audioplayers
- **Image Picker:** image_picker

## Project Structure

lib/
├── core/ # Theme, responsive, routes
├── data/ # DAO, Database, Models, Repositories
├── logic/ # Providers (state management)
└── presentation/ # Screens, Pages, Widgets

## Setup Instructions

1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get`
4. Run `flutter run`

## Database Schema

- **users** – id, fullName, email, password, studentId, major, school, year, photoUrl
- **courses** – id, userId (FK), title, progress, targetHours
- **deadlines** – id, userId (FK), title, date
- **scratchpad** – id, userId (FK), task, isDone

## Developer

Pelin Aksoy - Computer Engineer

## Course Info

- **Course:** CEN306 - Mobile Application Design and Development
- **Instructor:** Dr. Yıldız Karadayı

## License

This project is submitted for academic purposes.
