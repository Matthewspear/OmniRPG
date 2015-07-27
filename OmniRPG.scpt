set todayDate to current date
set yesterdayDate to todayDate - (1 * days)

set dateToday to date (short date string of (todayDate))
set dateYesterday to date (short date string of (yesterdayDate))

-- API Keys Go Here!
set API_USER to ""
set API_KEY to ""

-- set selection dialog option (true shows choice, false does not)
set selectionDialog to true

-- set day option (true is today, false is yesterday)
set countToday to true

if selectionDialog is true then
	
	-- Print number of tasks completed today
	tell application "OmniFocus"
		display dialog "Which day would you like to count?" buttons {"Yesterday", "Today"} default button 2
	end tell
	
	if button returned of result is "Yesterday" then
		
		set countToday to false
		
	else if button returned of result is "Today" then
		
		set countToday to true
		
	end if
	
end if
-- run main script
tell application "OmniFocus"
	tell default document
		
		if countToday is true then
			
			set refDoneToday to a reference to (flattened tasks where (completion date ≥ dateToday))
			
		else
			
			set refDoneToday to a reference to (flattened tasks where (completion date ≥ dateYesterday and completion date < dateToday))
			
		end if
		
		set {lstName, lstContext, lstProject, lstNote} to {name, name of its context, name of its containing project, note} of refDoneToday
		
		-- total number of tasks completed
		set n to count of refDoneToday
		
		set low to 0
		set medium to 0
		set high to 0
		
		repeat with iTask from 1 to count of lstName
			set {strName, varContext, varProject, varNote} to {item iTask of lstName, item iTask of lstContext, item iTask of lstProject, item iTask of lstNote}
			
			if varNote contains "LOW" or varContext is "C priority" or varContext is "Low" or varContext is "C" then
				set low to low + 1
			end if
			
			if varNote contains "MEDIUM" or varContext is "B priority" or varContext is "Medium" or varContext is "B" then
				set medium to medium + 1
			end if
			
			if varNote contains "HIGH" or varContext is "A priority" or varContext is "High" or varContext is "A" then
				set high to high + 1
			end if
			
		end repeat
		
		-- tasks that are undefined counted as LOW
		set other to n - low - medium - high
		
	end tell
end tell

try
	-- Print number of tasks completed today
	tell application "OmniFocus"
		if countToday is true then
			
			
			display dialog "Tasks completed today: " & n & "
		Low: " & low + other & "
		Medium: " & medium & "
		High: " & high
			
		else if countToday is false then
			
			display dialog "Tasks completed yesterday: " & n & "
		Low: " & low + other & "
		Medium: " & medium & "
		High: " & high
			
		end if
		
	end tell
	
	if button returned of result is "OK" then
		
		-- scripts to trigger HabitRPG
		
		set lowScript to "curl -X POST --compressed -H 'Content-Type:application/json' -H 'x-api-user:" & API_USER & "' -H 'x-api-key:" & API_KEY & "' https://habitrpg.com:443/api/v2/user/tasks/low/up"
		
		set mediumScript to "curl -X POST --compressed -H 'Content-Type:application/json' -H 'x-api-user:" & API_USER & "' -H 'x-api-key:" & API_KEY & "' https://habitrpg.com:443/api/v2/user/tasks/medium/up"
		
		set highScript to "curl -X POST --compressed -H 'Content-Type:application/json' -H 'x-api-user:" & API_USER & "' -H 'x-api-key:" & API_KEY & "' https://habitrpg.com:443/api/v2/user/tasks/high/up"
		
		
		-- repeat scripts per number of completed tasks in each difficulty
		
		repeat low + other times
			do shell script lowScript
		end repeat
		
		repeat medium times
			do shell script mediumScript
		end repeat
		
		repeat high times
			do shell script highScript
		end repeat
		
	end if
	
	-- TODO: write to log
	
on error number -128
	
	-- do nothing
	
end try
