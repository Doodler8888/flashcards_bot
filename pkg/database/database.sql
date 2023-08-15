-- CREATE DATABASE flashcarddatabase;

-- \c mydatabase;

CREATE TABLE messages(
  id SERIAL PRIMARY KEY,
  text TEXT NOT NULL       --By using "NOT NULL" i expicitly tell that this column always going to have a value.
);

-- +-----------------+
-- |   mydatabase    |
-- +-----------------+
-- |                 |
-- |    messages     |
-- |  +-----+-----+  |
-- |  | id  |text |  |
-- |  +-----+-----+  |
-- |  |  1  | ... |  |
-- |  |  2  | ... |  |
-- |  | ... | ... |  |
-- |                 |
-- +-----------------+
