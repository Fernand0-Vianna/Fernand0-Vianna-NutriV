# NutriV - AI Calorie Counter App

## 1. Project Overview

**Project Name:** NutriV  
**Project Type:** Flutter Mobile Application (iOS & Android)  
**Core Functionality:** AI-powered calorie and macro counter that uses camera, voice, and text input to recognize food and calculate nutritional values automatically.

## 2. Technology Stack & Choices

### Framework & Language
- **Framework:** Flutter 3.41+
- **Language:** Dart 3.11+
- **Minimum SDK:** Android 21 / iOS 12

### Key Libraries/Dependencies
- **State Management:** flutter_bloc (BLoC pattern)
- **HTTP Client:** dio
- **Image Picker:** image_picker (camera/gallery)
- **Local Storage:** shared_preferences, sqflite
- **Charts:** fl_chart
- **Camera:** camera
- **Voice:** speech_to_text
- **Barcode:** mobile_scanner
- **Navigation:** go_router
- **Dependency Injection:** get_it
- **Equatable:** equatable

### AI Integration
- **Primary:** Google Gemini API (Vision + Text)
- **Alternative:** OpenAI GPT-4 Vision API
- **Food Database:** Custom local database + USDA API

### Architecture Pattern
- **Clean Architecture** with 3 layers:
  - **Presentation** (UI + BLoC)
  - **Domain** (Entities + Use Cases)
  - **Data** (Repositories + Data Sources)

## 3. Feature List

### Core Features
1. **AI Food Scanner**
   - Photo capture (camera)
   - Image from gallery
   - Voice input (describe food)
   - Text input (manual search)
   - Barcode scanning
   - Food database search

2. **Nutritional Analysis**
   - Calories calculation
   - Macros: Protein, Carbs, Fat
   - Micronutrients (optional)
   - Portion size estimation

3. **Food Diary**
   - Daily meal log (Breakfast, Lunch, Dinner, Snacks)
   - Meal history
   - Edit/Delete entries
   - Copy meals

4. **Daily Summary Dashboard**
   - Calories progress (circular chart)
   - Macros breakdown (protein/carbs/fat)
   - Water intake tracker
   - Weekly/Monthly trends

5. **Progress Tracking**
   - Weight log
   - Progress charts
   - Goal setting (lose/gain/maintain)
   - Calorie/macro goals

6. **User Profile**
   - Personal data (age, height, weight, activity level)
   - BMR calculation
   - TDEE calculation
   - Goals configuration

7. **Tools (Free)**
   - Calorie Calculator
   - Macro Calculator
   - BMR Calculator
   - Protein Calculator

### Secondary Features
- Offline mode support
- Data export
- Dark/Light theme

## 4. UI/UX Design Direction

### Overall Visual Style
- **Design System:** Material Design 3
- **Style:** Clean, modern, fitness-focused
- **Typography:** Clean sans-serif (Roboto/Inter)

### Color Scheme
- **Primary:** Green (#4CAF50) - Health/Nutrition association
- **Secondary:** Orange (#FF9800) - Energy/Vitality
- **Background:** White (light) / Dark Gray (dark mode)
- **Accent:** Teal for charts/progress

### Layout Approach
- **Navigation:** Bottom navigation bar with 4 tabs
  1. Home (Dashboard)
  2. Diary (Food Log)
  3. Scanner (AI Camera)
  4. Profile (Settings)
- **FAB:** Floating action button for quick food add
- **Cards:** Food items in card format
- **Charts:** Circular progress for daily goals

### Key Screens
1. Dashboard - Daily summary with macros
2. Food Scanner - Camera with AI overlay
3. Diary - List of meals with add button
4. Food Details - Nutritional info + edit portion
5. Profile - User settings and goals
6. Tools - Calculator screens

## 5. API Integration

### AI Food Recognition Flow
1. User captures photo or selects image
2. Image sent to Gemini API with prompt
3. API returns JSON with food items, portions, macros
4. User confirms/edits values
5. Data saved to local database

### Sample API Request (Gemini)
```
Prompt: "Analyze this food image and return JSON with:
- food_name
- portion_size (grams)
- calories
- protein (g)
- carbs (g)
- fat (g)"
```

### Fallback
- If AI fails, show manual search
- Local food database as backup

## 6. Data Models

### Core Entities
- User (profile, goals, preferences)
- Meal (date, time, meal_type)
- FoodItem (name, calories, macros, portion)
- DailyLog (date, total_calories, macros, water)
- WeightEntry (date, weight)

## 7. File Structure

```
lib/
├── core/           # Constants, theme, utils
├── data/          # Repositories, data sources, models
├── domain/        # Entities, use cases
├── presentation/  # UI, BLoC, widgets
└── main.dart
```