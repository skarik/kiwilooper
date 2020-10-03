/// @description Choose longest non-intro track as leader.

// Grab current selected master track
var l_longest_index = null;
var l_longest_length = -0.0;
if (m_trackMasterId != null)
{
	var l_longest_index = m_trackMasterId;
	var l_longest_length = faudioSourceGetSoundLength(m_track[m_trackMasterId]);
	
	// If leading track is an intro, mark missing track:
	if (m_trackIntroToLoop[m_trackMasterId] != null)
	{
		l_longest_index = null;
		l_longest_length = -0.0;
	}
}

for (var i = 0; i < m_trackCount; ++i)
{
	// Skip current longest
	if (i == m_trackMasterId) continue;
	// Skip intro tracks
	if (m_trackIntroToLoop[i] != null) continue;
	
	var l_length = faudioSourceGetSoundLength(m_track[i]);
	if (l_length > l_longest_length)
	{
		l_longest_index = i;
		l_longest_length = l_length;
	}
}

// Set leading track to match properly.
m_trackMasterId = l_longest_index;