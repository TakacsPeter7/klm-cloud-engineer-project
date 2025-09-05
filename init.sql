-- Create the notes table if it doesn't exist
CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create an index on created_at for better query performance
CREATE INDEX IF NOT EXISTS idx_notes_created_at ON notes(created_at);

-- Insert sample data
INSERT INTO notes (title, content) VALUES 
('Welcome Note', 'Welcome to the Note-Taking API! This is a sample note.'),
('Meeting Notes', 'Discussed project requirements and timeline for the cloud deployment.')
ON CONFLICT DO NOTHING;
