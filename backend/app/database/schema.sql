-- Drop tables in reverse dependency order to avoid foreign key conflicts
DROP TABLE IF EXISTS reminders CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS interest_groups CASCADE;
DROP TABLE IF EXISTS care_requests CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS relations CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create ENUM type for user roles
DROP TYPE IF EXISTS user_role CASCADE;
CREATE TYPE user_role AS ENUM ('admin', 'caregiver', 'family_member', 'senior_citizen', 'interest_group_admin', 'support_user');

-- Create ENUM type for user status
DROP TYPE IF EXISTS user_status CASCADE;
CREATE TYPE user_status AS ENUM ('pending_approval', 'active', 'blocked');

-- Create ENUM type for task status
DROP TYPE IF EXISTS task_status CASCADE;
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- Create ENUM type for care request status
DROP TYPE IF EXISTS care_request_status CASCADE;
CREATE TYPE care_request_status AS ENUM ('pending', 'accepted', 'rejected', 'cancelled');

-- Create ENUM type for ticket status
DROP TYPE IF EXISTS ticket_status CASCADE;
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'resolved', 'closed');

-- Create ENUM type for notification type
DROP TYPE IF EXISTS notification_type CASCADE;
CREATE TYPE notification_type AS ENUM ('task', 'care_request', 'relation', 'interest_group', 'support_ticket');

-- Create ENUM type for notification priority
DROP TYPE IF EXISTS notification_priority CASCADE;
CREATE TYPE notification_priority AS ENUM ('low', 'medium', 'high');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    gmail_id VARCHAR(255) UNIQUE NOT NULL,
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    status user_status NOT NULL DEFAULT 'active',
    youtube_url VARCHAR(500),
    date_of_birth DATE,
    description TEXT,
    tags VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default admin accounts
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status)
VALUES ('21f3001600@ds.study.iitm.ac.in', 'qEGg9NTOjfgSaw646IhSRCXKtaZ2', 'Ashwin Narayanan S', 'admin', 'active');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status)
VALUES ('nakshatra.nsb@gmail.com', '4N2P7ZAWGPgXXoQmp2YAKXJTw253', ' Nakshatra Gupta', 'admin', 'active');

-- Insert test mode users (2 per role)
-- Admin users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('admin1@test.com', 'test_admin_uid_001', 'Test Admin One', 'admin', 'active', '1970-01-15', 'Test admin user for development', 'admin,test');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('admin2@test.com', 'test_admin_uid_002', 'Test Admin Two', 'admin', 'active', '1975-03-20', 'Second test admin user for development', 'admin,test');

-- Caregiver users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('caregiver1@test.com', 'test_caregiver_uid_001', 'Test Caregiver One', 'caregiver', 'active', 'https://www.youtube.com/watch?v=test1', '1985-06-10', 'Experienced caregiver specializing in elderly care', 'caregiver,elderly,compassionate');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('caregiver2@test.com', 'test_caregiver_uid_002', 'Test Caregiver Two', 'caregiver', 'pending_approval', 'https://www.youtube.com/watch?v=test2', '1990-08-25', 'Certified nurse with 5 years of experience in home care', 'caregiver,nurse,home-care');

-- Family member users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('family1@test.com', 'test_family_uid_001', 'Test Family Member One', 'family_member', 'active', '1980-12-05', 'Caring family member looking after elderly parent', 'family,caring');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('family2@test.com', 'test_family_uid_002', 'Test Family Member Two', 'family_member', 'active', '1988-04-18', 'Devoted child managing care for senior citizen', 'family,devoted');

-- Senior citizen users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('senior1@test.com', 'test_senior_uid_001', 'Test Senior Citizen One', 'senior_citizen', 'active', '1945-02-14', 'Retired teacher enjoying second innings of life', 'senior,retired,teacher');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('senior2@test.com', 'test_senior_uid_002', 'Test Senior Citizen Two', 'senior_citizen', 'active', '1950-09-30', 'Former engineer with passion for gardening', 'senior,engineer,gardening');

-- Interest group admin users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('groupadmin1@test.com', 'test_groupadmin_uid_001', 'Test Group Admin One', 'interest_group_admin', 'active', 'https://www.youtube.com/watch?v=testgroup1', '1965-07-22', 'Community leader organizing activities for seniors', 'group-admin,community,activities');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('groupadmin2@test.com', 'test_groupadmin_uid_002', 'Test Group Admin Two', 'interest_group_admin', 'pending_approval', 'https://www.youtube.com/watch?v=testgroup2', '1972-11-08', 'Art therapist creating engaging programs for elderly', 'group-admin,art-therapy,programs');

-- Support user users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('support1@test.com', 'test_support_uid_001', 'Test Support User One', 'support_user', 'active', '1992-01-12', 'Support specialist helping users with platform issues', 'support,specialist');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('support2@test.com', 'test_support_uid_002', 'Test Support User Two', 'support_user', 'active', '1987-05-07', 'Customer service representative for platform support', 'support,customer-service');

-- Additional test users for comprehensive testing
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('caregiver3@test.com', 'test_caregiver_uid_003', 'Test Caregiver Three', 'caregiver', 'blocked', 'https://www.youtube.com/watch?v=test3', '1982-03-15', 'Blocked caregiver for testing', 'caregiver,blocked');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('family3@test.com', 'test_family_uid_003', 'Test Family Member Three', 'family_member', 'blocked', '1985-07-22', 'Blocked family member for testing', 'family,blocked');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('senior3@test.com', 'test_senior_uid_003', 'Test Senior Citizen Three', 'senior_citizen', 'pending_approval', '1948-11-08', 'Senior citizen pending approval', 'senior,pending');

CREATE TABLE relations (
    id SERIAL PRIMARY KEY,
    senior_citizen_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    family_member_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    senior_citizen_relation VARCHAR(255) NOT NULL,
    family_member_relation VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (senior_citizen_id, family_member_id)
);

-- Insert test relations data
-- Relation between senior1 and family1
INSERT INTO relations (senior_citizen_id, family_member_id, senior_citizen_relation, family_member_relation)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    'Father',
    'Son';

-- Relation between senior2 and family2
INSERT INTO relations (senior_citizen_id, family_member_id, senior_citizen_relation, family_member_relation)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'family2@test.com'),
    'Mother',
    'Daughter';

CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    time_of_completion TIMESTAMP,
    status task_status NOT NULL DEFAULT 'pending',
    created_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_to INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test tasks data with different statuses
-- Pending task
INSERT INTO tasks (title, description, status, created_by, assigned_to)
SELECT
    'Morning Medication Reminder',
    'Remind senior citizen to take morning medications at 8:00 AM',
    'pending',
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver1@test.com');

-- In progress task
INSERT INTO tasks (title, description, status, created_by, assigned_to)
SELECT
    'Physical Therapy Session',
    'Assist with daily physical therapy exercises',
    'in_progress',
    (SELECT id FROM users WHERE gmail_id = 'family2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver2@test.com');

-- Completed task
INSERT INTO tasks (title, description, status, created_by, assigned_to, time_of_completion)
SELECT
    'Evening Walk',
    'Accompany senior citizen for evening walk in the park',
    'completed',
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver1@test.com'),
    CURRENT_TIMESTAMP - INTERVAL '2 hours';

-- Cancelled task
INSERT INTO tasks (title, description, status, created_by, assigned_to)
SELECT
    'Doctor Appointment',
    'Accompany to doctor appointment (cancelled due to weather)',
    'cancelled',
    (SELECT id FROM users WHERE gmail_id = 'family2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver2@test.com');

-- Task without assignment
INSERT INTO tasks (title, description, status, created_by)
SELECT
    'Grocery Shopping',
    'Help with grocery shopping for the week',
    'pending',
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com');

CREATE TABLE care_requests (
    id SERIAL PRIMARY KEY,
    senior_citizen_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    caregiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    made_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status care_request_status NOT NULL DEFAULT 'pending',
    timing_to_visit TIMESTAMP,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test care requests data with different statuses
-- Pending care request
INSERT INTO care_requests (senior_citizen_id, caregiver_id, made_by, status, timing_to_visit, location)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    'pending',
    CURRENT_TIMESTAMP + INTERVAL '2 days',
    '123 Main Street, Apartment 4B, Chennai';

-- Accepted care request
INSERT INTO care_requests (senior_citizen_id, caregiver_id, made_by, status, timing_to_visit, location)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'family2@test.com'),
    'accepted',
    CURRENT_TIMESTAMP + INTERVAL '1 day',
    '456 Oak Avenue, House 12, Chennai';

-- Rejected care request
INSERT INTO care_requests (senior_citizen_id, caregiver_id, made_by, status, timing_to_visit, location)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    'rejected',
    CURRENT_TIMESTAMP + INTERVAL '3 days',
    '789 Pine Road, Flat 8, Chennai';

-- Cancelled care request
INSERT INTO care_requests (senior_citizen_id, caregiver_id, made_by, status, timing_to_visit, location)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'caregiver1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'family2@test.com'),
    'cancelled',
    CURRENT_TIMESTAMP + INTERVAL '5 days',
    '321 Elm Street, Unit 15, Chennai';

CREATE TABLE interest_groups (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    links VARCHAR(500),
    status VARCHAR(50) DEFAULT 'active',
    timing TIMESTAMP,
    created_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test interest groups data
-- Active interest group
INSERT INTO interest_groups (title, description, links, status, timing, created_by)
SELECT
    'Senior Yoga & Meditation',
    'Weekly yoga and meditation sessions for senior citizens to improve flexibility and mental well-being',
    'https://zoom.us/j/123456789, https://www.youtube.com/watch?v=yoga_seniors',
    'active',
    CURRENT_TIMESTAMP + INTERVAL '3 days',
    (SELECT id FROM users WHERE gmail_id = 'groupadmin1@test.com');

-- Active interest group with different timing
INSERT INTO interest_groups (title, description, links, status, timing, created_by)
SELECT
    'Gardening Club for Seniors',
    'Monthly gardening sessions where seniors can share tips and grow plants together',
    'https://meet.google.com/garden-seniors, https://www.youtube.com/watch?v=senior_gardening',
    'active',
    CURRENT_TIMESTAMP + INTERVAL '1 week',
    (SELECT id FROM users WHERE gmail_id = 'groupadmin2@test.com');

-- Inactive interest group
INSERT INTO interest_groups (title, description, links, status, timing, created_by)
SELECT
    'Book Reading Club',
    'Monthly book discussions for senior citizens (currently inactive)',
    'https://discord.gg/bookclub, https://www.youtube.com/watch?v=book_reviews',
    'inactive',
    CURRENT_TIMESTAMP + INTERVAL '2 weeks',
    (SELECT id FROM users WHERE gmail_id = 'groupadmin1@test.com');

-- Interest group without timing
INSERT INTO interest_groups (title, description, links, status, created_by)
SELECT
    'Technology Support Group',
    'Helping seniors learn and use modern technology devices and applications',
    'https://teams.microsoft.com/tech-support, https://www.youtube.com/watch?v=tech_tutorials',
    'active',
    (SELECT id FROM users WHERE gmail_id = 'groupadmin2@test.com');

CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_to INTEGER REFERENCES users(id) ON DELETE SET NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    status ticket_status NOT NULL DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Insert test tickets data with different statuses
-- Open ticket without assignment
INSERT INTO tickets (user_id, subject, description, status)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior1@test.com'),
    'App Login Issue',
    'Unable to login to the application. Getting error message when trying to access my profile.',
    'open';

-- Open ticket with assignment
INSERT INTO tickets (user_id, assigned_to, subject, description, status)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'support1@test.com'),
    'Care Request Not Working',
    'When trying to create a care request, the form keeps showing validation errors.',
    'open';

-- In progress ticket
INSERT INTO tickets (user_id, assigned_to, subject, description, status)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'caregiver1@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'support2@test.com'),
    'Profile Update Problem',
    'Cannot update my profile information. The save button is not working properly.',
    'in_progress';

-- Resolved ticket
INSERT INTO tickets (user_id, assigned_to, subject, description, status, resolved_at)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'support1@test.com'),
    'Notification Settings',
    'Need help configuring notification preferences for the application.',
    'resolved',
    CURRENT_TIMESTAMP - INTERVAL '1 day';

-- Closed ticket
INSERT INTO tickets (user_id, assigned_to, subject, description, status, resolved_at)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'family2@test.com'),
    (SELECT id FROM users WHERE gmail_id = 'support2@test.com'),
    'Payment Issue Resolved',
    'Payment gateway integration was not working properly. Issue has been resolved.',
    'closed',
    CURRENT_TIMESTAMP - INTERVAL '3 days';

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    priority notification_priority NOT NULL DEFAULT 'medium',
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reminders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    reminder_time TIMESTAMP NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    snooze_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test notifications data with different types and priorities
-- Unread high priority task notification
INSERT INTO notifications (user_id, type, priority, body, is_read)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'caregiver1@test.com'),
    'task',
    'high',
    'New task assigned: Morning medication reminder for Senior Citizen One',
    FALSE;

-- Read medium priority care request notification
INSERT INTO notifications (user_id, type, priority, body, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    'care_request',
    'medium',
    'Care request for Senior Citizen One has been accepted by Test Caregiver One',
    TRUE,
    CURRENT_TIMESTAMP - INTERVAL '1 hour';

-- Unread low priority interest group notification
INSERT INTO notifications (user_id, type, priority, body, is_read)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior1@test.com'),
    'interest_group',
    'low',
    'New interest group created: Senior Yoga & Meditation. Join now!',
    FALSE;

-- Unread high priority support ticket notification
INSERT INTO notifications (user_id, type, priority, body, is_read)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'support1@test.com'),
    'support_ticket',
    'high',
    'New support ticket assigned: App Login Issue from Senior Citizen One',
    FALSE;

-- Read medium priority relation notification
INSERT INTO notifications (user_id, type, priority, body, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'family2@test.com'),
    'relation',
    'medium',
    'Family member relation request approved for Senior Citizen Two',
    TRUE,
    CURRENT_TIMESTAMP - INTERVAL '2 hours';

-- Unread medium priority task notification
INSERT INTO notifications (user_id, type, priority, body, is_read)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'caregiver2@test.com'),
    'task',
    'medium',
    'Task completed: Physical Therapy Session for Senior Citizen Two',
    FALSE;

-- Read low priority interest group notification
INSERT INTO notifications (user_id, type, priority, body, is_read, created_at)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior2@test.com'),
    'interest_group',
    'low',
    'Reminder: Gardening Club meeting tomorrow at 3 PM',
    TRUE,
    CURRENT_TIMESTAMP - INTERVAL '6 hours';

-- Unread high priority care request notification
INSERT INTO notifications (user_id, type, priority, body, is_read)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'caregiver1@test.com'),
    'care_request',
    'high',
    'New care request from Family Member One for Senior Citizen One',
    FALSE;

-- Insert test reminders data
-- Active reminder
INSERT INTO reminders (user_id, title, description, reminder_time, status)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior1@test.com'),
    'Morning Medication',
    'Take blood pressure medication at 8:00 AM',
    CURRENT_TIMESTAMP + INTERVAL '2 hours',
    'active';

-- Snoozed reminder
INSERT INTO reminders (user_id, title, description, reminder_time, status, snooze_count)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'senior2@test.com'),
    'Evening Walk',
    'Go for evening walk in the park',
    CURRENT_TIMESTAMP + INTERVAL '30 minutes',
    'snoozed',
    2;

-- Completed reminder
INSERT INTO reminders (user_id, title, description, reminder_time, status)
SELECT
    (SELECT id FROM users WHERE gmail_id = 'family1@test.com'),
    'Doctor Appointment',
    'Accompany senior to doctor appointment',
    CURRENT_TIMESTAMP - INTERVAL '1 day',
    'completed';

-- Create indexes for better query performance and referential integrity
CREATE INDEX idx_users_gmail_id ON users(gmail_id);
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

CREATE INDEX idx_relations_senior_citizen_id ON relations(senior_citizen_id);
CREATE INDEX idx_relations_family_member_id ON relations(family_member_id);

CREATE INDEX idx_tasks_created_by ON tasks(created_by);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_status ON tasks(status);

CREATE INDEX idx_care_requests_senior_citizen_id ON care_requests(senior_citizen_id);
CREATE INDEX idx_care_requests_caregiver_id ON care_requests(caregiver_id);
CREATE INDEX idx_care_requests_made_by ON care_requests(made_by);
CREATE INDEX idx_care_requests_status ON care_requests(status);

CREATE INDEX idx_interest_groups_created_by ON interest_groups(created_by);
CREATE INDEX idx_interest_groups_status ON interest_groups(status);

CREATE INDEX idx_tickets_user_id ON tickets(user_id);
CREATE INDEX idx_tickets_assigned_to ON tickets(assigned_to);
CREATE INDEX idx_tickets_status ON tickets(status);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

CREATE INDEX idx_reminders_user_id ON reminders(user_id);
CREATE INDEX idx_reminders_status ON reminders(status);
CREATE INDEX idx_reminders_reminder_time ON reminders(reminder_time);
