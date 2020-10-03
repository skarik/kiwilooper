with (Debug)
{
	if (recordModeEnabled)
	{
		gpu_set_blendenable(true);
		gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha);
	
		with (GameCamera)
		{
			var kGifUpscale = 2.0;
			//var kGifWidth = 560; //Screen.width / Screen.pixelScale;
			//var kGifHeight = 560; //Screen.height / Screen.pixelScale; 
			
			var kGifWidth = Debug.gifWidth;//Screen.width / Screen.pixelScale;
			var kGifHeight = Debug.gifHeight;//Screen.height / Screen.pixelScale; 
		
			draw_set_color(c_lime);
			draw_rectangle(
				view_x + width * 0.5 - (kGifWidth/kGifUpscale * 0.5) - 4,
				view_y + height * 0.5  - (kGifHeight/kGifUpscale * 0.5) - 4,
				view_x + width * 0.5 + (kGifWidth/kGifUpscale * 0.5) + 4,
				view_y + height * 0.5 + (kGifHeight/kGifUpscale * 0.5) + 4,
				true);
		}
	}
}