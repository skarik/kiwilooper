/// @description Clean up debug UI

if (ds_exists(uiListing, ds_type_list))
{
	for (var i = 0; i < ds_list_size(uiListing); ++i)
	{
		idelete(uiListing[|i]);
	}
	ds_list_destroy(uiListing);
}