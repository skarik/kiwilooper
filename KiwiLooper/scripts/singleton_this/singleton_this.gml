/// @function singleton_this()
/// @description Returns true if the calling script should abort
function singleton_this() {
	if (instance_number(object_index) > 1)
	{
		persistent = false;
	    idelete(this);
	    return true;
	}
	return false;



}
