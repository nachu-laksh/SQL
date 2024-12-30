-
CREATE DATABASE KitchenPantryInventory;
USE KitchenPantryInventory;

-- Create Tables

-- Storage Locations Table
CREATE TABLE StorageLocations (
    LocationID INT AUTO_INCREMENT PRIMARY KEY,
    LocationName VARCHAR(100) NOT NULL, -- e.g., "Refrigerator", "Pantry Shelf A"
    TemperatureZone ENUM('Ambient', 'Chilled', 'Frozen') NOT NULL
);

-- Categories Table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL -- e.g., "Vegetables", "Dairy", "Spices"
);

-- Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL -- e.g., "Whole Foods", "Trader Joe's", "Giant Eagle"
);

-- Products Table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT,
    SupplierID INT,
    Unit VARCHAR(20) NOT NULL, -- e.g., "kg", "liters", "packets"
    UnitPrice DECIMAL(10, 2),
    QuantityInStock DECIMAL(10, 2) DEFAULT 0,
    StorageLocationID INT,
    ExpirationDate DATE,
    CaloriesPerUnit DECIMAL(10, 2), -- Calories per unit
    ProteinPerUnit DECIMAL(10, 2), -- Protein in grams
    FatPerUnit DECIMAL(10, 2), -- Fat in grams
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (StorageLocationID) REFERENCES StorageLocations(LocationID)
);

-- Inventory Transactions Table
CREATE TABLE InventoryTransactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    TransactionType ENUM('IN', 'OUT') NOT NULL, -- 'IN' for stock addition, 'OUT' for stock removal
    Quantity DECIMAL(10, 2) NOT NULL,
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Reason TEXT, -- Reason for transaction (Used in what recipe)
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Recipes Table
CREATE TABLE Recipes (
    RecipeID INT AUTO_INCREMENT PRIMARY KEY,
    RecipeName VARCHAR(100) NOT NULL,
    Instructions TEXT,
    EstimatedPrepTime INT -- In minutes
);

-- Ingredients Table
CREATE TABLE RecipeIngredients (
    RecipeIngredientID INT AUTO_INCREMENT PRIMARY KEY,
    RecipeID INT,
    ProductID INT,
    QuantityNeeded DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Inserting Data

-- Insert Storage Locations
INSERT INTO StorageLocations (LocationName, TemperatureZone)
VALUES
    ('Refrigerator', 'Chilled'),
    ('Freezer', 'Frozen'),
    ('Pantry Shelf A', 'Ambient'),
    ('Pantry Shelf B', 'Ambient');

-- Insert Categories
INSERT INTO Categories (CategoryName)
VALUES
    ('Vegetables'), ('Dairy'), ('Spices'), ('Meat'), ('Grains');

-- Insert Suppliers
INSERT INTO Suppliers (SupplierName)
VALUES
    ('Whole Foods'), ('Trader Joe\'s'), ('Giant Eagle');

-- Insert Products
INSERT INTO Products (ProductName, CategoryID, SupplierID, Unit, UnitPrice, QuantityInStock, StorageLocationID, ExpirationDate, CaloriesPerUnit, ProteinPerUnit, FatPerUnit)
VALUES
    ('Tomatoes', 1, 1, 'kg', 2.50, 20, 3, '2024-01-15', 18, 0.9, 0.2),
    ('Milk', 2, 2, 'liters', 1.50, 10, 1, '2024-01-05', 42, 3.4, 1.0),
    ('Butter', 2, 3, 'packs', 3.00, 5, 1, '2024-03-01', 717, 0.9, 81);

-- Insert Recipes
INSERT INTO Recipes (RecipeName, Instructions, EstimatedPrepTime)
VALUES
    ('Tomato Soup', 'Blend tomatoes, add spices, and simmer.', 30);

-- Insert Recipe Ingredients
INSERT INTO RecipeIngredients (RecipeID, ProductID, QuantityNeeded)
VALUES
    (1, 1, 1.5); -- 1.5 kg of Tomatoes for Tomato Soup

-- Step 4: Queries

-- 1. View Current Inventory with Nutrition Values
SELECT 
    p.ProductName,
    c.CategoryName,
    p.QuantityInStock,
    p.Unit,
    l.LocationName,
    p.CaloriesPerUnit,
    p.ProteinPerUnit,
    p.FatPerUnit,
    p.ExpirationDate
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN StorageLocations l ON p.StorageLocationID = l.LocationID;

-- 2. Identify Most Used Ingredients (based on 'OUT' transactions)
SELECT 
    p.ProductName,
    SUM(t.Quantity) AS TotalUsed
FROM InventoryTransactions t
JOIN Products p ON t.ProductID = p.ProductID
WHERE t.TransactionType = 'OUT'
GROUP BY p.ProductName
ORDER BY TotalUsed DESC;

-- 3. Identify Least Used Ingredients (based on 'OUT' transactions)
SELECT 
    p.ProductName,
    SUM(t.Quantity) AS TotalUsed
FROM InventoryTransactions t
JOIN Products p ON t.ProductID = p.ProductID
WHERE t.TransactionType = 'OUT'
GROUP BY p.ProductName
ORDER BY TotalUsed ASC;

-- 4. View Expiring Products
SELECT 
    ProductName,
    ExpirationDate,
    QuantityInStock
FROM Products
WHERE ExpirationDate < CURDATE() + INTERVAL 7 DAY;

-- 5. Record a Transaction
INSERT INTO InventoryTransactions (ProductID, TransactionType, Quantity, Reason)
VALUES
    (2, 'OUT', 2, 'Used during breakfast');
