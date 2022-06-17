/*
Cleaning Data in SQL
*/

-- Specificy the name of the Database to be used
use PortfolioProject;

-- To view all the dataset stored in the table
SELECT * FROM dbo.Sheet1;

-- Standardize Date format
-- Add a new Coloumn
ALTER TABLE dbo.sheet1
ADD SaleDateConverted Date;

Update the SaleDateConverted with the data from SaleDate
UPDATE dbo.Sheet1 SET SaleDateConverted = CONVERT(date, SaleDate);


-- Populate missing Property Address data that has the same ParcelID with different UniqueID
-- Check to see if the correct values are picked
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM dbo.Sheet1 a
JOIN dbo.Sheet1 b
ON a.ParcelID = b.ParcelID
AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Now update the values picked in last query
UPDATE a 
SET PropertyAddress =
ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM dbo.Sheet1 a
JOIN dbo.Sheet1 b
ON a.ParcelID = b.ParcelID
AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


-- Breaking out Address into individual columns(Address, City, State)
SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) AS Address
from dbo.Sheet1;

ALTER TABLE dbo.sheet1
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE dbo.sheet1
ADD PropertySplitCity NVARCHAR(255);


--UPDATE dbo.Sheet1
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

UPDATE dbo.Sheet1
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress));

-- This is an alternative to the above string functions
-- uses . to split words
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.Sheet1;

ALTER TABLE dbo.sheet1
--ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE dbo.sheet1
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE dbo.sheet1
ADD OwnerSplitState NVARCHAR(255);


--UPDATE dbo.Sheet1
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE dbo.Sheet1
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE dbo.Sheet1
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);



-- change Y and N to Yes and No in "Sold as Vacant" field

-- Checking the number 
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
from dbo.Sheet1
GROUP BY SoldAsVacant;

---- To see prior to updating
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END	
from dbo.Sheet1;

UPDATE dbo.Sheet1 SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;


-- Remove Duplicates
with RowNumCTE as(
SELECT *,

ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
			PropertyAddress, 
			SalePrice, 
			SaleDate, 
			LegalReference
			ORDER BY UniqueID
			) row_num
FROM dbo.Sheet1
)
-- Get the data from cte
--select * 
--from RowNumCTE
--where row_num > 1
--order by row_num;

-- Delete duplicates that have come up in the table
DELETE FROM RowNumCTE
where row_num > 1;



-- Delete unused columns
ALTER TABLE dbo.sheet1
DROP COLUMN SaleDate,OwnerAddress, TaxDistrict, PropertyAddress;