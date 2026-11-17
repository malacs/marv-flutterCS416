import AsyncStorage from '@react-native-async-storage/async-storage';
import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';

const light = {
  background: '#F7F7F2', surface: '#FFFFFF', text: '#16251E', muted: '#4D6156',
  border: '#D8E1D8', accent: '#1B6949', tint: '#E5F1E9', hero: '#133E30',
  heroText: '#FFFFFF', heroMuted: '#CEEBDB', off: '#667E71',
};
const dark: typeof light = {
  background: '#101A15', surface: '#192820', text: '#EEF6EE', muted: '#B2C8B8',
  border: '#35483D', accent: '#8DE2B1', tint: '#263D31', hero: '#244836',
  heroText: '#FFFFFF', heroMuted: '#DBF4E4', off: '#667E71',
};

const themeKey = 'lab-companion:theme';
type Appearance = { isDark: boolean; setIsDark: (value: boolean) => void; colors: typeof light };
const AppearanceContext = createContext<Appearance | null>(null);

export function AppearanceProvider({ children }: { children: ReactNode }) {
  const [savedMode, setSavedMode] = useState<boolean | null>(null);

  useEffect(() => {
    let active = true;
    AsyncStorage.getItem(themeKey).then(
      (value) => { if (active) setSavedMode((current) => current ?? (value === 'dark')); },
      () => { if (active) setSavedMode((current) => current ?? false); },
    );
    return () => { active = false; };
  }, []);

  const value = useMemo<Appearance>(() => {
    const isDark = savedMode ?? false;
    return {
      isDark,
      colors: isDark ? dark : light,
      setIsDark(nextMode) {
        setSavedMode(nextMode);
        AsyncStorage.setItem(themeKey, nextMode ? 'dark' : 'light').catch(() => {
          // The selected theme is still available for the current session.
        });
      },
    };
  }, [savedMode]);

  return <AppearanceContext.Provider value={value}>{children}</AppearanceContext.Provider>;
}

export function useAppearance() {
  const appearance = useContext(AppearanceContext);
  if (!appearance) throw new Error('AppearanceProvider is required');
  return appearance;
}
