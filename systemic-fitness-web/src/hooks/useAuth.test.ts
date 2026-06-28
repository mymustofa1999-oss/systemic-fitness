import { describe, it, expect, vi } from 'vitest';
import { renderHook } from '@testing-library/react';
import { useAuth } from './useAuth';

// Mock next-auth/react
const mockSession = vi.fn();

vi.mock('next-auth/react', () => ({
  useSession: () => mockSession(),
}));

describe('useAuth', () => {
  it('returns unauthenticated state when no session', () => {
    mockSession.mockReturnValue({ data: null, status: 'unauthenticated' });

    const { result } = renderHook(() => useAuth());

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.role).toBe('client');
  });

  it('returns loading state', () => {
    mockSession.mockReturnValue({ data: null, status: 'loading' });

    const { result } = renderHook(() => useAuth());

    expect(result.current.isLoading).toBe(true);
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('returns authenticated admin user', () => {
    mockSession.mockReturnValue({
      data: {
        user: { id: 'u1', role: 'admin', email: 'admin@test.com' },
      },
      status: 'authenticated',
    });

    const { result } = renderHook(() => useAuth());

    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.role).toBe('admin');
    expect(result.current.isAdmin).toBe(true);
    expect(result.current.isTrainer).toBe(false);
    expect(result.current.isClient).toBe(false);
  });

  it('identifies owner role correctly', () => {
    mockSession.mockReturnValue({
      data: { user: { id: 'u1', role: 'owner' } },
      status: 'authenticated',
    });

    const { result } = renderHook(() => useAuth());

    expect(result.current.isOwner).toBe(true);
    expect(result.current.isAdmin).toBe(true); // owner is also admin
  });

  it('identifies trainer role correctly', () => {
    mockSession.mockReturnValue({
      data: { user: { id: 'u1', role: 'trainer' } },
      status: 'authenticated',
    });

    const { result } = renderHook(() => useAuth());

    expect(result.current.isTrainer).toBe(true);
    expect(result.current.isAdmin).toBe(false);
    expect(result.current.isClient).toBe(false);
  });

  it('identifies client role correctly', () => {
    mockSession.mockReturnValue({
      data: { user: { id: 'u1', role: 'client' } },
      status: 'authenticated',
    });

    const { result } = renderHook(() => useAuth());

    expect(result.current.isClient).toBe(true);
    expect(result.current.isTrainer).toBe(false);
    expect(result.current.isAdmin).toBe(false);
    expect(result.current.isFinance).toBe(false);
  });

  it('identifies finance role correctly', () => {
    mockSession.mockReturnValue({
      data: { user: { id: 'u1', role: 'finance' } },
      status: 'authenticated',
    });

    const { result } = renderHook(() => useAuth());

    expect(result.current.isFinance).toBe(true);
    expect(result.current.isTrainer).toBe(false);
  });
});
