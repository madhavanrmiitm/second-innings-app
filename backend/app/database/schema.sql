-- Drop tables in reverse dependency order to avoid foreign key conflicts
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS interest_groups CASCADE;
DROP TABLE IF EXISTS care_requests CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS relations CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- User ID Mapping for Story Characters:
-- ID 1: Ashwin Narayanan S (admin)
-- ID 2: Nakshatra Gupta (admin)
-- ID 3: Asha (senior_citizen) - 80-year-old Indian woman with kind eyes, short grey hair, glasses
-- ID 4: Rohan (family_member) - 45-year-old professional Indian man, Asha's son
-- ID 5: Priya (caregiver) - 28-year-old Indian woman with warm smile, long dark hair in ponytail
-- ID 6: Mr. Verma (interest_group_admin) - 70-year-old retired Indian gentleman with white mustache
-- ID 7: Test Caregiver Two (caregiver) - Additional caregiver for variety
-- ID 8: Test Family Member Two (family_member) - Additional family member
-- ID 9: Test Senior Citizen Two (senior_citizen) - Additional senior citizen
-- ID 10: Test Group Admin Two (interest_group_admin) - Additional group admin
-- ID 11: Test Support User One (support_user) - Support specialist
-- ID 12: Test Support User Two (support_user) - Customer service representative

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
CREATE TYPE ticket_status AS ENUM ('open', 'in_progress', 'closed');

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
VALUES ('nakshatra.nsb@gmail.com', '4N2P7ZAWGPgXXoQmp2YAKXJTw253', 'Nakshatra Gupta', 'admin', 'active');



-- Insert test mode users (2 per role)
-- Admin users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('asha.senior@example.com', 'story_asha_uid_001', 'Asha', 'senior_citizen', 'active', '1945-03-15', '80-year-old Indian woman with kind eyes, short grey hair, and glasses. Enjoys gardening and staying active.', 'senior,indian,gardening,active');

-- Rohan - Family Member (ID 4) - Asha's son
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('rohan.family@example.com', 'story_rohan_uid_001', 'Rohan', 'family_member', 'active', '1980-08-22', '45-year-old professional Indian man with short black hair and grey streaks at temples. Caring son managing his mother Asha''s care.', 'family,professional,caring,indian');

-- Priya - Caregiver (ID 5)
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('priya.caregiver@example.com', 'story_priya_uid_001', 'Priya', 'caregiver', 'active', 'https://www.youtube.com/watch?v=priya_intro', '1997-11-08', '28-year-old Indian woman with warm smile and long dark hair in ponytail. Specializes in physiotherapy and companionship.', 'caregiver,physiotherapy,companionship,indian');

-- Mr. Verma - Interest Group Admin (ID 6)
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('verma.groupadmin@example.com', 'story_verma_uid_001', 'Mr. Verma', 'interest_group_admin', 'active', 'https://www.youtube.com/watch?v=verma_intro', '1955-06-10', '70-year-old retired Indian gentleman with cheerful demeanor, neat white mustache, and glasses. Community leader organizing activities for seniors.', 'group-admin,retired,community,indian');

-- Additional test users for variety
-- Test Caregiver Two
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('caregiver2@test.com', 'test_caregiver_uid_002', 'Test Caregiver Two', 'caregiver', 'pending_approval', 'https://www.youtube.com/watch?v=test2', '1990-08-25', 'Certified nurse with 5 years of experience in home care', 'caregiver,nurse,home-care');

-- Test Family Member Two
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('family2@test.com', 'test_family_uid_002', 'Test Family Member Two', 'family_member', 'active', '1988-04-18', 'Devoted child managing care for senior citizen', 'family,devoted');

-- Test Senior Citizen Two
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('senior2@test.com', 'test_senior_uid_002', 'Test Senior Citizen Two', 'senior_citizen', 'active', '1950-09-30', 'Former engineer with passion for gardening', 'senior,engineer,gardening');

-- Test Group Admin Two
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, youtube_url, date_of_birth, description, tags)
VALUES ('groupadmin2@test.com', 'test_groupadmin_uid_002', 'Test Group Admin Two', 'interest_group_admin', 'pending_approval', 'https://www.youtube.com/watch?v=testgroup2', '1972-11-08', 'Art therapist creating engaging programs for elderly', 'group-admin,art-therapy,programs');

-- Support users
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('support1@test.com', 'test_support_uid_001', 'Test Support User One', 'support_user', 'active', '1992-01-12', 'Support specialist helping users with platform issues', 'support,specialist');

INSERT INTO users (gmail_id, firebase_uid, full_name, role, status, date_of_birth, description, tags)
VALUES ('support2@test.com', 'test_support_uid_002', 'Test Support User Two', 'support_user', 'active', '1987-05-07', 'Customer service representative for platform support', 'support,customer-service');

CREATE TABLE relations (
    id SERIAL PRIMARY KEY,
    senior_citizen_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    family_member_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    senior_citizen_relation VARCHAR(255) NOT NULL,
    family_member_relation VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (senior_citizen_id, family_member_id)
);

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

CREATE TABLE care_requests (
    id SERIAL PRIMARY KEY,
    senior_citizen_id INTEGER REFERENCES users(id) ON DELETE CASCADE, -- Can be NULL for direct caregiver requests by family members
    caregiver_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    made_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status care_request_status NOT NULL DEFAULT 'pending',
    timing_to_visit TIMESTAMP,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE interest_groups (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    whatsapp_link VARCHAR(500),
    category VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    timing TIMESTAMP,
    created_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_to INTEGER REFERENCES users(id) ON DELETE SET NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    priority notification_priority NOT NULL DEFAULT 'medium',  -- Added
    category VARCHAR(100),  -- Added
    status ticket_status NOT NULL DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Added
    resolved_at TIMESTAMP
);

CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    priority notification_priority NOT NULL DEFAULT 'medium',
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_tickets_category ON tickets(category);
CREATE INDEX idx_tickets_updated_at ON tickets(updated_at);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Insert story-based family relations
INSERT INTO relations (senior_citizen_id, family_member_id, senior_citizen_relation, family_member_relation) VALUES
(3, 4, 'Son', 'Mother'); -- Asha and Rohan

-- Insert story-based tasks
INSERT INTO tasks (title, description, time_of_completion, status, created_by, assigned_to) VALUES
('Morning Medicine Reminder', 'Remind Asha to take her blood pressure medication at 8 AM', '2025-01-20 08:00:00', 'completed', 4, 3),
('Afternoon Medicine Reminder', 'Remind Asha to take her afternoon medication', '2025-01-20 14:00:00', 'pending', 4, 3),
('Weekly Grocery Shopping', 'Help Asha with grocery shopping for weekly supplies', '2025-01-22 14:00:00', 'in_progress', 4, 3),
('Doctor Appointment', 'Accompany Asha to cardiologist appointment', '2025-01-25 10:00:00', 'pending', 4, 3),
('Home Safety Check', 'Inspect Asha''s home for safety hazards and make necessary adjustments', '2025-01-26 11:00:00', 'pending', 4, 3);

-- Insert story-based care requests
INSERT INTO care_requests (senior_citizen_id, caregiver_id, made_by, status, timing_to_visit, location) VALUES
(3, 5, 4, 'accepted', '2025-01-20 09:00:00', 'Asha''s Home, Mumbai'),
(3, 5, 4, 'pending', '2025-01-22 15:00:00', 'Asha''s Home, Mumbai');

-- Insert story-based interest groups (created by Mr. Verma)
INSERT INTO interest_groups (title, description, whatsapp_link, category, status, timing, created_by) VALUES
('Sunrise Walkers Club', 'Morning walking group for seniors in the neighborhood. Start your day with gentle exercise and friendly conversation.', 'https://chat.whatsapp.com/BQJVvF9M8B50Qj4xDf2a1z', 'Health', 'active', '2025-01-20 07:00:00', 6),
('Laughter Yoga Club', 'Weekly laughter yoga sessions to boost mood and health. No experience needed, just bring your smile!', 'https://chat.whatsapp.com/CRKWwG0N9C61Rk5yEg3b2A', 'Health', 'active', '2025-01-22 16:00:00', 6),
('Garden Lovers Community', 'Share gardening tips, plant care advice, and seasonal growing guides. Perfect for those with green thumbs or aspiring gardeners.', 'https://chat.whatsapp.com/DSLXxH1O0D72Sl6zFh4c3B', 'Hobby', 'active', '2025-01-25 10:00:00', 6),
('Digital Learning Circle', 'Learn to use smartphones, tablets, and the internet safely. Weekly sessions covering WhatsApp, video calls, and online banking.', 'https://chat.whatsapp.com/ETMYyI2P1E83Tm7aGi5d4C', 'Technology', 'active', '2025-01-27 15:00:00', 6),
('Book Club Enthusiasts', 'Monthly book discussions featuring classic literature and contemporary works. Share insights and make new friends through reading.', 'https://chat.whatsapp.com/FUNZzJ3Q2F94Un8bHj6e5D', 'Education', 'active', '2025-01-30 16:00:00', 6);

-- Insert story-based tickets
INSERT INTO tickets (user_id, assigned_to, subject, description, priority, category, status) VALUES
(4, 11, 'Question about payment', 'Need help understanding the payment structure for caregiver services', 'medium', 'Billing', 'open'),
(3, 11, 'App navigation help', 'Having trouble finding the local groups section in the app', 'low', 'Technical', 'open'),
(5, 12, 'Profile update request', 'Would like to add new skills to my caregiver profile', 'low', 'Profile', 'in_progress');

-- Insert story-based notifications
INSERT INTO notifications (user_id, type, priority, body, is_read) VALUES
(4, 'care_request', 'high', 'Your care request for Asha has been accepted by Priya', false),
(4, 'task', 'medium', 'New task assigned: Morning Medicine Reminder', true),
(4, 'interest_group', 'low', 'New member joined Sunrise Walkers Club', false),
(3, 'care_request', 'high', 'Care request accepted for tomorrow morning', true),
(3, 'task', 'medium', 'Task completed: Morning Medicine Reminder', true),
(3, 'interest_group', 'low', 'New walking group available in your area: Sunrise Walkers Club', false),
(5, 'care_request', 'high', 'New care request assigned to you for Asha', false),
(5, 'task', 'medium', 'Care request accepted: Morning visit to Asha''s home', true),
(6, 'interest_group', 'medium', 'New member joined your Sunrise Walkers Club group', false),
(6, 'interest_group', 'low', 'Activity reminder: Laughter Yoga session tomorrow', false);
