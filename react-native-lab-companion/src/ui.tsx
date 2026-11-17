import { Feather } from '@expo/vector-icons';
import type { ComponentProps, ReactNode } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAppearance } from './theme';

export type IconName = ComponentProps<typeof Feather>['name'];

export function Screen({ children }: { children: ReactNode }) {
  const { colors } = useAppearance();
  const insets = useSafeAreaInsets();
  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: colors.background }}
      contentContainerStyle={{
        paddingTop: Math.max(insets.top, 12) + 12,
        paddingLeft: Math.max(insets.left, 18),
        paddingRight: Math.max(insets.right, 18),
        paddingBottom: Math.max(insets.bottom, 24),
      }}
      keyboardShouldPersistTaps="handled"
    >
      <View style={styles.content}>{children}</View>
    </ScrollView>
  );
}

export function IconButton({ icon, label, onPress }: { icon: IconName; label: string; onPress: () => void }) {
  const { colors } = useAppearance();
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      onPress={onPress}
      style={({ pressed }) => [styles.iconButton, {
        backgroundColor: pressed ? colors.tint : colors.surface,
        borderColor: colors.border,
      }]}
    >
      <Feather name={icon} size={20} color={colors.accent} />
    </Pressable>
  );
}

export function ScreenHeader({ title, subtitle, onBack }: { title: string; subtitle: string; onBack: () => void }) {
  const { colors } = useAppearance();
  return (
    <View style={{ gap: 12 }}>
      <IconButton icon="arrow-left" label="Back to dashboard" onPress={onBack} />
      <Text accessibilityRole="header" style={[styles.pageTitle, { color: colors.text }]}>{title}</Text>
      <Text style={[styles.body, { color: colors.muted }]}>{subtitle}</Text>
    </View>
  );
}

export function ActivityCard({ title, description, onPress }: { title: string; description: string; onPress: () => void }) {
  const { colors } = useAppearance();
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={title}
      accessibilityHint={description}
      onPress={onPress}
      style={({ pressed }) => [styles.card, {
        backgroundColor: pressed ? colors.tint : colors.surface,
        borderColor: colors.border,
      }]}
    >
      <View style={[styles.iconTile, { backgroundColor: colors.tint }]}>
        <Feather name="code" size={22} color={colors.accent} />
      </View>
      <View style={styles.cardBody}>
        <Text style={[styles.cardTitle, { color: colors.text }]}>{title}</Text>
        <Text style={[styles.body, { color: colors.muted }]}>{description}</Text>
      </View>
      <Feather name="arrow-up-right" size={20} color={colors.accent} />
    </Pressable>
  );
}

export const styles = StyleSheet.create({
  content: { width: '100%', maxWidth: 900, alignSelf: 'center', gap: 22 },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12 },
  iconButton: { width: 48, height: 48, borderRadius: 15, borderWidth: 1, justifyContent: 'center', alignItems: 'center' },
  iconTile: { width: 46, height: 46, borderRadius: 14, justifyContent: 'center', alignItems: 'center' },
  pageTitle: { fontSize: 32, fontWeight: '800', letterSpacing: -1 },
  sectionTitle: { fontSize: 23, fontWeight: '800', letterSpacing: -0.5 },
  cardTitle: { fontSize: 17, fontWeight: '700' },
  body: { fontSize: 15, lineHeight: 22 },
  card: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 15, borderWidth: 1, borderRadius: 19 },
  cardBody: { flex: 1, minWidth: 0, gap: 4 },
});
