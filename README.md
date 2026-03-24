README
Team members:
Rolena Williams
Edu M. Okpok

Project Summary
Title: Adaptive Focus Studio App
The Adaptive Focus Studio App, MindMap, Is a productivity app that helps users enter.Work states.Using personalized soundscapes, Pomodoro-style timers, and mood-based session setup. The app provides users with a personalized audio environment beased on their mood,task type, and energy, helping them to create an ideal environment for concentrating.
For users who want to create an ideal environment for concentrating and studying.

Features Implemented
Adaptive Soundscape Generator
Tracker
Ai focus DJ
Pomodoro-style deep work sessions
Session blueprints

Screens Overview
Welcome Screen 
App Introduction
Focus Setup Screen
Form with mood, task, energy slider, date picker
AI recommendation DJ
Summary card
“Save Setup” button

Soundscape Screen
Audio controls/Sound mix
Volume sliders
Load/Save presets
Active Session Screen
Timer
Start/Pause/Reset
Exit Session
Insights Screen
Tracker
Total/Completed Sessions
Average Work Duration
Edit/Delete Sessions

Technologies used 
Flutter + Dart
Flutter version: Flutter 3.38.7
Packages: Shared Preferences, Sqflite, path
Tools: Android Studios emulator
VS Code
Github
SQLite for database


Installation Instructions 
Before running the project, make sure you have Flutter SDK, Dart SDK, Android Studio/Visual Studio Code, Chrome Browser, and Git. The best way to verify installation is to type “flutter doctor” into the terminal.
 
First,  the repo needs to be cloned using “git clone [repo name]” and run “flutter pub get” in the terminal, to make the dependencies are added. Secondly, to run the app, for chrome “flutter run -d chrome” and for Android type “flutter run”.

User Guide
Open the app
Welcome screen opens
On the welcome screen it gives the user an introduction to the app and shows the features we offer.
The user presses the start session setup button if they want to continue
The navigation screen opens and the user is in the focus setup screen 
Here the user can fill out the form which includes: Session name, Mood, Task, Session Date, Energy Level, Work Duration, and Break Curation. The user can also choose between light or dark mode.
The user can use the ai dj to generate after they’ve filled out the required fields on the form and apply that recommendation to the form.
Once they’re done they can save the setup if they choose and move to the active session screen.
During the session they can start, pause, and reset the timer, or leave if they want to finish for the day. 
On the soundscape screen they can toggle between different sound options and save them or load previous presets.
The insights screen tracks the total sessions, completed sessions, and average focus screen.
The insights screen holds the saved sessions that users can edit or delete.


Schema Structure Example
CREATE TABLE $focusSessionsTable (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       session_name TEXT NOT NULL,
       mood TEXT NOT NULL,
       task_type TEXT NOT NULL,
       energy_level INTEGER NOT NULL,
       work_duration_minutes INTEGER NOT NULL,
       break_duration_minutes INTEGER NOT NULL,
       session_date TEXT NOT NULL,
       completed INTEGER NOT NULL DEFAULT 0,
       ai_feedback INTEGER NOT NULL,
       created_at TEXT NOT NULL
)

Know Issues
When reset button was pressed it would go to default work duration instead of selected work duration (fixed)
Limited Analytics
Local Data Storage only/No APIs


Future Enhancements
Adding charts for more data
Restart Saved Sessions
Cloud Sync


License
MIT License

Copyright (c) 2026 RolenaWilliams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
