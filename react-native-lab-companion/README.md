# Activity 5 React Native

Activity 5 React Native is an Expo and TypeScript mobile app for compiling React Native laboratory activities. The dashboard opens each lab, and Settings controls the appearance of all screens using React Context. Search is managed locally with `useState`. The theme updates immediately and is saved on the device for the next launch.

## Run locally

1. Install Node.js 22 LTS and npm.
2. Run `npm install` after cloning the repository.
3. Run `npm start`. On Android, scan the QR code using Expo Go for SDK 54 or press **a** with an Android emulator running.
4. For a browser preview, run `npm run web`. Run `npm run typecheck` to check TypeScript.

## Add a lab

Add a unique ID, title, description, and task list to `src/activities.ts`. Its dashboard card and detail route will use that entry automatically. For a lab that needs its own interactive screen, register the screen in `src/App.tsx` and its route in `RootStack`.

## Screen-recording walkthrough

1. Show the dashboard on a narrow portrait screen. Open the activity, scroll if needed, and return.
2. Search for a title and clear the search. Rotate to landscape or widen the emulator or browser viewport to show how the layout adapts.
3. Open Settings and turn on **Dark mode**. Go back to the dashboard, where the palette and the mode label update. Open the activity to show that it uses the same theme.
4. Return to Settings, turn Dark mode off, and show the dashboard in Light mode again.
