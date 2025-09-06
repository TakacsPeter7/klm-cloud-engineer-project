CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notes_created_at ON notes(created_at);

INSERT INTO notes (title, content) VALUES 
('Welcome Note', 'Welcome to the Note-Taking API! This is a sample note.'),
('Meeting Notes', 'Example Note 1-2-3')
ON CONFLICT DO NOTHING;
