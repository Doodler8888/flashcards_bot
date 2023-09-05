-- CREATE DATABASE flashcarddatabase;

-- \c mydatabase;

-- CREATE TYPE flashcard_category AS ENUM ('easy', 'medium', 'hard');

-- ALTER TABLE flashcards ADD COLUMN chat_id INT;

CREATE TABLE flashcards(
  id SERIAL PRIMARY KEY,
  question TEXT,
  answer TEXT,
  category flashcard_category
);

-- +-----------------+
-- |   mydatabase    |
-- +-----------------+
-- |                 |
-- |    messages     |
-- |  +-----+-----+  |
-- |  | id  |ques |  |
-- |  +-----+-----+  |
-- |  |  1  | ... |  |
-- |  |  2  | ... |  |
-- |  | ... | ... |  |
-- |                 |
-- +-----------------+



-- By using "NOT NULL" i expicitly tell that this column always going to have a value.
-- For example, this implicates that both fields must be populated at the time of row insertion.
-- So i wouldn't be able to use the /question and /answer commands separately.


-- CREATE TABLE active_questions (
--   chat_id INT,
--   question_id INT,
--   PRIMARY KEY (chat_id),
--   FOREIGN KEY (question_id) REFERENCES flashcards(id)
-- );

