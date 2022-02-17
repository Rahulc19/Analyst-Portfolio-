--Cleaning Data in SQL Queries

SELECT * FROM housing


-- Standardize Date Format from date w/ timestamp to date w/o timestamp

ALTER TABLE housing
ALTER COLUMN saledate
SET DATA TYPE date


-- Populate property address data using INNER JOIN to fill in NULL values knowing parecelid corresponds with property address

SELECT * FROM housing
--WHERE propertyaddress IS NULL
ORDER BY parcelid


SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress) 
FROM housing a
JOIN housing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL

UPDATE housing as a
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM housing AS b
WHERE a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
AND a.propertyaddress IS NULL


-- Breaking out Address into Individual columns (address, city, state)

SELECT SUBSTRING(propertyaddress from 1 for position(',' IN propertyaddress)-1) as address,
SUBSTRING(propertyaddress from position(',' IN propertyaddress) +1 for LENGTH(propertyaddress))
FROM housing

-- Now adding the address and city back into the table as seperate columns

ALTER TABLE housing
ADD COLUMN PropertySplitAddress VARCHAR(255)

UPDATE housing
SET PropertySplitAddress = SUBSTRING(propertyaddress from 1 for position(',' IN propertyaddress)-1)

ALTER TABLE housing
ADD COLUMN PropertySplitCity VARCHAR(255)

UPDATE housing
SET PropertySplitCity = SUBSTRING(propertyaddress from position(',' IN propertyaddress) +1 for LENGTH(propertyaddress))

-- Now performing splits on the 'OwnerAddress' Column with SPLIT_PART instead of substrings and adding corresponding columns to housing table.

SELECT OwnerAddress
FROM housing

SELECT 
SPLIT_PART(owneraddress,',',1),
SPLIT_PART(owneraddress,',',2),
SPLIT_PART(owneraddress,',',3)
FROM housing


-- Adding back into table
ALTER TABLE housing
ADD COLUMN OwnerSplitAddress VARCHAR(255)

UPDATE housing
SET OwnerSplitAddress = SPLIT_PART(owneraddress,',',1)

ALTER TABLE housing
ADD COLUMN OwnerSplitCity VARCHAR(255)

UPDATE housing
SET OwnerSplitCity = SPLIT_PART(owneraddress,',',2)

ALTER TABLE housing
ADD COLUMN OwnerSplitState VARCHAR(255)

UPDATE housing
SET OwnerSplitState = SPLIT_PART(owneraddress,',',3)


-- CHANGE Yes to No for the "Sold as Vacant" field using CASES.

SELECT DISTINCT(soldasvacant),COUNT(soldasvacant)
FROM housing
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant, 
CASE
WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END
FROM housing


UPDATE housing
SET soldasvacant = CASE
WHEN soldasvacant = 'Y' THEN 'Yes'
WHEN soldasvacant = 'N' THEN 'No'
ELSE soldasvacant
END

-- Removing Duplicates

WITH RowNumCTE(parcelid,propertyaddress,saleprice,saledate,legalreference) AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY parcelid,propertyaddress,saleprice,saledate,legalreference ORDER BY uniqueid) row_num
FROM housing)

DELETE FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY propertyaddress
	
	
-- Delete Unused Columns

ALTER TABLE housing
DROP COLUMN saledate,
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress
