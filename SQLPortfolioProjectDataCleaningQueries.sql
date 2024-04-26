/*

Data Cleaning with SQL queries

*/

SELECT * FROM
PortfolioProject.dbo.NashvilleHousing

-- Changing Date Format --


Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 


-- ALTERNATE WAY (without changing orignal coloumn)

ALTER TABLE NashvilleHousing
Add SaleDateOnly Date;

UPDATE NashvilleHousing
SET SaleDateOnly = CONVERT(Date, SaleDate)

SELECT SaleDateOnly
FROM PortfolioProject.dbo.NashvilleHousing


-- Populate Property Address Data --

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a JOIN
PortfolioProject.dbo.NashvilleHousing b ON 
a.ParcelID = b.ParcelID AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b 
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING (PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1) AS Address, 
SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress) ) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add  PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress) ) 

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Spliting Owner city, state and Address from OwnerAddress (Column)

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3), --Replace works in reverse (321)
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add  OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing -- Checking query result

-- Change Y and N to Yes and No -- 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 


SELECT SoldAsVacant, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE  SoldAsVacant 
	END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant  = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE  SoldAsVacant 
	END

-- Removing Duplicates Values --
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER( 
	PARTITION BY ParcelId,
                 PropertyAddress,
   				 SalePrice,
				 SaleDate,
				 LegalReference							 
                 ORDER BY UniqueID
				 )row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *     -- Change 'SELECT *' with 'DELETE' to remove these duplicate rows.
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns --


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, Taxdistrict, PropertyAddress, SaleDate




