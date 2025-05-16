/*
  # Initial Schema Setup for E-commerce Platform

  1. New Tables
    - users
      - id (uuid, primary key) - Maps to Supabase auth.users
      - email (text)
      - name (text)
      - image_url (text)
      - created_at (timestamptz)
      - is_seller (boolean)
    
    - products
      - id (uuid, primary key)
      - user_id (uuid, foreign key)
      - name (text)
      - description (text)
      - price (decimal)
      - offer_price (decimal)
      - category (text)
      - images (text[])
      - created_at (timestamptz)
    
    - addresses
      - id (uuid, primary key)
      - user_id (uuid, foreign key)
      - full_name (text)
      - phone_number (text)
      - pincode (text)
      - area (text)
      - city (text)
      - state (text)
      - created_at (timestamptz)
    
    - orders
      - id (uuid, primary key)
      - user_id (uuid, foreign key)
      - address_id (uuid, foreign key)
      - amount (decimal)
      - status (text)
      - created_at (timestamptz)
    
    - order_items
      - id (uuid, primary key)
      - order_id (uuid, foreign key)
      - product_id (uuid, foreign key)
      - quantity (integer)
      - price (decimal)
      - created_at (timestamptz)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
*/

-- Create users table
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT auth.uid(),
  email text UNIQUE NOT NULL,
  name text,
  image_url text,
  is_seller boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create products table
CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  price decimal NOT NULL,
  offer_price decimal NOT NULL,
  category text NOT NULL,
  images text[] NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create addresses table
CREATE TABLE addresses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  phone_number text NOT NULL,
  pincode text NOT NULL,
  area text NOT NULL,
  city text NOT NULL,
  state text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create orders table
CREATE TABLE orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  address_id uuid REFERENCES addresses(id) ON DELETE CASCADE,
  amount decimal NOT NULL,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- Create order_items table
CREATE TABLE order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE CASCADE,
  quantity integer NOT NULL,
  price decimal NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can read their own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Anyone can view products" ON products
  FOR SELECT USING (true);

CREATE POLICY "Sellers can manage their products" ON products
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their addresses" ON addresses
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view their orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );