-- Cleaning data Nashville housing

Select *
from [Nashville housing]

-- Standardize data format

Select SaleDate, convert(date,SaleDate)
from [Nashville housing]

update [Nashville housing]				-- not working in this case, usually should be
set SaleDate = CONVERT(date,SaleDate)

alter table [Nashville housing]
add SaleDateConverted Date;

update [Nashville housing]
set SaleDateConverted = CONVERT(date,SaleDate)

Select SaleDateConverted, SaleDate, convert(date,SaleDate)
from [Nashville housing]
 
 ------------------------------------
 -- Populate Property Adress data

Select *
from [Nashville housing]
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from [Nashville housing] a
join [Nashville housing] b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [Nashville housing] a
join [Nashville housing] b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

/* just checking
Select *
from [Nashville housing]
where PropertyAddress is null
*/

-----------------------------------

-- Breaking out Address into Individual Columns (Adress, City, State)

select PropertyAddress
from [Nashville housing]

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
from [Nashville housing]


alter table [Nashville housing]
add PropertySplitAddress Nvarchar(255);

update [Nashville housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table [Nashville housing]
add PropertySplitCity Nvarchar(255);

update [Nashville housing]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

select *
from [Nashville housing]


--------------- Property Owner Address --------------

select OwnerAddress
from [Nashville housing]

select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from [Nashville housing]


alter table [Nashville housing]
add OwnerSplitAdress Nvarchar(255);

update [Nashville housing]
set OwnerSplitAdress = PARSENAME(Replace(OwnerAddress,',','.'),3)

alter table [Nashville housing]
add OwnerSplitCity Nvarchar(255);

update [Nashville housing]
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table [Nashville housing]
add PropertySplitState Nvarchar(255);

update [Nashville housing]
set PropertySplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
from [Nashville housing]

---------------- Change Y and N to Yes and No in 'Sold as Vacant' field ----------

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [Nashville housing]
group by SoldAsVacant
order by 2


update [Nashville housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


-----------------------------------------------------------
--------- Remove Duplicates -------------
WITH RowNumCTE AS(
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID 
					) row_num

from [Nashville housing]
-- order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress

select * 
from [Nashville housing]


-------------------------------------------------------------
---------- Delete Unused Columns --------------------------

select *
from [Nashville housing]

alter table [Nashville housing]
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table [Nashville housing]
drop column SaleDate






