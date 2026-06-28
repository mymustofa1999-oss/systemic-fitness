import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Sidebar } from './Sidebar';

// ── Mocks ─────────────────────────────────────────────

// Mock next/navigation
vi.mock('next/navigation', () => ({
  usePathname: () => '/',
}));

// Mock next/link
vi.mock('next/link', () => ({
  default: ({ children, href, ...props }: any) => (
    <a href={href} {...props}>{children}</a>
  ),
}));

// Mock next-auth/react with configurable role
let mockRole = 'admin';
vi.mock('next-auth/react', () => ({
  useSession: () => ({
    data: {
      user: { id: 'u1', role: mockRole, email: 'test@test.com' },
      accessToken: 'mock-token',
    },
    status: 'authenticated',
  }),
}));

// Mock zustand UI store
vi.mock('@/stores/uiStore', () => ({
  useUIStore: () => ({
    sidebarCollapsed: false,
    toggleCollapse: vi.fn(),
  }),
}));

// ── Tests ─────────────────────────────────────────────

describe('Sidebar', () => {
  beforeEach(() => {
    mockRole = 'admin';
  });

  it('renders logo text', () => {
    render(<Sidebar />);
    expect(screen.getByText('Systemic Fitness')).toBeInTheDocument();
  });

  it('renders Dashboard link for all roles', () => {
    render(<Sidebar />);
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
  });

  it('renders Settings link for all roles', () => {
    render(<Sidebar />);
    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  it('shows admin-only items for admin role', () => {
    mockRole = 'admin';
    render(<Sidebar />);

    expect(screen.getByText('Users')).toBeInTheDocument();
    expect(screen.getByText('Exercises')).toBeInTheDocument();
    expect(screen.getByText('Workouts')).toBeInTheDocument();
    expect(screen.getByText('Programs')).toBeInTheDocument();
    expect(screen.getByText('Progress')).toBeInTheDocument();
    expect(screen.getByText('Nutrition')).toBeInTheDocument();
    expect(screen.getByText('Messages')).toBeInTheDocument();
    expect(screen.getByText('Automations')).toBeInTheDocument();
  });

  it('hides admin items for client role', () => {
    mockRole = 'client';
    render(<Sidebar />);

    // Client should see: Dashboard, Messages, Settings
    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Messages')).toBeInTheDocument();
    expect(screen.getByText('Settings')).toBeInTheDocument();

    // Should NOT see admin/trainer-only items
    expect(screen.queryByText('Users')).not.toBeInTheDocument();
    expect(screen.queryByText('Exercises')).not.toBeInTheDocument();
    expect(screen.queryByText('Workouts')).not.toBeInTheDocument();
    expect(screen.queryByText('Automations')).not.toBeInTheDocument();
    expect(screen.queryByText('Payments')).not.toBeInTheDocument();
  });

  it('shows trainer items for trainer role', () => {
    mockRole = 'trainer';
    render(<Sidebar />);

    expect(screen.getByText('Exercises')).toBeInTheDocument();
    expect(screen.getByText('Workouts')).toBeInTheDocument();
    expect(screen.getByText('Programs')).toBeInTheDocument();
    expect(screen.getByText('Messages')).toBeInTheDocument();

    // Trainer should NOT see payments or users
    expect(screen.queryByText('Users')).not.toBeInTheDocument();
    expect(screen.queryByText('Payments')).not.toBeInTheDocument();
  });

  it('shows payment for finance role', () => {
    mockRole = 'finance';
    render(<Sidebar />);

    expect(screen.getByText('Payments')).toBeInTheDocument();
    expect(screen.queryByText('Users')).not.toBeInTheDocument();
    expect(screen.queryByText('Exercises')).not.toBeInTheDocument();
  });

  it('renders navigation links with correct hrefs', () => {
    mockRole = 'admin';
    render(<Sidebar />);

    const dashLink = screen.getByText('Dashboard').closest('a');
    expect(dashLink).toHaveAttribute('href', '/');

    const usersLink = screen.getByText('Users').closest('a');
    expect(usersLink).toHaveAttribute('href', '/users');

    const msgLink = screen.getByText('Messages').closest('a');
    expect(msgLink).toHaveAttribute('href', '/messages');
  });
});
