/// @description Perform synchronization

#macro kSynchroFitLeeway 0.02
#macro kSynchroResyncLeeway 0.07

if (m_trackMasterId == null)
	exit; // Skip if no synchro track.

// Intro synchro:
if (m_trackIntroToLoop[m_trackMasterId] != null)
{
	// Grab time & length with intro:
	var current_lead_time_intro = faudioSourceGetPlaybackTime(m_track[m_trackMasterId]);
	var current_lead_length_intro = faudioSourceGetSoundLength(m_track[m_trackMasterId]);
	
	// Grab time & length of the looped variant (we subtract length of intro)
	var current_lead_length = faudioSourceGetSoundLength(m_track[m_trackIntroToLoop[m_trackMasterId]]);
	var intro_length = current_lead_length_intro - current_lead_length;
	var current_lead_time = current_lead_time_intro - intro_length;
	
	if (intro_length < 0.0)
	{
		debugLog(kLogWarning, "Intro length is smaller than looped variant. Issues here.");
		m_trackMasterId = null; // Skip this shit.
		exit;
	}
	
	if (current_lead_time > 0.0)
	{
		// Perform the normal synchro based on the wierd timing:
		for (var i = 0; i < m_trackCount; ++i)
		{
			// Skip setting the master track in charge of sync
			if (i == m_trackMasterId) continue;
			// Skip syncing intro tracks
			if (m_trackIntroToLoop[i] != null) continue;
			
			var track_position = faudioSourceGetPlaybackTime(m_track[i]);
			var track_length = faudioSourceGetSoundLength(m_track[i]);
			
			// Check if it's a perfect fit
			if ((current_lead_length % track_length) < kSynchroFitLeeway)
			{
				var new_track_position = current_lead_time % track_length;
			
				// Sync if too far
				if (abs(track_position - new_track_position) > kSynchroResyncLeeway)
				{
					faudioSourceSetPlaybackTime(m_track[i], new_track_position);
				}
			}
			// Not a perfect fit. Need to do more complicated maths to sync.
			else
			{
				debugLog(kLogWarning, "Intro sync: Imperfect sync currently unsupported.");
			}
		}
	}
	
	// Near end of intro, automatically shift to the looped.
	if (current_lead_time_intro > current_lead_length_intro * 0.9)
	{
		// Shift the volumes around:
		m_trackVolume[m_trackIntroToLoop[m_trackMasterId]] = m_trackVolume[m_trackMasterId];
		m_trackVolume[m_trackMasterId] = 0.0;
		
		// Move to the looped version as master
		m_trackMasterId = m_trackIntroToLoop[m_trackMasterId];
		
		// Mark intro as ended
		m_introEnded = true;
	}
}
// Normal synchro:
else
{
	var current_lead_time = faudioSourceGetPlaybackTime(m_track[m_trackMasterId]);
	var current_lead_length = faudioSourceGetSoundLength(m_track[m_trackMasterId]);
	for (var i = 0; i < m_trackCount; ++i)
	{
		// Skip setting the master track in charge of sync
		if (i == m_trackMasterId) continue;
		// Skip syncing intro tracks
		if (m_trackIntroToLoop[i] != null) continue;
			
		var track_position = faudioSourceGetPlaybackTime(m_track[i]);
		var track_length = faudioSourceGetSoundLength(m_track[i]);
			
		// Check if it's a perfect fit
		if ((current_lead_length % track_length) < kSynchroFitLeeway)
		{
			var new_track_position = current_lead_time % track_length;
			
			// Sync if too far
			if (abs(track_position - new_track_position) > kSynchroResyncLeeway)
			{
				faudioSourceSetPlaybackTime(m_track[i], new_track_position);
			}
		}
		// Not a perfect fit. Need to do more complicated maths to sync.
		else
		{
			debugLog(kLogWarning, "Normal sync: Imperfect sync currently unsupported.");
		}
	}
	
	// Clear intro flag
	m_introEnded = false;
}