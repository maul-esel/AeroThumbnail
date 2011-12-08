/**************************************************************************************************************
title: Thumbnail class
wrapped by maul.esel

Credits:
	- skrommel for example how to show a thumbnail (http://www.autohotkey.com/forum/topic34318.html)
	- RaptorOne & IsNull for correcting some mistakes in the code
	- Lexikos for AutoHotkey_L / AutoHotkey 2 with class syntax

NOTE:
*This requires Windows Vista or Windows7 and the latest AutoHotkey build* (tested on Windows 7)

Quick-Tutorial:
To add a thumbnail to a gui, you must know the following:
	- the hwnd / id of your gui
	- the hwnd / id of the window to show
	- the coordinates where to show the thumbnail
	- the coordinates of the area to be shown

What to do:
- Create a new Thumbnail instance
- Set its regions with <SetRegion> or <SetDestinationRegion> and <SetSourceRegion>, optionally query for the source windows width and height before with <GetSourceSize> or <GetSourceWidth> and <GetSourceHeight>
- optionally set the opacity with <SetOpacity>
- show the thumbnail with <Show>
***************************************************************************************************************	
*/
class Thumbnail
{
	/**********************************************************************************************************
	field: module
		static field that contains the hModule handle to the loaded dwmapi.dll.
		This field is for internal use only.

	See also:
		- <Unload>
	***********************************************************************************************************
	*/
	static module := DllCall("LoadLibrary", "Str", "dwmapi.dll")

	/**********************************************************************************************************
	field: handle
		contains the hThumb handle to the thumbnail.
		This field is for internal use only.

	See also:
		- <Destroy>
	***********************************************************************************************************
	*/
	handle := 0

	/**********************************************************************************************************
	method: __New
		constructor for the class

	Parameters:
		hWnd hDestination - the handle to the window to display the thumbnail
		hWnd hSource - 	the handle to the window to be displayed by the thumbnail
	
	Returns:
		Thumbnail instance - the new Thumbnail instance
	***********************************************************************************************************
	*/
	__New(hDestination, hSource)
	{
		VarSetCapacity(thumbnail,	4,	0)
		if (DllCall("dwmapi.dll\DwmRegisterThumbnail", "UPtr", hDestination, "UPtr", hSource, "Ptr", &thumbnail) != 0x00)
			return false
		this.id := NumGet(thumbnail)
	}

	/**********************************************************************************************************
	method: __Delete
		deconstructor for the class.
	***********************************************************************************************************
	*/
	__Delete()
	{
		this.Destroy()
	}

	/**********************************************************************************************************
	method: Destroy
		destroys a thumbnail relationship and sets the handle to 0

	returns:
		bool success - true on success, false on failure
	***********************************************************************************************************
	*/
	Destroy()
	{
		id := this.id
		this.id := 0
		return DllCall("dwmapi.dll\DwmUnregisterThumbnail", "UPtr", id) >= 0x00
	}

	/**********************************************************************************************************
	method: GetSourceSize
		gets the width and height of the source window

	Parameters:
		ByRef int width - receives the width of the window
		ByRef int height - receives the height of the window

	returns:
		bool success - true on success, false on failure

	See also:
		- <GetSourceWidth>
		- <GetSourceHeight>
		- <SetSourceRegion>
	***********************************************************************************************************
	*/
	GetSourceSize(ByRef width, ByRef height)
	{
		VarSetCapacity(Size, 8, 0)
		if (DllCall("dwmapi.dll\DwmQueryThumbnailSourceSize", "UPtr", this.id, "Ptr", &Size) != 0x00)
			return false
		width := NumGet(&Size + 0, 0, "int")
		height := NumGet(&Size + 0, 4, "int")
		return true
	}

	/**********************************************************************************************************
	method: GetSourceHeight
		gets the height of the source window

	returns:
		int height - the source window's height

	See also:
		- <GetSourceSize>
		- <GetSourceWidth>
		- <SetSourceRegion>
	***********************************************************************************************************
	*/
	GetSourceHeight()
	{
		this.GetSourceSize(width, height)
		return height
	}

	/**********************************************************************************************************
	method: GetSourceWidth
		gets the width of the source window

	returns:
		int width - the source window's width

	See also:
		- <GetSourceSize>
		- <GetSourceHeight>
		- <SetSourceRegion>
	***********************************************************************************************************
	*/
	GetSourceWidth()
	{
		this.GetSourceSize(width, height)
		return width
	}

	/**********************************************************************************************************
	method: Hide
		hides a thumbnail. It can be shown again without recreating

	returns:
		bool success - true on success, false on failure

	See also:
		- <Show>
	***********************************************************************************************************
	*/
	Hide()
	{
		static dwFlags := 0x00000008, fVisible := false

		VarSetCapacity(dskThumbProps, 45, 0)

		NumPut(dwFlags,		dskThumbProps,	0,	"UInt")
		NumPut(fVisible,	dskThumbProps,	37,	"UInt")

		return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties",	"UPtr",	this.id,	"Ptr",	&dskThumbProps) >= 0x00
	}

	/**********************************************************************************************************
	method: SetDestinationRegion
		sets the region to be used for displaying

	Parameters:
		int xDest - the x-coordinate of the rendered thumbnail inside the destination window
		int yDest - the y-coordinate of the rendered thumbnail inside the destination window
		int wDest - the width of the rendered thumbnail inside the destination window
		int hDest - the height of the rendered thumbnail inside the destination window

	returns:
		bool success - true on success, false on failure

	See also:
		- <SetRegion>
		- <SetSourceRegion>
	***********************************************************************************************************
	*/
	SetDestinationRegion(xDest, yDest, wDest, hDest)
	{
		static dwFlags := 0x00000001

		VarSetCapacity(dskThumbProps, 45, 0)

		NumPut(dwFlags,		dskThumbProps,	0,	"UInt")
		NumPut(xDest,		dskThumbProps,	4,	"Int")
		NumPut(yDest,		dskThumbProps,	8,	"Int")
		NumPut(wDest+xDest,		dskThumbProps,	12,	"Int")
		NumPut(hDest+yDest,		dskThumbProps,	16,	"Int")

		return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties",	"UPtr",	this.id,	"Ptr",	&dskThumbProps) >= 0x00
	}

	/**********************************************************************************************************
	method: SetIncludeSourceNC
		sets whether the source's non-client area should be included. The default value is true.

	Parameters:
		bool include - true to include the non-client area, false to exclude it

	returns:
		bool success - true on success, false on failure
	***********************************************************************************************************
	*/
	SetIncludeSourceNC(include)
	{
		static dwFlags := 0x00000010

		VarSetCapacity(dskThumbProps, 45, 0)

		NumPut(dwFlags,		dskThumbProps,	0,	"UInt")
		NumPut(!include,		dskThumbProps,	42, "UInt")

		return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties",	"UPtr",	this.id,	"Ptr",	&dskThumbProps) >= 0x00
	}

	/**********************************************************************************************************
	method: SetOpacity
		sets the opacity level of the thumbnail

	returns:
		bool success - true on success, false on failure
	***********************************************************************************************************
	*/
	SetOpacity(opacity)
	{
		static dwFlags := 0x00000004

		VarSetCapacity(dskThumbProps, 45, 0)

		NumPut(dwFlags,		dskThumbProps,	0,	"UInt")
		NumPut(opacity,		dskThumbProps,	36,	"UChar")

		return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties", "UPtr", this.id, "Ptr", &dskThumbProps) >= 0x00
	}

	/**********************************************************************************************************
	method: SetRegion
		sets the regions for both the area to be displayed and the area to be used for displaying

	Parameters:
		int xDest - the x-coordinate of the rendered thumbnail inside the destination window
		int yDest - the y-coordinate of the rendered thumbnail inside the destination window
		int wDest - the width of the rendered thumbnail inside the destination window
		int hDest - the height of the rendered thumbnail inside the destination window
		int xSource - the x-coordinate of the area that will be shown inside the thumbnail
		int ySource - the y-coordinate of the area that will be shown inside the thumbnail
		int wSource - the width of the area that will be shown inside the thumbnail
		int hSource - the height of the area that will be shown inside the thumbnail

	returns:
		bool success - true on success, false on failure

	See also:
		- <SetDestinationRegion>
		- <SetSourceRegion>
	***********************************************************************************************************
	*/
	SetRegion(xDest, yDest, wDest, hDest, xSource, ySource, wSource, hSource)
	{
		return this.SetDestinationRegion(xDest, yDest, wDest, hDest) && this.SetSourceRegion(xSource, ySource, wSource, hSource)
	}
	
	/**********************************************************************************************************
	method: SetSourceRegion
		sets the region to be displayed

	Parameters:
		int xSource - the x-coordinate of the area that will be shown inside the thumbnail
		int ySource - the y-coordinate of the area that will be shown inside the thumbnail
		int wSource - the width of the area that will be shown inside the thumbnail
		int hSource - the height of the area that will be shown inside the thumbnail

	returns:
		bool success - true on success, false on failure

	See also:
		- <SetRegion>
		- <SetDestinationRegion>
		- <GetSourceSize>
		- <GetSourceWidth>
		- <GetSourceHeight>
	***********************************************************************************************************
	*/
	SetSourceRegion(xSource, ySource, wSource, hSource)
	{
		static dwFlags := 0x00000002

		VarSetCapacity(dskThumbProps, 45, 0)

		NumPut(dwFlags,		dskThumbProps,	0,	"UInt")
		NumPut(xSource,		dskThumbProps,	20,	"Int")
		NumPut(ySource,		dskThumbProps,	24,	"Int")
		NumPut(wSource-xSource,		dskThumbProps,	28,	"Int")
		NumPut(hSource-ySource,		dskThumbProps,	32,	"Int")

		return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties",	"UPtr",	this.id,	"Ptr",	&dskThumbProps) >= 0x00
	}

	/**********************************************************************************************************
	method: Show
		shows a previously created and sized thumbnail

	returns:
		bool success - true on success, false on failure

	See also:
		- <Hide>
	***********************************************************************************************************
	*/
	Show()
	{
		static dwFlags := 0x00000008, fVisible := true

		VarSetCapacity(dskThumbProps, 45, 0)

		NumPut(dwFlags,		dskThumbProps,	0,	"UInt")
		NumPut(fVisible,	dskThumbProps,	37,	"UInt")

		return DllCall("dwmapi.dll\DwmUpdateThumbnailProperties",	"UPtr",	this.id,	"Ptr",	&dskThumbProps) >= 0x00
	}

	/**********************************************************************************************************
	method: Unload
		unloads the dwmapi-library and sets the module-field to 0

	returns:
		bool success - true on success, false on failure
	***********************************************************************************************************
	*/
	Unload()
	{
		module := Thumbnail.module
		Thumbnail.module := 0
		return DllCall("FreeLibrary", "UPtr", module)
	}
}