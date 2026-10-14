-- =====================================================================
-- Structured Query Language 101  ·  Texas Linux Festival 2026
-- Every example and exercise answer from the slides, in order.
-- Database: DBeaver Sample Database (SQLite), created with Help > Create Sample Database (Chinook 1.3).
-- Run one statement: Ctrl+Enter (Cmd+Enter on macOS). Whole script: Alt+X.
-- =====================================================================

SELECT 'Hello, Texas!' AS greeting;

-- ---------- Part 2 · SELECT ----------
SELECT * FROM Employee;
SELECT FirstName, LastName, Title FROM Employee;
SELECT FirstName || ' ' || LastName AS FullName, Email FROM Customer LIMIT 3;
SELECT Name, Milliseconds / 1000 AS Seconds FROM Track;
SELECT DISTINCT Country FROM Customer ORDER BY Country;
SELECT COUNT(DISTINCT Country) FROM Customer;                 -- 24
SELECT Name, Milliseconds FROM Track ORDER BY Milliseconds DESC LIMIT 3;
SELECT LastName, FirstName, Country FROM Customer ORDER BY Country, LastName;
SELECT Name FROM Track ORDER BY Name LIMIT 10 OFFSET 10;

-- Exercise 1
SELECT FirstName, LastName, HireDate FROM Employee;            -- 8 rows
SELECT DISTINCT BillingCity FROM Invoice ORDER BY BillingCity; -- 53 rows
SELECT Name, Milliseconds FROM Track ORDER BY Milliseconds LIMIT 5;

-- ---------- Part 3 · WHERE ----------
SELECT FirstName, LastName, Country FROM Customer WHERE Country = 'USA';   -- 13
SELECT FirstName, Country, Company FROM Customer
WHERE Country = 'Brazil' OR Country = 'Canada' AND Company IS NOT NULL;    -- 7 (surprise)
SELECT FirstName, Country, Company FROM Customer
WHERE (Country = 'Brazil' OR Country = 'Canada') AND Company IS NOT NULL;  -- 6
SELECT FirstName, LastName, Country FROM Customer
WHERE Country IN ('Canada', 'Brazil', 'France');                          -- 18
SELECT Name, Milliseconds FROM Track
WHERE Milliseconds BETWEEN 300000 AND 360000;                             -- 446
SELECT Name FROM Track WHERE Name LIKE '%love%';                          -- 114
SELECT Name FROM Track WHERE Name LIKE 'Love%';                           -- 27
SELECT FirstName FROM Customer WHERE FirstName LIKE '_ack';               -- Jack
SELECT FirstName, LastName FROM Customer WHERE Company IS NULL;           -- 49
SELECT FirstName, LastName FROM Customer WHERE Company = NULL;            -- 0 (never matches)

-- Exercise 2
SELECT FirstName, LastName, City FROM Customer WHERE Country = 'Germany'; -- 4
SELECT COUNT(*) FROM Track WHERE Milliseconds > 300000;                   -- 1069
SELECT COUNT(*) FROM Track WHERE Composer IS NULL;                        -- 978

-- ---------- Part 4 · INSERT, UPDATE, DELETE ----------
-- Tip: switch DBeaver to manual-commit mode first.
INSERT INTO Genre (Name) VALUES ('Texas Swing');
SELECT * FROM Genre ORDER BY GenreId DESC LIMIT 3;
UPDATE Genre SET Name = 'Western Swing' WHERE Name = 'Texas Swing';
SELECT * FROM Genre WHERE Name = 'Western Swing';
DELETE FROM Genre WHERE Name = 'Western Swing';

-- Exercise 3
INSERT INTO Customer (FirstName, LastName, Email, Country, SupportRepId)
VALUES ('Tux', 'Penguin', 'tux@example.com', 'USA', 3);
UPDATE Customer SET SupportRepId = 4 WHERE Email = 'tux@example.com';
SELECT * FROM Customer WHERE Email = 'tux@example.com';
DELETE FROM Customer WHERE Email = 'tux@example.com';

-- ---------- Part 5 · Built-in functions ----------
SELECT UPPER(LastName) AS Upper, LOWER(Email) AS Email,
       LENGTH(LastName) AS Len, SUBSTR(Phone, 1, 3) AS Prefix
FROM Customer LIMIT 3;
SELECT Name, ROUND(Milliseconds / 60000.0, 2) AS Minutes
FROM Track ORDER BY Minutes DESC LIMIT 3;
SELECT 7 / 2, 7 / 2.0, ROUND(3.14159, 2), ABS(-5);
SELECT InvoiceDate, DATE(InvoiceDate) AS Day, strftime('%Y', InvoiceDate) AS Yr
FROM Invoice LIMIT 3;
SELECT DATE('now');
SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM Invoice;
SELECT FirstName, COALESCE(Company, '(none)') AS Company FROM Customer;
SELECT Name,
  CASE
    WHEN Milliseconds < 180000 THEN 'short'
    WHEN Milliseconds < 360000 THEN 'medium'
    ELSE 'long'
  END AS Size
FROM Track;

-- Exercise 4
SELECT UPPER(LastName) || ', ' || FirstName AS Name FROM Employee ORDER BY LastName;
SELECT Name, ROUND(Bytes / 1048576.0, 1) AS MB FROM Track ORDER BY Bytes DESC;
SELECT FirstName, LastName, strftime('%Y', HireDate) AS Yr FROM Employee;

-- ---------- Part 6 · Grouping and aggregates ----------
SELECT COUNT(*) AS Invoices, SUM(Total) AS Revenue, ROUND(AVG(Total), 2) AS AvgSale,
       MIN(Total) AS Smallest, MAX(Total) AS Largest
FROM Invoice;
SELECT COUNT(Company) FROM Customer;                                       -- 10, not 59
SELECT Country, COUNT(*) AS Customers FROM Customer
GROUP BY Country ORDER BY Customers DESC;
SELECT Country, City, COUNT(*) FROM Customer GROUP BY Country, City;
SELECT Country, COUNT(*) AS Customers FROM Customer
GROUP BY Country HAVING COUNT(*) >= 5;
SELECT strftime('%Y', InvoiceDate) AS Yr, COUNT(*) AS Invoices, ROUND(SUM(Total), 2) AS Sales
FROM Invoice GROUP BY Yr ORDER BY Yr;

-- Exercise 5
SELECT MediaTypeId, COUNT(*) AS Tracks FROM Track GROUP BY MediaTypeId;
SELECT BillingCountry, ROUND(SUM(Total), 2) AS Sales FROM Invoice
GROUP BY BillingCountry ORDER BY Sales DESC LIMIT 5;
SELECT Country, COUNT(*) AS Customers FROM Customer
GROUP BY Country HAVING COUNT(*) > 3;

-- ---------- Part 7 · JOINs ----------
SELECT a.Title, ar.Name
FROM Album a
INNER JOIN Artist ar ON a.ArtistId = ar.ArtistId
WHERE ar.Name = 'AC/DC';
SELECT ar.Name
FROM Artist ar
LEFT JOIN Album al ON ar.ArtistId = al.ArtistId
WHERE al.AlbumId IS NULL;                                                  -- 71
SELECT g.Name AS Genre, COUNT(*) AS Tracks
FROM Track t JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name ORDER BY Tracks DESC LIMIT 5;
SELECT ar.Name AS Artist, ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Sales
FROM Artist ar
JOIN Album al       ON ar.ArtistId = al.ArtistId
JOIN Track t        ON al.AlbumId  = t.AlbumId
JOIN InvoiceLine il ON t.TrackId   = il.TrackId
GROUP BY ar.Name ORDER BY Sales DESC LIMIT 5;

-- Exercise 6
SELECT c.FirstName, c.LastName, e.FirstName AS Rep
FROM Customer c JOIN Employee e ON c.SupportRepId = e.EmployeeId;
SELECT e.FirstName, e.LastName, COUNT(*) AS Customers
FROM Customer c JOIN Employee e ON c.SupportRepId = e.EmployeeId
GROUP BY e.EmployeeId;
SELECT g.Name, SUM(il.Quantity) AS Sold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name ORDER BY Sold DESC LIMIT 5;

-- ---------- Capstone ----------
SELECT c.FirstName || ' ' || c.LastName AS Customer,
       c.Country,
       ROUND(SUM(i.Total), 2) AS Spent,
       e.FirstName AS Rep
FROM Customer c
JOIN Invoice  i ON c.CustomerId   = i.CustomerId
JOIN Employee e ON c.SupportRepId = e.EmployeeId
GROUP BY c.CustomerId
HAVING SUM(i.Total) > 40
ORDER BY Spent DESC
LIMIT 5;
