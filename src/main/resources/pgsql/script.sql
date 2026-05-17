CREATE TABLE TBLROLE(
	ROLEID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	ROLENAME VARCHAR(20),
	ROLEDESC VARCHAR(100)
)

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- for register
CREATE TABLE tblusers (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20) UNIQUE,
    password_hash TEXT NOT NULL,
    profile_picture TEXT,
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_phone_verified BOOLEAN NOT NULL DEFAULT FALSE,

    failed_login_attempts INTEGER NOT NULL DEFAULT 0,
    locked_until TIMESTAMP,

    last_login_at TIMESTAMP,
    last_password_changed_at TIMESTAMP,

    deregister BOOLEAN NOT NULL DEFAULT FALSE,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by VARCHAR(100),

    CONSTRAINT chk_failed_login_attempts 
        CHECK (failed_login_attempts >= 0)
);

CREATE TABLE gbl_user_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    access_token TEXT,
    refresh_token TEXT,

    ip_address VARCHAR(45),
    user_agent TEXT,

    browser VARCHAR(100),
    device_name VARCHAR(150),
    operating_system VARCHAR(100),

    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,

    expires_at TIMESTAMP NOT NULL,
    last_activity_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_sessions_user
        FOREIGN KEY (user_id)
        REFERENCES tblusers(user_id)
        ON DELETE CASCADE
);

-- type 1 : sent to mail, 2: sent to phone
CREATE TABLE gbl_otp_codes (
    otp_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,
    otp_type_id INT NOT NULL,

    code VARCHAR(10) NOT NULL,

    target_email VARCHAR(255),
    target_phone VARCHAR(20),

    attempts INTEGER NOT NULL DEFAULT 0,
    max_attempts INTEGER NOT NULL DEFAULT 5,

    is_used BOOLEAN NOT NULL DEFAULT FALSE,

    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_otp_user
        FOREIGN KEY (user_id)
        REFERENCES tblusers(user_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_attempts
        CHECK (attempts >= 0 AND attempts <= max_attempts),

    CONSTRAINT chk_target
        CHECK (
            target_email IS NOT NULL OR target_phone IS NOT NULL
        )
);


CREATE TABLE gbl_notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    sender_user_id UUID,

    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,

    image_url TEXT,
    action_url TEXT,

    priority VARCHAR(20) NOT NULL DEFAULT 'normal',

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notifications_sender
        FOREIGN KEY (sender_user_id)
        REFERENCES tblusers(user_id)
        ON DELETE SET NULL,

    CONSTRAINT chk_notification_priority
        CHECK (
            priority IN ('low', 'normal', 'high', 'urgent')
        )
);

CREATE TABLE user_notifications (
    user_notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,
    notification_id UUID NOT NULL,

    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP,

    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    delivered_at TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_notifications_user
        FOREIGN KEY (user_id)
        REFERENCES tblusers(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_notifications_notification
        FOREIGN KEY (notification_id)
        REFERENCES gbl_notifications(notification_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_user_notification
        UNIQUE(user_id, notification_id)
);

CREATE TABLE password_reset_tokens (
    reset_token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    token_hash TEXT NOT NULL,

    is_used BOOLEAN NOT NULL DEFAULT FALSE,

    expires_at TIMESTAMP NOT NULL,
    used_at TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_password_reset_user
        FOREIGN KEY (user_id)
        REFERENCES tblusers(user_id)
        ON DELETE CASCADE
);

CREATE TABLE email_verification_tokens (
    verification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    token_hash TEXT NOT NULL,

    is_verified BOOLEAN NOT NULL DEFAULT FALSE,

    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_email_verification_user
        FOREIGN KEY (user_id)
        REFERENCES tblusers(user_id)
        ON DELETE CASCADE
);

