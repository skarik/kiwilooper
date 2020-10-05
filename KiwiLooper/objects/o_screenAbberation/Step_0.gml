// Abberate at 60 FPS
var shakeRate = 1/60;
shakeTimer += Time.dt;
if (shakeTimer > shakeRate)
{
    shakeTimer = min(shakeRate, shakeTimer - shakeRate);

    // Create screenshake
    //var dir = random_range(0,360);
    var len = magnitude;//random_range(0,magnitude);
    // Fade shake over time if wanted
    if ( fade ) len *= life/maxlife;
    // Set actual shake
    //Screen.offset_x = lengthdir_x( len,dir );
    //Screen.offset_y = lengthdir_y( len,dir );
	strength = len;
}

// Decrement over lifetime
life -= Time.dt;
if ( life < 0 )
{
    // Reset offset   
    //Screen.offset_x = 0;
    //Screen.offset_y = 0;
    
    // Delete self
    idelete(this);
}

