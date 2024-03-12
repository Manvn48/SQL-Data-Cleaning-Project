--Nashville Housing Data Cleaning Project using SQL

SELECT *
FROM PortfolioProject.dbo.Housing


--------------------------------------------------------------------------------------------------------------------

--Standardize Date Fromat
SELECT SaleDateConverted, Convert(Date, SaleDate)
FROM PortfolioProject.dbo.Housing

--Making Changes Applicable
ALTER TABLE PortfolioProject.dbo.Housing
ADD SaleDateConverted Date

UPDATE PortfolioProject.dbo.Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Sale Date converted - Like for instance from April 9, 2013 to standard 2013-04-09


--------------------------------------------------------------------------------------------------------------------
--Populate Property Address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Housing a
join PortfolioProject.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL 

UPDATE a    --a gentle reminder to myself -Use alias in cases like this
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Housing a
join PortfolioProject.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL




--------------------------------------------------------------------------------------------------------------------
-- Breaking out the Addresss into individual columns (Addresss, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.Housing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject.dbo.Housing

ALTER TABLE PortfolioProject.dbo.Housing
ADD StreetAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject.dbo.Housing
ADD City Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT StreetAddress, City
FROM PortfolioProject.dbo.Housing

SELECT * FROM PortfolioProject.dbo.Housing



SELECT OwnerAddress
FROM PortfolioProject.dbo.Housing

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.' ), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.' ), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.' ), 1)
FROM PortfolioProject.dbo.Housing 


ALTER TABLE PortfolioProject.dbo.Housing
ADD OwnerStreetAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',','.' ), 3)




ALTER TABLE PortfolioProject.dbo.Housing
ADD OwnerCity Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing
SET OwnerCity =  PARSENAME(REPLACE(OwnerAddress, ',','.' ), 2)


ALTER TABLE PortfolioProject.dbo.Housing
ADD OwnerState Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing
SET OwnerState  = PARSENAME(REPLACE(OwnerAddress, ',','.' ), 1)


SELECT *
FROM PortfolioProject.dbo.Housing
Order by ParcelID

--------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold a s Vacant " field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant) as CountNumber
FROM PortfolioProject.dbo.Housing 
GROUP BY  SoldAsVacant
ORDER BY 2


--Before Updation

--SoldAsVacant-- | --CountNumber--
     --Yes		 |      xyz
	 --No 		 |      xyz
	 --Y  		 |      xyz
	 --N  		 |      xyz


--After Updation

--SoldAsVacant-- | --CountNumber--
     --Yes		 |      abc
	 --No 		 |      abc

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'	
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.Housing

UPDATE PortfolioProject.dbo.Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'	
	 ELSE SoldAsVacant
	 END


--------------------------------------------------------------------------------------------------------------------
	--Remove Duplicates
WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) row_num

	FROM PortfolioProject.dbo.Housing
	--ORDER BY ParcelID
     )
/*
DELETE 
FROM RowNumCTE
WHERE row_num > 1
*/
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

SELECT * 
FROM PortfolioProject.dbo.Housing


ALTER TABLE PortfolioProject.dbo.Housing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress





