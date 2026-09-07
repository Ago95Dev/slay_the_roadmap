import { PlayerProgress } from '../types';

const STORAGE_KEY = 'dart-quest-progress';

export const saveProgress = (progress: PlayerProgress): void => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
  } catch (error) {
    console.error('Failed to save progress:', error);
  }
};

export const loadProgress = (): PlayerProgress | null => {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      return JSON.parse(saved);
    }
  } catch (error) {
    console.error('Failed to load progress:', error);
  }
  return null;
};

export const resetProgress = (): void => {
  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch (error) {
    console.error('Failed to reset progress:', error);
  }
};
