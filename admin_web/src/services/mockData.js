export const mockUsers = [
  {
    id: 1,
    name: 'Sakshi Patel',
    email: 'admin@2ndinnings.com',
    role: 'admin',
    profileImage: 'https://ui-avatars.com/api/?name=Sakshi+Patel',
    department: 'Administration',
    phone: '+91 98765 43210',
    bio: 'System administrator with full access',
    createdAt: '2023-01-01T00:00:00Z'
  }
]

export const mockOfficials = [
  {
    id: 1,
    name: 'Ramesh Kumar',
    email: 'ramesh.kumar@2ndinnings.com',
    role: 'Caregiver',
    department: 'Home Care',
    status: 'Active',
    joinedDate: '2023-04-12',
    phone: '+91 98765 43211',
    address: 'Mumbai, Maharashtra',
    createdAt: '2023-04-12T00:00:00Z'
  },
  {
    id: 2,
    name: 'Meena Patel',
    email: 'meena.patel@2ndinnings.com',
    role: 'Family Member',
    department: 'Family Support',
    status: 'Active',
    joinedDate: '2023-05-08',
    phone: '+91 98765 43212',
    address: 'Kolkata, West Bengal',
    createdAt: '2023-05-08T00:00:00Z'
  },
  {
    id: 3,
    name: 'Sunita Das',
    email: 'sunita.das@2ndinnings.com',
    role: 'Interest Group Admin',
    department: 'Activity Coordination',
    status: 'Active',
    joinedDate: '2023-06-10',
    phone: '+91 98765 43213',
    address: 'New Delhi, Delhi',
    createdAt: '2023-06-10T00:00:00Z'
  },
  {
    id: 4,
    name: 'Ajay Singh',
    email: 'ajay.singh@2ndinnings.com',
    role: 'Caregiver',
    department: 'Respite Care',
    status: 'Inactive',
    joinedDate: '2023-07-01',
    phone: '+91 98765 43214',
    address: 'Chennai, Tamil Nadu',
    createdAt: '2023-07-01T00:00:00Z'
  },
  {
    id: 5,
    name: 'Priya Sharma',
    email: 'priya.sharma@2ndinnings.com',
    role: 'Caregiver',
    department: 'Medical Assistance',
    status: 'Active',
    joinedDate: '2023-08-15',
    phone: '+91 98765 43215',
    address: 'Bengaluru, Karnataka',
    createdAt: '2023-08-15T00:00:00Z'
  }
]

export const mockTickets = [
  {
    id: 'TICK-001',
    title: 'Missed Medication Reminder',
    description: 'Morning medication reminder did not go through',
    status: 'Open',
    priority: 'High',
    assignedTo: 'Ramesh Kumar',
    createdBy: 'Sunita Das',
    createdAt: '2024-03-01T07:30:00Z',
    updatedAt: '2024-03-01T07:30:00Z',
    category: 'Medication',
    tags: ['medication', 'reminder']
  },
  {
    id: 'TICK-002',
    title: 'Appointment Scheduling Issue',
    description: 'Unable to schedule doctor appointment via the portal',
    status: 'In Progress',
    priority: 'Medium',
    assignedTo: 'Meena Patel',
    createdBy: 'Ramesh Kumar',
    createdAt: '2024-03-02T10:20:00Z',
    updatedAt: '2024-03-03T09:15:00Z',
    category: 'Appointment',
    tags: ['appointment', 'scheduling']
  },
  {
    id: 'TICK-003',
    title: 'New Activity Group Creation',
    description: 'Request to create a new yoga group for seniors',
    status: 'Open',
    priority: 'High',
    assignedTo: 'Sunita Das',
    createdBy: 'Priya Sharma',
    createdAt: '2024-03-03T16:45:00Z',
    updatedAt: '2024-03-03T16:45:00Z',
    category: 'Activity',
    tags: ['group', 'creation', 'yoga']
  },
  {
    id: 'TICK-004',
    title: 'Calendar Not Showing Events',
    description: 'Senior events calendar is not loading upcoming sessions',
    status: 'Closed',
    priority: 'Low',
    assignedTo: 'Ramesh Kumar',
    createdBy: 'Meena Patel',
    createdAt: '2024-02-28T11:00:00Z',
    updatedAt: '2024-03-01T15:30:00Z',
    category: 'Events',
    tags: ['calendar', 'events']
  },
  {
    id: 'TICK-005',
    title: 'Subscription Payment Error',
    description: 'Error encountered while paying monthly subscription',
    status: 'In Progress',
    priority: 'High',
    assignedTo: 'Priya Sharma',
    createdBy: 'Sunita Das',
    createdAt: '2024-03-04T09:20:00Z',
    updatedAt: '2024-03-04T10:00:00Z',
    category: 'Payment',
    tags: ['payment', 'subscription', 'error']
  }
]

export const mockNotifications = [
  {
    id: 1,
    title: 'Medication Reminder',
    message: 'Time to take your morning medications',
    read: false,
    timestamp: '2024-03-04T07:00:00Z',
    type: 'reminder',
    priority: 'high'
  },
  {
    id: 2,
    title: 'Caregiver Assigned',
    message: 'Ramesh Kumar has been assigned as a caregiver',
    read: false,
    timestamp: '2024-03-04T09:15:00Z',
    type: 'user',
    userId: 1
  },
  {
    id: 3,
    title: 'System Maintenance',
    message: 'System maintenance scheduled for tomorrow at 2:00 AM IST',
    read: true,
    timestamp: '2024-03-03T18:00:00Z',
    type: 'system',
    priority: 'medium'
  },
  {
    id: 4,
    title: 'Appointment Confirmed',
    message: 'A doctor appointment has been confirmed for 2024-03-10 at 10:00 AM',
    read: true,
    timestamp: '2024-03-05T10:30:00Z',
    type: 'appointment'
  },
  {
    id: 5,
    title: 'Welcome!',
    message: 'Welcome to the 2nd Innings senior care panel',
    read: true,
    timestamp: '2024-03-01T08:00:00Z',
    type: 'system'
  }
]

export const mockGroups = [
  {
    id: 1,
    name: 'Morning Yoga for Seniors',
    description: 'Gentle yoga sessions to improve flexibility and balance',
    category: 'health',
    members: 30,
    events: 60,
    admin: 'Sunita Das',
    adminId: 3,
    active: true,
    createdAt: '2023-06-15T00:00:00Z',
    location: 'Central Park, New Delhi'
  },
  {
    id: 2,
    name: 'Senior Book Discussion',
    description: 'Monthly meetups to discuss favourite books and share insights',
    category: 'literature',
    members: 25,
    events: 12,
    admin: 'Priya Sharma',
    adminId: 5,
    active: true,
    createdAt: '2023-07-20T00:00:00Z',
    location: 'Community Hall, Pune'
  },
  {
    id: 3,
    name: 'Silver Tech Workshops',
    description: 'Hands-on sessions to learn smartphone and internet use',
    category: 'tech',
    members: 40,
    events: 24,
    admin: 'Ajay Singh',
    adminId: 4,
    active: false,
    createdAt: '2023-08-10T00:00:00Z',
    location: 'Online'
  }
]
