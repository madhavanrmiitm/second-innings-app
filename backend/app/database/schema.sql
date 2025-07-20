-- Drop tables if they exist to ensure a clean slate.
DROP TABLE IF EXISTS users, relations, tasks, care_requests, tags, user_tags, interest_groups, tickets, notifications CASCADE;

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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default admin account
INSERT INTO users (gmail_id, firebase_uid, full_name, role, status)
VALUES ('21f3001600@ds.study.iitm.ac.in', 'qEGg9NTOjfgSaw646IhSRCXKtaZ2', 'Ashwin Narayanan S', 'admin', 'active');

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
    assigned_to INTEGER REFERENCES users(id) ON DELETE CASCADE,
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

CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    status BOOLEAN DEFAULT TRUE,
    category VARCHAR(255)
);

CREATE TABLE user_tags (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    UNIQUE (user_id, tag_id)
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
    assigned_to INTEGER REFERENCES users(id) ON DELETE CASCADE,
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

