export const activities = [
  {
    id: 'app-shell',
    title: 'React Native App Shell',
    description: 'Explore the dashboard, screen navigation, and shared appearance setting.',
    tasks: [
      'Open the dashboard and try the activity search.',
      'Compare the layout at narrow and wide screen sizes.',
      'Turn on Dark mode in Settings and return to the dashboard.',
    ],
  },
] as const;

export type ActivityId = (typeof activities)[number]['id'];
export type RootStack = { Home: undefined; Settings: undefined; Activity: { id: ActivityId } };
