import { Feather } from '@expo/vector-icons';
import { DarkTheme, DefaultTheme, NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator, type NativeStackScreenProps } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import { useState } from 'react';
import { StyleSheet, Switch, Text, TextInput, View, useWindowDimensions } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { activities, type RootStack } from './activities';
import { AppearanceProvider, useAppearance } from './theme';
import { ActivityCard, IconButton, Screen, ScreenHeader, styles } from './ui';

const Stack = createNativeStackNavigator<RootStack>();

function Home({ navigation }: NativeStackScreenProps<RootStack, 'Home'>) {
  const { isDark, colors } = useAppearance();
  const [query, setQuery] = useState('');
  const { width } = useWindowDimensions();
  const wide = width >= 680;
  const search = query.trim().toLowerCase();
  const visibleActivities = activities.filter(({ title, description }) =>
    (title + ' ' + description).toLowerCase().includes(search),
  );

  return (
    <Screen>
      <View style={[styles.row, { justifyContent: 'space-between' }]}>
        <View style={[styles.row, { flex: 1 }]}>
          <View style={[styles.iconTile, { backgroundColor: colors.tint }]}>
            <Feather name="layers" size={21} color={colors.accent} />
          </View>
          <Text accessibilityRole="header" style={[styles.cardTitle, { flex: 1, color: colors.text }]}>Activity 5 React Native</Text>
        </View>
        <IconButton icon="settings" label="Settings" onPress={() => navigation.navigate('Settings')} />
      </View>

      <View style={[layout.hero, { backgroundColor: colors.hero, padding: wide ? 34 : 22 }]}>
        <View style={{ gap: 8 }}>
          <Text style={[layout.heroTitle, { color: colors.heroText, fontSize: wide ? 42 : 34 }]}>Lab dashboard</Text>
          <Text style={[styles.body, { color: colors.heroMuted }]}>Open your mobile development lab activities.</Text>
        </View>
        <View style={[styles.row, { gap: 8 }]}>
          <Feather name={isDark ? 'moon' : 'sun'} color={colors.heroMuted} size={17} />
          <Text style={[styles.body, { color: colors.heroMuted }]}>{isDark ? 'Dark mode' : 'Light mode'}</Text>
        </View>
      </View>

      <View style={{ gap: 12 }}>
        <Text accessibilityRole="header" style={[styles.sectionTitle, { color: colors.text }]}>Activities</Text>
        <View style={[styles.row, layout.search, { borderColor: colors.border, backgroundColor: colors.surface }]}>
          <Feather name="search" size={19} color={colors.muted} />
          <TextInput
            accessibilityLabel="Search activities"
            autoCapitalize="none"
            autoCorrect={false}
            value={query}
            onChangeText={setQuery}
            placeholder="Search activities"
            placeholderTextColor={colors.muted}
            style={[styles.body, { flex: 1, minWidth: 0, minHeight: 48, color: colors.text }]}
          />
        </View>
        <View style={[layout.cards, wide && layout.wideCards]}>
          {visibleActivities.map((activity) => (
            <View key={activity.id} style={wide ? layout.wideCard : undefined}>
              <ActivityCard
                title={activity.title}
                description={activity.description}
                onPress={() => navigation.navigate('Activity', { id: activity.id })}
              />
            </View>
          ))}
        </View>
        {visibleActivities.length === 0 && (
          <Text accessibilityLiveRegion="polite" style={[styles.body, { color: colors.muted }]}>No matching activities.</Text>
        )}
      </View>
    </Screen>
  );
}

function Settings({ navigation }: NativeStackScreenProps<RootStack, 'Settings'>) {
  const { isDark, setIsDark, colors } = useAppearance();
  return (
    <Screen>
      <ScreenHeader title="Settings" subtitle="Choose how Activity 5 React Native looks across all screens." onBack={navigation.goBack} />
      <View style={[styles.card, { backgroundColor: colors.surface, borderColor: colors.border }]}>
        <View style={[styles.iconTile, { backgroundColor: colors.tint }]}>
          <Feather name={isDark ? 'moon' : 'sun'} size={21} color={colors.accent} />
        </View>
        <View style={styles.cardBody}>
          <Text style={[styles.cardTitle, { color: colors.text }]}>Dark mode</Text>
          <Text style={[styles.body, { color: colors.muted }]}>{isDark ? 'On' : 'Off'}</Text>
        </View>
        <Switch
          accessibilityLabel="Dark mode"
          value={isDark}
          onValueChange={setIsDark}
          trackColor={{ false: colors.off, true: colors.accent }}
          thumbColor={isDark ? '#133E30' : '#FFFFFF'}
          ios_backgroundColor={colors.off}
        />
      </View>
    </Screen>
  );
}

function Activity({ navigation, route }: NativeStackScreenProps<RootStack, 'Activity'>) {
  const { colors } = useAppearance();
  const activity = activities.find(({ id }) => id === route.params.id);
  return (
    <Screen>
      <ScreenHeader
        title={activity?.title ?? 'Activity unavailable'}
        subtitle={activity?.description ?? 'Return to the dashboard to select an activity.'}
        onBack={navigation.goBack}
      />
      {activity && (
        <View style={[layout.taskPanel, { backgroundColor: colors.surface, borderColor: colors.border }]}>
          <Text accessibilityRole="header" style={[styles.sectionTitle, { color: colors.text }]}>Try it</Text>
          {activity.tasks.map((task, index) => (
            <View key={task} style={[styles.row, { alignItems: 'flex-start' }]}>
              <Text style={[styles.body, { color: colors.accent, fontWeight: '700' }]}>{index + 1}.</Text>
              <Text style={[styles.body, { flex: 1, color: colors.text }]}>{task}</Text>
            </View>
          ))}
        </View>
      )}
    </Screen>
  );
}

function AppNavigation() {
  const { isDark, colors } = useAppearance();
  const base = isDark ? DarkTheme : DefaultTheme;

  return (
    <NavigationContainer theme={{
      ...base,
      colors: { ...base.colors, primary: colors.accent, background: colors.background, card: colors.surface, text: colors.text, border: colors.border },
    }}>
      <StatusBar style={isDark ? 'light' : 'dark'} />
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        <Stack.Screen name="Home" component={Home} />
        <Stack.Screen name="Settings" component={Settings} />
        <Stack.Screen name="Activity" component={Activity} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <AppearanceProvider>
        <AppNavigation />
      </AppearanceProvider>
    </SafeAreaProvider>
  );
}

const layout = StyleSheet.create({
  hero: { borderRadius: 23, gap: 20 },
  heroTitle: { fontWeight: '800', letterSpacing: -1.3 },
  search: { borderRadius: 14, borderWidth: 1, paddingHorizontal: 14 },
  cards: { gap: 12 },
  wideCards: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between' },
  wideCard: { width: '49%' },
  taskPanel: { gap: 15, padding: 20, borderRadius: 19, borderWidth: 1 },
});
