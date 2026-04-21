# Elqalam E-Commerce Database Schema

This document describes the Supabase database schema needed for the Elqalam e-commerce application.

## Tables Structure

### 1. profiles (User Profiles)
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 2. categories (Product Categories)
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 3. products (Products)
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_url TEXT,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  stock INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 4. cart_items (Shopping Cart)
```sql
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 5. orders (Orders)
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  items JSONB NOT NULL,
  total DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Setup Instructions

1. Go to your Supabase dashboard at https://app.supabase.com
2. Select your project (elqalam)
3. Go to the SQL Editor
4. Create each table using the SQL statements provided above
5. Enable Row Level Security (RLS) policies for security

## RLS Policies Example

### For profiles table:
```sql
-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON profiles
FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON profiles
FOR UPDATE USING (auth.uid() = id);
```

### For products table:
```sql
-- Anyone can view products
CREATE POLICY "Anyone can view products" ON products
FOR SELECT USING (true);
```

### For cart_items table:
```sql
-- Users can manage their own cart
CREATE POLICY "Users can manage own cart" ON cart_items
FOR ALL USING (auth.uid() = user_id);
```

### For orders table:
```sql
-- Users can view their own orders
CREATE POLICY "Users can view own orders" ON orders
FOR SELECT USING (auth.uid() = user_id);
```

## Sample Data

You can insert sample data using the Supabase dashboard or the following SQL:

```sql
-- Insert sample categories
INSERT INTO categories (name, image_url) VALUES
('أقلام', 'https://example.com/pens.jpg'),
('دفاتر', 'https://example.com/notebooks.jpg'),
('ورق', 'https://example.com/paper.jpg');

-- Insert sample products
INSERT INTO products (name, description, price, image_url, category_id, stock, is_available) VALUES
('قلم جاف أسود', 'قلم جاف عالي الجودة', 2.50, 'https://example.com/pen1.jpg', (SELECT id FROM categories WHERE name='أقلام'), 100, true),
('دفتر 100 ورقة', 'دفتر دراسة عملي', 5.00, 'https://example.com/notebook1.jpg', (SELECT id FROM categories WHERE name='دفاتر'), 50, true);
```
