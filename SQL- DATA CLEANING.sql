
--DATA CLEANING IN SQL


SELECT * FROM MyPortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------

--Standardizing Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted,CONVERT(Date, SaleDate) 
FROM MyPortfolioProject.dbo.NashvilleHousing 

-----------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MyPortfolioProject.dbo.NashvilleHousing a
JOIN MyPortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MyPortfolioProject.dbo.NashvilleHousing a
JOIN MyPortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM MyPortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)
,PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)
FROM MyPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)

SELECT * FROM MyPortfolioProject.dbo.NashvilleHousing


SELECT OwnerAddress
FROM MyPortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM MyPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT * FROM MyPortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldasVacant" Column

SELECT DISTINCT(SoldAsVacant) FROM MyPortfolioProject.dbo.NashvilleHousing


SELECT SoldAsVacant
,CASE
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END
FROM MyPortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END
FROM MyPortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM MYPortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


SELECT * FROM MyPortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------------

--Delete Unused Columns

SELECT * FROM MyPortfolioProject.dbo.NashvilleHousing


ALTER TABLE MyPortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
