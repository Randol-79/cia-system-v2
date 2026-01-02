/**
 * CIA System - Admin Dashboard
 * Main React Application
 */

import React, { useState, useEffect } from 'react';
import {
  Box,
  CssBaseline,
  ThemeProvider,
  createTheme,
  AppBar,
  Toolbar,
  Typography,
  Drawer,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  ListItemButton,
  Container,
  Grid,
  Card,
  CardContent,
  CardHeader,
  Chip,
  Alert,
  CircularProgress,
  Button,
  Snackbar,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Breadcrumbs,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Divider
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  AssignmentTurnedIn as TaskIcon,
  TrendingUp as TrendingUpIcon,
  Settings as SettingsIcon,
  Notifications as NotificationsIcon,
  CheckCircle as CheckCircleIcon,
  Warning as WarningIcon,
  Error as ErrorIcon,
  ArrowBack as ArrowBackIcon,
  Home as HomeIcon,
  Add as AddIcon,
  Assessment as AssessmentIcon,
  Download as DownloadIcon,
  Print as PrintIcon,
  FilterList as FilterListIcon,
  Close as CloseIcon,
  Close,
  People,
  TrendingUp,
  Task
} from '@mui/icons-material';
import { BrowserRouter as Router, Routes, Route, Link, useLocation, useNavigate } from 'react-router-dom';
import ClientProfile from './pages/ClientProfile';
import ContactClient from './pages/ContactClient';
import EditClient from './pages/EditClient';
import io from 'socket.io-client';
import axios from 'axios';

// Configure axios defaults
axios.defaults.baseURL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

// ============================================================================
// DEVELOPMENT MODE STATE - Global toggle for mock data
// ============================================================================
let USE_MOCK_DATA = localStorage.getItem('comit_dev_mode') === 'true';

export const setDevMode = (enabled) => {
  USE_MOCK_DATA = enabled;
  localStorage.setItem('comit_dev_mode', enabled.toString());
  console.log(`🔧 Development Mode: ${enabled ? 'ENABLED (Using Mock Data)' : 'DISABLED (Using Real API)'}`);
};

export const isDevMode = () => USE_MOCK_DATA;

// ============================================================================
// MOCK DATA CONTAINER - Isolated from real data
// ============================================================================
const MOCK_DATA = {
  stats: {
    activeClients: 12,
    pendingTasks: 8,
    completedThisMonth: 34,
    revenue: 125000
  },
  
  events: [
    { id: 1, type: 'call_completed', event_type: 'call_completed', client: 'Acme Corp', status: 'completed', timestamp: new Date().toISOString(), description: 'Sales call with decision maker' },
    { id: 2, type: 'recommendation_generated', event_type: 'recommendation_generated', client: 'TechStart Inc', status: 'pending', timestamp: new Date(Date.now() - 3600000).toISOString(), description: 'AI recommended follow-up strategy' },
    { id: 3, type: 'task_completed', event_type: 'task_completed', client: 'Global Solutions', status: 'completed', timestamp: new Date(Date.now() - 7200000).toISOString(), description: 'Contract review completed' },
    { id: 4, type: 'integration_sync', event_type: 'integration_sync', client: 'Fireflies', status: 'completed', timestamp: new Date(Date.now() - 10800000).toISOString(), description: 'Meeting transcripts synced' },
    { id: 5, type: 'call_completed', event_type: 'call_completed', client: 'Enterprise Co', status: 'completed', timestamp: new Date(Date.now() - 14400000).toISOString(), description: 'Product demo call' }
  ],
  
  allEvents: [
    { id: 1, type: 'call_completed', event_type: 'call_completed', client: 'Acme Corp', status: 'completed', timestamp: new Date().toISOString(), description: 'Sales call with decision maker', related_clients: ['Acme Corp', 'Acme Subsidiary'], related_tasks: ['Follow-up email', 'Send proposal'], actionable: true },
    { id: 2, type: 'recommendation_generated', event_type: 'recommendation_generated', client: 'TechStart Inc', status: 'pending', timestamp: new Date(Date.now() - 3600000).toISOString(), description: 'AI recommended follow-up strategy', related_clients: ['TechStart Inc'], related_tasks: ['Schedule demo'], actionable: true },
    { id: 3, type: 'task_completed', event_type: 'task_completed', client: 'Global Solutions', status: 'completed', timestamp: new Date(Date.now() - 7200000).toISOString(), description: 'Contract review completed', related_clients: ['Global Solutions'], related_tasks: [], actionable: false },
    { id: 4, type: 'integration_sync', event_type: 'integration_sync', client: 'Fireflies', status: 'completed', timestamp: new Date(Date.now() - 10800000).toISOString(), description: 'Meeting transcripts synced', related_clients: [], related_tasks: [], actionable: false },
    { id: 5, type: 'call_completed', event_type: 'call_completed', client: 'Enterprise Co', status: 'completed', timestamp: new Date(Date.now() - 14400000).toISOString(), description: 'Product demo call', related_clients: ['Enterprise Co'], related_tasks: ['Send follow-up', 'Schedule next meeting'], actionable: true },
    { id: 6, type: 'recommendation_approved', event_type: 'recommendation_approved', client: 'Beta Systems', status: 'completed', timestamp: new Date(Date.now() - 18000000).toISOString(), description: 'Recommendation approved and actioned', related_clients: ['Beta Systems'], related_tasks: ['Execute strategy'], actionable: false },
    { id: 7, type: 'task_created', event_type: 'task_created', client: 'Innovation Labs', status: 'pending', timestamp: new Date(Date.now() - 21600000).toISOString(), description: 'New task: Quarterly review', related_clients: ['Innovation Labs'], related_tasks: ['Q4 Review'], actionable: true },
    { id: 8, type: 'call_scheduled', event_type: 'call_scheduled', client: 'Dynamic Corp', status: 'pending', timestamp: new Date(Date.now() - 25200000).toISOString(), description: 'Call scheduled for next week', related_clients: ['Dynamic Corp'], related_tasks: ['Prepare agenda'], actionable: true }
  ],
  
  integrationHealth: {
    accelo: { is_healthy: true, last_check_at: new Date().toISOString(), status: 'healthy' },
    fireflies: { is_healthy: true, last_check_at: new Date().toISOString(), status: 'healthy' },
    google_analytics: { is_healthy: true, last_check_at: new Date().toISOString(), status: 'healthy' },
    slack: { is_healthy: false, last_check_at: new Date().toISOString(), status: 'error' }
  },
  
  clients: [
    { id: 1, name: 'Acme Corporation', industry: 'Technology', status: 'active', health_score: 85, communication_style: 'Direct and data-driven', emotional_trigger: 'Innovation and ROI' },
    { id: 2, name: 'TechStart Inc', industry: 'Software', status: 'active', health_score: 92, communication_style: 'Collaborative and agile', emotional_trigger: 'Speed to market' },
    { id: 3, name: 'Global Solutions Ltd', industry: 'Consulting', status: 'active', health_score: 78, communication_style: 'Formal and structured', emotional_trigger: 'Risk mitigation' },
    { id: 4, name: 'Enterprise Co', industry: 'Manufacturing', status: 'active', health_score: 88, communication_style: 'Results-oriented', emotional_trigger: 'Efficiency gains' },
    { id: 5, name: 'Innovation Labs', industry: 'Research', status: 'active', health_score: 95, communication_style: 'Exploratory and open', emotional_trigger: 'Cutting-edge technology' },
    { id: 6, name: 'Dynamic Corp', industry: 'Retail', status: 'active', health_score: 72, communication_style: 'Fast-paced', emotional_trigger: 'Customer satisfaction' },
    { id: 7, name: 'Beta Systems', industry: 'Finance', status: 'active', health_score: 81, communication_style: 'Analytical and cautious', emotional_trigger: 'Security and compliance' },
    { id: 8, name: 'Alpha Industries', industry: 'Healthcare', status: 'inactive', health_score: 65, communication_style: 'Regulatory-focused', emotional_trigger: 'Patient outcomes' }
  ],
  
  recommendations: [
    { id: 1, recommendation_type: 'follow_up', client_name: 'Acme Corporation', service_name: 'Send personalized proposal', confidence: 0.92, status: 'pending', created_at: new Date().toISOString() },
    { id: 2, recommendation_type: 'upsell', client_name: 'TechStart Inc', service_name: 'Premium support package', confidence: 0.88, status: 'pending', created_at: new Date(Date.now() - 3600000).toISOString() },
    { id: 3, recommendation_type: 'engagement', client_name: 'Global Solutions Ltd', service_name: 'Schedule quarterly review', confidence: 0.85, status: 'pending', created_at: new Date(Date.now() - 7200000).toISOString() },
    { id: 4, recommendation_type: 'retention', client_name: 'Enterprise Co', service_name: 'Offer renewal incentive', confidence: 0.91, status: 'pending', created_at: new Date(Date.now() - 10800000).toISOString() },
    { id: 5, recommendation_type: 'cross_sell', client_name: 'Innovation Labs', service_name: 'AI Analytics module', confidence: 0.87, status: 'pending', created_at: new Date(Date.now() - 14400000).toISOString() },
    { id: 6, recommendation_type: 'follow_up', client_name: 'Dynamic Corp', service_name: 'Post-demo consultation', confidence: 0.89, status: 'pending', created_at: new Date(Date.now() - 18000000).toISOString() }
  ],
  
  tasks: [
    { id: 1, title: 'Follow up with Acme Corp', description: 'Send personalized proposal after demo call', priority: 'high', status: 'pending', client_id: 1, assigned_to: 'Sales Team', due_date: new Date(Date.now() + 86400000).toISOString() },
    { id: 2, title: 'Schedule demo for TechStart', description: 'Product demonstration with technical team', priority: 'high', status: 'in_progress', client_id: 2, assigned_to: 'Product Team', due_date: new Date(Date.now() + 172800000).toISOString() },
    { id: 3, title: 'Contract review - Global Solutions', description: 'Legal review of updated terms', priority: 'medium', status: 'pending', client_id: 3, assigned_to: 'Legal Team', due_date: new Date(Date.now() + 259200000).toISOString() },
    { id: 4, title: 'Prepare Q1 business review', description: 'Compile metrics and insights for Enterprise Co', priority: 'medium', status: 'in_progress', client_id: 4, assigned_to: 'Account Manager', due_date: new Date(Date.now() + 345600000).toISOString() },
    { id: 5, title: 'Onboarding call - Innovation Labs', description: 'Walk through platform features', priority: 'high', status: 'pending', client_id: 5, assigned_to: 'Customer Success', due_date: new Date(Date.now() + 432000000).toISOString() },
    { id: 6, title: 'Send renewal proposal', description: 'Beta Systems contract renewal', priority: 'high', status: 'completed', client_id: 7, assigned_to: 'Sales Team', due_date: new Date(Date.now() - 86400000).toISOString() },
    { id: 7, title: 'Update case study', description: 'Dynamic Corp success story', priority: 'low', status: 'pending', client_id: 6, assigned_to: 'Marketing Team', due_date: new Date(Date.now() + 518400000).toISOString() },
    { id: 8, title: 'Technical support follow-up', description: 'Alpha Industries integration issues', priority: 'medium', status: 'in_progress', client_id: 8, assigned_to: 'Support Team', due_date: new Date(Date.now() + 604800000).toISOString() }
  ]
};

// Expose mock data to pages for dev-mode fallbacks
if (typeof window !== 'undefined' && isDevMode()) {
  window.__MOCK_DATA__ = MOCK_DATA;
}

// Global axios error interceptor
axios.interceptors.response.use(
  response => response,
  error => {
    if (error.response) {
      console.error(`API Error ${error.response.status}:`, error.response.data);
    } else if (error.request) {
      console.error('Network Error: No response received');
    } else {
      console.error('Request Error:', error.message);
    }
    return Promise.reject(error);
  }
);

// Error Boundary Component
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('React Error Boundary caught:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <Box sx={{ p: 3 }}>
          <Alert severity="error">
            <Typography variant="h6">Something went wrong</Typography>
            <Typography variant="body2">{this.state.error?.message}</Typography>
          </Alert>
        </Box>
      );
    }
    return this.props.children;
  }
}

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
    success: {
      main: '#4caf50',
    },
    warning: {
      main: '#ff9800',
    },
    error: {
      main: '#f44336',
    },
  },
});

const drawerWidth = 240;

// ============================================================================
// DASHBOARD COMPONENT
// ============================================================================

function DashboardView() {
  const navigate = useNavigate();
  const [stats, setStats] = useState({
    activeClients: 0,
    pendingTasks: 0,
    recommendations: 0,
    integrationHealth: {}
  });
  const [loading, setLoading] = useState(true);
  const [recentEvents, setRecentEvents] = useState([]);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const [allEventsOpen, setAllEventsOpen] = useState(false);
  const [allEvents, setAllEvents] = useState([]);
  const [eventsLoading, setEventsLoading] = useState(false);
  const [eventFilter, setEventFilter] = useState('all');
  
  // Event Detail Modal
  const [eventDetailOpen, setEventDetailOpen] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState(null);
  
  // Integration Detail Modal
  const [integrationDetailOpen, setIntegrationDetailOpen] = useState(false);
  const [selectedIntegration, setSelectedIntegration] = useState(null);

  useEffect(() => {
    loadDashboardData();
    
    // Set up WebSocket for real-time updates
    const socket = io(process.env.REACT_APP_WS_URL || 'http://localhost:5000', {
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionAttempts: 5
    });
    
    socket.on('connect', () => {
      console.log('WebSocket connected');
    });

    socket.on('connect_error', (error) => {
      console.warn('WebSocket connection error:', error.message);
    });
    
    socket.on('workflow_event', (event) => {
      setRecentEvents(prev => [event, ...prev.slice(0, 9)]);
    });

    socket.on('integration_status', (status) => {
      setStats(prev => ({
        ...prev,
        integrationHealth: status
      }));
    });

    return () => {
      socket.disconnect();
    };
  }, []);

  const loadDashboardData = async () => {
    try {
      // Try to load from API, fallback to mock data
      const [statsRes, eventsRes, healthRes, recommendationsRes] = await Promise.all([
        axios.get('/api/analytics/dashboard-stats').catch(err => {
          if (isDevMode()) {
            console.warn('🔧 Dev Mode: Using mock stats data');
            return { data: MOCK_DATA.stats };
          }
          throw err;
        }),
        axios.get('/api/analytics/recent-events?limit=10').catch(err => {
          if (isDevMode()) {
            console.warn('🔧 Dev Mode: Using mock events data');
            return { data: MOCK_DATA.events };
          }
          throw err;
        }),
        axios.get('/health/integrations').catch(err => {
          if (isDevMode()) {
            console.warn('🔧 Dev Mode: Using mock integration health data');
            return { data: MOCK_DATA.integrationHealth };
          }
          throw err;
        }),
        axios.get('/api/recommendations?status=pending').catch(err => {
          if (isDevMode()) {
            console.warn('🔧 Dev Mode: Using mock recommendations data');
            return { data: MOCK_DATA.recommendations.filter(r => r.status === 'pending') };
          }
          throw err;
        })
      ]);

      setStats({
        ...statsRes.data,
(Content truncated due to size limit. Use page ranges or line ranges to read remaining content)