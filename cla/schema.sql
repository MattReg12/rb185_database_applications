CREATE TABLE expenses (
  id SERIAL,
  amount NUMERIC(6,2) NOT NULL CHECK (amount > 0),
  memo TEXT,
  created_on DATE DEFAULT CURRENT_DATE);
