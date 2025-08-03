-- Drop tables in reverse dependency order to avoid foreign key conflicts
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
    senior_citizen_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
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
    links VARCHAR(500),
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
    status ticket_status NOT NULL DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
